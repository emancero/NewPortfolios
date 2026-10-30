CREATE PROCEDURE [BVQ_BACKOFFICE].[VerificarSaldosUltimoPeriodo]
	@i_lga_id int = null,
	@i_anteriores bit = 0	--0: ultimo periodo cerrado; 1: todos los periodos cerrados anteriores al ultimo
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#vista') IS NOT NULL
	DROP TABLE #vista;

	SELECT * INTO #vista
	FROM BVQ_BACKOFFICE.SaldosPeriodosCerradosView
	WHERE ((@i_anteriores = 0 AND orden = 1)
	    OR (@i_anteriores = 1 AND orden > 1))
	  AND CAST(EJERCICIO_ANIO AS int) * 100 + mes >= 202305	--solo desde mayo 2023

	--Periodos a verificar con su fecha de corte: ultimo dia laborable del mes del periodo
	IF OBJECT_ID('tempdb..#periodos') IS NOT NULL
	DROP TABLE #periodos;

	SELECT
		p.PERIODO_ID,
		p.periodo_siisspol,
		p.fecha_corte,
		cortenum = ROW_NUMBER() OVER (ORDER BY p.fecha_corte)
	INTO #periodos
	FROM (
		SELECT
			v.PERIODO_ID,
			v.periodo_siisspol,
			fecha_corte = DATETIMEFROMPARTS(YEAR(f.d), MONTH(f.d), DAY(f.d), 23, 59, 59, 0)
		FROM (SELECT DISTINCT EJERCICIO_ANIO, mes, PERIODO_ID, periodo_siisspol FROM #vista) v
			CROSS APPLY (SELECT d = dbo.fnUltimoDiaLaborable(EOMONTH(DATEFROMPARTS(CAST(v.EJERCICIO_ANIO AS int), v.mes, 1)))) f
	) p

	--Valor efectivo del portafolio por fecha de corte y tipo de renta
	IF OBJECT_ID('tempdb..#port') IS NOT NULL
	DROP TABLE #port;

	CREATE TABLE #port (
		tfcorte datetime,
		tiv_tipo_renta int,
		saldo_valor_efectivo float
	);

	IF EXISTS (SELECT 1 FROM #periodos)
	BEGIN
		--Una sola generacion para todas las fechas de corte (antes: ObtenerInfoPortfoliosPorFecha por periodo).
		--generarcompraventacorte no depende de corteslist; generarvectores, PrepararValoracionLinealCache
		--y portafoliocorte calculan todos los cortes de corteslist a la vez.
		BEGIN TRAN
			TRUNCATE TABLE corteslist
			INSERT INTO corteslist (c, cortenum)
			SELECT fecha_corte, cortenum FROM #periodos

			EXEC bvq_administracion.generarcompraventacorte
			EXEC bvq_administracion.generarvectores
			EXEC BVQ_ADMINISTRACION.PrepararValoracionLinealCache

			--Mismas filas y VALOR_EFECTIVO que ObtenerInfoPortfoliosPorFecha, solo las vigentes (sin CxC):
			--con IPR_ES_CXC = 0 su iif siempre toma la primera rama
			INSERT INTO #port (tfcorte, tiv_tipo_renta, saldo_valor_efectivo)
			SELECT
				s.tfcorte,
				s.tiv_tipo_renta,
				SUM(s.VALOR_EFECTIVO)
			FROM (
				SELECT DISTINCT
					pc.tfcorte,
					pc.httpo_id,
					pc.por_id,
					pc.tiv_id,
					pc.tiv_tipo_renta,
					VALOR_EFECTIVO = COALESCE(
						COALESCE(PRE.PRE_VALOR, pc.prEfectivo) * pc.salNewValNom,
						pc.htp_precio_compra / 100.0 * pc.salNewValNom + ISNULL(pc.TPO_INTERES_TRANSCURRIDO, 0) + ISNULL(pc.TPO_COMISION_BOLSA, 0)
					)
				FROM bvq_backoffice.portafoliocorte pc
					INNER JOIN bvq_administracion.tipo_valor tvl
						ON pc.tiv_tipo_valor = tvl.tvl_id
					INNER JOIN bvq_backoffice.portafolio por
						ON pc.por_id = por.por_id
					INNER JOIN bvq_prevencion.personacomitente ctc
						ON ctc.ctc_id = por.ctc_id
					INNER JOIN bvq_administracion.item_catalogo tipo
						ON por.por_tipo = tipo.itc_id
					INNER JOIN bvq_administracion.item_catalogo rent
						ON pc.tiv_tipo_renta = rent.itc_id
					INNER JOIN bvq_administracion.tipo_tasa tta
						ON pc.tiv_tipo_tasa = tta.tta_id
					LEFT JOIN BVQ_BACKOFFICE.PRECIO_EFECTIVO PRE
						ON (
							PRE.PRE_TPO_ID IS NULL AND PRE.TIV_ID = pc.TIV_ID AND PRE.POR_ID = pc.POR_ID
							OR PRE.PRE_TPO_ID = pc.httpo_id
						)
						AND pc.tfcorte >= PRE.PRE_FECHA_INICIO AND pc.tfcorte < PRE.PRE_FECHA_FIN
				WHERE ISNULL(pc.IPR_ES_CXC, 0) = 0
				  AND (pc.sal > 0 OR ROUND(pc.salNewValNom, 2) > 0)
			) s
			GROUP BY s.tfcorte, s.tiv_tipo_renta
		COMMIT TRAN
	END

	--Cuadre por periodo y tipo de renta
	--La renta de la cuenta contable sale de su cuenta padre:
	--7.1.2 (inversiones a valor justo) = renta variable, 7.1.3 (inversiones al costo amortizado) = renta fija
	;WITH ren AS (
		SELECT r.prefijo, itc.ITC_ID, itc.ITC_CODIGO, itc.ITC_DESCRIPCION
		FROM (VALUES ('7.1.2', 'REN_VARIABLE'), ('7.1.3', 'REN_FIJA')) r(prefijo, codigo)
			INNER JOIN BVQ_ADMINISTRACION.ITEM_CATALOGO itc
				ON itc.ITC_CODIGO = r.codigo
	), cont AS (
		SELECT
			PERIODO_ID,
			prefijo = LEFT(cuenta_formato, 5),
			saldo_contable = SUM(saldo)
		FROM #vista
		GROUP BY PERIODO_ID, LEFT(cuenta_formato, 5)
	)
	SELECT
		p.fecha_corte,
		p.PERIODO_ID,
		p.periodo_siisspol,
		tipo_renta = ren.ITC_ID,	--= tiv_tipo_renta (153 renta fija, 154 renta variable)
		tipo_renta_codigo = ren.ITC_CODIGO,
		renta = ren.ITC_DESCRIPCION,
		port.saldo_valor_efectivo,
		cont.saldo_contable,
		diferencia = ISNULL(cont.saldo_contable, 0) - ISNULL(port.saldo_valor_efectivo, 0)
	FROM #periodos p
		CROSS JOIN ren
		LEFT JOIN #port port
			ON  port.tfcorte = p.fecha_corte
			AND port.tiv_tipo_renta = ren.ITC_ID
		LEFT JOIN cont
			ON  cont.PERIODO_ID = p.PERIODO_ID
			AND cont.prefijo = ren.prefijo
	ORDER BY p.fecha_corte DESC, ren.ITC_DESCRIPCION
END
GO

--exec BVQ_BACKOFFICE.VerificarSaldosUltimoPeriodo
--exec BVQ_BACKOFFICE.VerificarSaldosUltimoPeriodo @i_anteriores = 1
