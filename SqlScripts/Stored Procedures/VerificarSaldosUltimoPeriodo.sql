ALTER PROCEDURE [BVQ_BACKOFFICE].[VerificarSaldosUltimoPeriodo]
	@i_lga_id int = null
AS
BEGIN
	DECLARE @anio int, @mes int, @fecha_corte datetime

	IF OBJECT_ID('tempdb..#vista') IS NOT NULL
	DROP TABLE #vista;

	SELECT * INTO #vista FROM BVQ_BACKOFFICE.SaldosUltimoPeriodoView

	IF OBJECT_ID('tempdb..#cont') IS NOT NULL
	DROP TABLE #cont;

	SELECT
		v.EJERCICIO_ANIO, v.mes, v.PERIODO_ID, v.periodo_siisspol, v.estado_sicav_desc,
		saldo_contable = SUM(v.saldo)
	INTO #cont
	FROM #vista v
	GROUP BY v.EJERCICIO_ANIO, v.mes, v.PERIODO_ID, v.periodo_siisspol, v.estado_sicav_desc

	--Fecha de corte: ultimo dia laborable del mes del periodo
	SELECT TOP 1 @anio = CAST(EJERCICIO_ANIO AS int), @mes = mes FROM #cont;

	IF @anio IS NULL
		RETURN;	--sin periodo cerrado o sin saldos

	SET @fecha_corte = dbo.fnUltimoDiaLaborable(EOMONTH(DATEFROMPARTS(@anio, @mes, 1)));
	SET @fecha_corte = DATETIMEFROMPARTS(YEAR(@fecha_corte), MONTH(@fecha_corte), DAY(@fecha_corte),23,59,59,0);

	IF OBJECT_ID('tempdb..#InfoPortfolios') IS NOT NULL
	DROP TABLE #InfoPortfolios;

	CREATE TABLE #InfoPortfolios (
		comitente varchar(max),
		ems_nombre varchar(500),
		tvl_descripcion varchar(255),
		renta varchar(max),
		tta_nombre varchar(500),
		por_tipo_nombre varchar(500),
		por_codigo varchar(500),
		tiv_precio float,
		por_id int,
		tiv_id int,
		tiv_tasa_interes float,
		tiv_fecha_emision datetime,
		tiv_fecha_vencimiento datetime,
		htp_numeracion varchar(550),
		tfcorte datetime,
		fecha_compra datetime,
		htp_precio_compra float,
		valefeoper float,
		htp_compra float,
		liq_rendimiento float,
		accrual float,
		latest_inicio datetime,
		tpo_tipo_valoracion bit,
		sal float,
		dias_al_corte int,
		prox_capital datetime,
		prox_interes datetime,
		POR_DESCRIPCION varchar(max),
		SBP_DESCRIPCION varchar(500),
		VALOR_UNITARIO float,
		VALOR_NOMINAL float,
		IPR_ES_CXC bit,
		TPO_ACTA varchar(510),
		VALOR_EFECTIVO float,
		TIPO_RENTA varchar(14),
		ESTADO varchar(18),
		Por_ord int,
		httpo_id int,
		tpo_recursos varchar(530),
		TPO_PRECIO_REGISTRO_VALOR_EFECTIVO float,
		TPO_TABLA_AMORTIZACION varchar(540),
		CALIFICACION_DE_RIESGO nvarchar(513),
		PRECIO_DE_HOY float,
		INTERES_GANADO float,
		prEfectivo float,
		YIELD float,
		NUEVO_VALOR_NOMINAL float,
		SECTOR varchar(500),
		INTERES_GANADO_2 float,
		tiv_tipo_base int,
		NOMBRE_BONO varchar(100),
		TPO_F1 int,
		SECTOR2 varchar(47)
	);

	INSERT INTO #InfoPortfolios
	EXEC BVQ_BACKOFFICE.ObtenerInfoPortfoliosPorFecha @i_fechaCorte = @fecha_corte, @i_lga_id = @i_lga_id;

	--Cuadre por tipo de renta
	--La renta de la cuenta contable sale de su cuenta padre:
	--7.1.2 (inversiones a valor justo) = renta variable, 7.1.3 (inversiones al costo amortizado) = renta fija
	;WITH ren AS (
		SELECT r.prefijo, itc.ITC_ID, itc.ITC_CODIGO, itc.ITC_DESCRIPCION
		FROM (VALUES ('7.1.2', 'REN_VARIABLE'), ('7.1.3', 'REN_FIJA')) r(prefijo, codigo)
			INNER JOIN BVQ_ADMINISTRACION.ITEM_CATALOGO itc
				ON itc.ITC_CODIGO = r.codigo
	), port AS (
		SELECT
			renta,
			saldo_valor_efectivo = SUM(VALOR_EFECTIVO)
		FROM #InfoPortfolios
		WHERE ISNULL(ipr_es_cxc, 0) = 0
		GROUP BY renta
	), cont AS (
		SELECT
			prefijo = LEFT(cuenta_formato, 5),
			saldo_contable = SUM(saldo)
		FROM #vista
		GROUP BY LEFT(cuenta_formato, 5)
	)
	SELECT
		fecha_corte = @fecha_corte,
		c.PERIODO_ID,
		c.periodo_siisspol,
		tipo_renta = ren.ITC_ID,	--= tiv_tipo_renta (153 renta fija, 154 renta variable)
		tipo_renta_codigo = ren.ITC_CODIGO,
		renta = ren.ITC_DESCRIPCION,
		port.saldo_valor_efectivo,
		cont.saldo_contable,
		diferencia = ISNULL(cont.saldo_contable, 0) - ISNULL(port.saldo_valor_efectivo, 0)
	FROM ren
		CROSS JOIN (SELECT TOP 1 PERIODO_ID, periodo_siisspol FROM #cont) c
		LEFT JOIN port
			ON port.renta COLLATE DATABASE_DEFAULT = ren.ITC_DESCRIPCION
		LEFT JOIN cont
			ON cont.prefijo = ren.prefijo
	ORDER BY ren.ITC_DESCRIPCION
END
GO

--exec BVQ_BACKOFFICE.VerificarSaldosUltimoPeriodo
