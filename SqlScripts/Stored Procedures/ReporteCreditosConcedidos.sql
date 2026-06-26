--select fecha,valor=sum(valor),tipo,codigo from bvq_backoffice.IsspolAsientoCredito where tipo='D' group by codigo,fecha

--sp_helptext 'BVQ_BACKOFFICE.RendimientoPorPlazoPrivativas'
--sp_helptext 'BVQ_BACKOFFICE.RendimientoPorPlazoPrivativas'
--sp_helptext 'bvq_backoffice.RendimientoPrivativas'
--sp_helptext 'bvq_backoffice.recuperacionesprivativas'
--select * from sys.views v where name like '%ultim%'
--sp_helptext 'bvq_backoffice.UltimoDiaHabil'
--select * from bvq_backoffice.

--sp_helptext 'bvq_backoffice.RecuperacionesPrivativas'
--sp_helptext 'bvq_backoffice.ReporteCreditosConcedidos'
--go
--sp_helptext 'bvq_backoffice.IsspolAsientoCredito'
-- =============================================
-- Author:		<Author,José Pullaguari>
-- Create date: <02/05/2023>
-- Description:	<Sp Movimientos migra créditos concedidos>
-- ============================================= 
ALTER PROCEDURE [BVQ_BACKOFFICE].[ReporteCreditosConcedidos]
--declare
@i_fecha_ini DATETIME = '20250801',
@i_fecha_fin DATETIME = '20250909',
@i_incluir_rendimiento bit=1,
@i_usar_mora BIT = 0,
@i_lga_id INT = NULL
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	exec dropifexists 'bvq_backoffice.IsspolAsientoCreditoTable'
	select * into bvq_backoffice.IsspolAsientoCreditoTable
	from bvq_backoffice.IsspolAsientoCredito


	/*==============================SALDO INICIAL===============================*/
	DECLARE @valorInicialPQ FLOAT = 140285675.09
		   ,@valorInicialPH FLOAT = 7745129.18
	IF OBJECT_ID('tempdb..#TEMPSALDOINICIAL') IS NOT NULL
	BEGIN
		DROP TABLE #TEMPSALDOINICIAL;
	END;

	CREATE TABLE #TEMPSALDOINICIAL (
		FinMes DATE
	   ,DESCRIPCION VARCHAR(20)
	   ,DETALLE VARCHAR(20)
	   ,MONTO FLOAT
	   ,INTERES_G FLOAT
	   ,INTERES_MORA FLOAT
	   ,SUMAN FLOAT
	   ,TIPO VARCHAR(5)
	)
	INSERT INTO #TEMPSALDOINICIAL
	values
	 ('20100316','INICIO',0,0,0,0,0,'PQ')
	,('20100122','INICIO',0,0,0,0,0,'PH')


	/*===========================FIN SALDO INICIAL=================================================*/


	--agrupado por mes y segmento
	EXEC DropIfExists 'BVQ_BACKOFFICE.RendimientoPrivativasPorCierre'
	SELECT
		TIN = SUM(rpp * peso) * 100.0
	   ,crc_fecha_cierre
	   ,crc_segmento
	INTO bvq_backoffice.RendimientoPrivativasPorCierre
	FROM (SELECT
			ppp = SUM(saldo / saldoPorTasa * PLAZO)
		   ,crc_segmento
		   ,saldo = SUM(saldo)
		   ,rpp = crc_tasa / 100.0
		   ,peso = MAX(saldoPorTasa) / (SUM(MAX(saldoPorTasa)) OVER (PARTITION BY crc_segmento, crc_fecha_cierre))
		   ,crc_fecha_cierre
		FROM bvq_backoffice.RendimientoPrivativas
		GROUP BY crc_segmento
				,crc_tasa
				,crc_fecha_cierre
	--having datediff(m,crc_fecha_cierre,'20230901')=0
	--order by crc_fecha_cierre desc
	) s
	GROUP BY crc_fecha_cierre
			,crc_segmento


	EXEC DropIfExists 'BVQ_BACKOFFICE.RendimientoPrivativasPorCierreTotal'

	SET LANGUAGE 'spanish'

	--si @i_fecha_fin es el último día hábil del mes convertirla al último día del mes
	if 1=1 and convert(date,@i_fecha_fin)=(select ultimo from BVQ_BACKOFFICE.UltimoDiaHabil where fecha=eomonth(@i_fecha_fin))
		set @i_fecha_fin=eomonth(@i_fecha_fin)
	--else
		--set @i_fecha_fin=convert(date,@i_fecha_fin)

	-- agrupado por mes y segmento
	SELECT
		FECHA_OTORGAMIENTO =--dateadd(m,month(fecha),dateadd(yy,year(fecha),0)+dateadd(m,month(fecha),0)
		DATEADD(s, -1,
		DATEADD(m, MONTH(fecha) - 1 + 1,
		DATEADD(yy, YEAR(fecha) - 1900, 0)
		)
		)
	   ,TIPO_PRODUCTO =
		CASE LEFT(codigo, 2)
			WHEN 'PH' THEN 'HIPOTECARIO'
			ELSE 'QUIROGRAFARIO'
		END
	   ,MONTO = SUM(valor)
	   ,ID_CREDITO =
		CASE LEFT(codigo, 2)
			WHEN 'PH' THEN 'PH'
			ELSE 'PQ'
		END + ' ' + STUFF(FORMAT(fecha, 'MMMM'), 1, 1, UPPER(LEFT(FORMAT(fecha, 'MMMM'), 1)))
	   ,INTERES = MAX(r.TIN)
		/*case left(codigo,2)
					when 'PH' then 7.0
					else 9.07
		end*/
	   ,PLAZO =
		CASE LEFT(codigo, 2)
			WHEN 'PH' THEN 7200
			ELSE 2880
		END
	   ,GASTOS_ADM = NULL
	   ,SEGURO_DES = NULL--,
	--MesLetras=format(fecha,'MMMM')
	--xxx
	INTO bvq_backoffice.RendimientoPrivativasPorCierreTotal

	FROM (
		--select fecha=fecha_hasta,valor=convert(float,debito),tipo='D', codigo from bvq_backoffice.IsspolSaldos
		select fecha,valor=sum(valor),tipo,codigo from bvq_backoffice.IsspolAsientoCreditoTable where tipo='D' group by codigo,tipo,fecha
	) a--Table a

	LEFT JOIN bvq_backoffice.RendimientoPrivativasPorCierre r
		--BVQ_BACKOFFICE.RendimientoPrivativasPorSegmento r
		ON DATEDIFF(m, a.fecha, r.crc_fecha_cierre) = 0
			AND (
				LEFT(a.codigo, 2) = 'PQ'
				AND r.crc_segmento = 'QUIROGRAFARIO'
				OR LEFT(a.codigo, 2) = 'PH'
				AND r.crc_segmento = 'HIPOTECARIO'
			)
	/*FROM siisspolweb.siisspolweb.contabilidad.ASIENTO A
				inner join siisspolweb.siisspolweb.contabilidad.movimiento M on a.id_asiento=m.id_asiento
				inner join siisspolweb.siisspolweb.contabilidad.cuenta C on m.id_cuenta=c.id_cuenta*/
	WHERE
	/*(c.cuenta like '7130302%' or c.cuenta like '7130301%' )      
	and a.id_estado_asi <>'N'
	and*/ TIPO = 'D'
	AND (
	a.fecha>='20200101'--30531'
	--and a.fecha >= @i_fecha_ini
	AND a.fecha <= @i_fecha_fin
	)
	-->='01/01/2021'
	--and left (codigo,2)in (@v_tipo_credito)
	GROUP BY
	--year(fecha)
	--, month(fecha)
	--eom 23:59:59 :
	DATEADD(s, -1,
	DATEADD(m, MONTH(fecha) - 1 + 1,
	DATEADD(yy, YEAR(fecha) - 1900, 0)
	)
	)
   ,LEFT(codigo, 2)
   ,FORMAT(fecha, 'MMMM')
	ORDER BY 1, 2, 3
	

	--tabla final para reporte de créditos concedidos
	;with a as(
		SELECT saldo=sum(monto) over (partition by tipo_producto order by seccion,f1,fecha_otorgamiento),
			*
		FROM (
			SELECT
				FECHA_OTORGAMIENTO,TIPO_PRODUCTO,MONTO,ID_CREDITO,INTERES,PLAZO,GASTOS_ADM,SEGURO_DES
				,f1=null,seccion=3
			FROM bvq_backoffice.RendimientoPrivativasPorCierreTotal
			where datediff(mm,FECHA_OTORGAMIENTO,@i_fecha_fin)>=0
			UNION ALL
			select fecha,producto,convert(float,monto),numero,0,0,null,null
			,f1,seccion=2
			from bvq_backoffice.IsspolConcesionesHistoricas where 1=0 --where fecha>=@i_fecha_ini
			/*UNION ALL
			SELECT
				FECHA_OTORGAMIENTO = @i_fecha_ini
			   ,TIPO_PRODUCTO =
				CASE T.TIPO
					WHEN 'PH' THEN 'HIPOTECARIO'
					ELSE 'QUIROGRAFARIO'
				END
			   ,MONTO = SUM(MONTO)
			   ,ID_CREDITO = T.DESCRIPCION
			   ,INTERES = 0
			   ,PLAZO = 0
			   ,GASTOS_ADM = NULL
			   ,SEGURO_DES = NULL
			   ,f1=null
			   ,seccion=1
			FROM #TEMPSALDOINICIAL T
			--WHERE TIPO = @v_tipo_credito
			GROUP BY FinMes
					,DESCRIPCION
					,TIPO*/
		) AS REPORTE
	) select * from a --where /*datediff(d,@i_fecha_ini,FECHA_OTORGAMIENTO)>=0 and*/ datediff(mm,FECHA_OTORGAMIENTO,@i_fecha_fin)>=0
				--where tipo_producto='quirografario'
	ORDER BY TIPO_PRODUCTO, seccion, f1, fecha_otorgamiento
	if @i_incluir_rendimiento=0
		return
	exec bvq_backoffice.CargaCreditosCarteraISSPOL2 null--@i_lga_id=@i_lga_id

	--tabla final para reporte de rendimiento privativas
	IF @i_usar_mora = 1
		SELECT *
		FROM bvq_backoffice.ReporteRendimientoPrivativasMora
		WHERE crc_fecha_cierre = (
			select max(crc_fecha_cierre) from bvq_backoffice.creditos_cartera where DATEDIFF(m, crc_fecha_cierre, @i_fecha_fin)>=0
		)
		ORDER BY rpp
	ELSE
		SELECT *
		FROM bvq_backoffice.ReporteRendimientoPrivativas
		WHERE crc_fecha_cierre = (
			select max(crc_fecha_cierre) from bvq_backoffice.creditos_cartera where DATEDIFF(m, crc_fecha_cierre, @i_fecha_fin)>=0
		)
		ORDER BY rpp

	select tipo_producto,saldo_cuentas_malas=sum(saldo)--,per.fecha_hasta,cuenta.cuenta
	FROM siisspolweb.siisspolweb.contabilidad.saldo A with (nolock)
	INNER JOIN siisspolweb.siisspolweb.contabilidad.cuenta with (nolock)
			ON a.id_cuenta = cuenta.id_cuenta
	INNER JOIN siisspolweb.siisspolweb.contabilidad.periodo per with (nolock)
			ON A.id_periodo = per.id_periodo
	join (values
		 ('PQ','7139930001')
		,('PQ','7139930003')
		,('PQ','7139930004')
		,('PQ','7139930006')
		,('PQ','7139930007')
		,('PQ','7139930011')
		,('PH','7139930002')
	) v (tipo_producto,cuenta)
	on v.cuenta=cuenta.cuenta
	and datediff(mm,per.fecha_hasta,@i_fecha_fin)=0
	group by tipo_producto
END
GO


--exec [BVQ_BACKOFFICE].[ReporteCreditosConcedidos] '20250801', '20250831', 1, NULL, 0  -- sin mora
--exec [BVQ_BACKOFFICE].[ReporteCreditosConcedidos] '20250801', '20250831', 1, NULL, 1  -- con mora