CREATE PROCEDURE [BVQ_ADMINISTRACION].[ObtenerTitulosYTiposValoresPorEmisorYPortafolio] (
	@ems_id INT
	,@fecha DATETIME
	,@port_id INT
	,@historic BIT=0
	,@i_lga_id INT
	)
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
		--if not (@port_id=-1 or @port_id is null)
		--begin			
		--	exec bvq_backoffice.GenerarCompraVentaPortafolio
		--	exec bvq_administracion.GenerarTituloFlujoComun
		--	exec bvq_backoffice.GenerarCompraVentaFlujo
			
		--	select htp_tpo_id into #tmpSaldo from bvq_backoffice.eventoportafolio where htp_fecha_operacion<=@fecha group by htp_tpo_id having sum(montooper)>=0.005e
		--end	

	DECLARE @fechaDiaIni DATETIME;
	DECLARE @fechaDiaSig DATETIME;
	DECLARE @v_vig_dli INT;
	DECLARE @v_vig_htp INT;

	-- Inicio del día de @fecha
	SET @fechaDiaIni = DATEADD(DAY, DATEDIFF(DAY, 0, @fecha), 0);
	-- Inicio del día siguiente
	SET @fechaDiaSig = DATEADD(DAY, 1, @fechaDiaIni);

	SELECT @v_vig_dli = ITC_ID FROM BVQ_ADMINISTRACION.CatalogoItemCatalogo WHERE cat_codigo = 'BCK_EST_TIT_ORDEN' AND ITC_CODIGO = 'L';

	SELECT @v_vig_htp = ITC_ID FROM BVQ_ADMINISTRACION.CatalogoItemCatalogo WHERE cat_codigo = 'BCK_ES_TIT_POR' AND ITC_CODIGO = 'A';;

	WITH Base
	AS (
		SELECT tut.tiv_id
			,tut.tvl_id
			,tiv.tiv_fecha_vencimiento
			,tiv.tiv_fecha_emision
			,tvl.tvl_id AS tvl_id_real
			,tiv.tiv_codigo
			,tiv.tiv_tasa_interes
			,tvl.tvl_codigo
			,tiv.tiv_subtipo
			,tiv.tiv_tipo_renta
			,tiv.tiv_serie
			,tiv.TIV_GARANTIA_REPORTO
			,tiv.TIV_MATERIA_REPORTO
		FROM BVQ_ADMINISTRACION.tipo_valor tvl
		LEFT JOIN BVQ_ADMINISTRACION.TivUnionTvl tut ON tvl.tvl_id = tut.tvl_id
			AND tut.ems_id = @ems_id
		LEFT JOIN BVQ_ADMINISTRACION.titulo_valor tiv ON tiv.tiv_id = tut.tiv_id
		LEFT JOIN BVQ_BACKOFFICE.TITULOS_PORTAFOLIO tpo ON tpo.tiv_id = tiv.tiv_id
				--and tpo.tpo_id in (select htp_tpo_id from #tmpSaldo)		
		WHERE 
		    ( @historic = 1 AND (tut.ems_id = @ems_id OR @ems_id >= 1000000)
			  AND ( EXISTS ( SELECT 1 FROM BVQ_BACKOFFICE.DETALLE_ORDEN_NEGOCIACION don WHERE don.TIV_ID = tut.tiv_id )
				OR EXISTS ( SELECT 1 FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO h WHERE h.TIV_ID = tut.tiv_id ) ) )
			OR
			( @historic = 0 AND (tut.ems_id = @ems_id OR @ems_id >= 1000000)
			AND ( @port_id = -1  OR @port_id IS NULL OR ( tpo.por_id = @port_id  AND tpo.tpo_saldo >= 0.005e  AND tpo.tpo_estado = 352 ) )
			AND ISNULL(tiv.TIV_FECHA_VENCIMIENTO, '99991231') >= @fechaDiaIni )
		)
		
	SELECT DISTINCT 
		b.tiv_id
		,b.tvl_id
		,COUNT(*) OVER ( PARTITION BY b.tvl_id ,b.tiv_fecha_vencimiento ,b.tiv_fecha_emision ) AS tvl_id__tiv_id_count
		,COALESCE(vp.precio, liq.precio, htp.precio) AS precio
		,RIGHT(b.tiv_codigo, 4) AS tiv_codigo_suffix
		,b.tiv_tasa_interes
		,b.tiv_fecha_emision
		,b.tiv_fecha_vencimiento
		,b.tvl_codigo
		,b.tiv_subtipo
		,b.tiv_tipo_renta
		,b.tiv_codigo
		,b.tiv_serie
		,b.TIV_GARANTIA_REPORTO
		,b.TIV_MATERIA_REPORTO
	FROM Base b
	OUTER APPLY (
		SELECT TOP (1) vp.VPR_PRECIO AS precio
		FROM BVQ_ADMINISTRACION.VECTOR_PRECIO vp
		WHERE vp.TIV_ID = b.tiv_id
			-- Equivalente a datediff(dd, VPR_FECHA, @fecha) > 0
			AND vp.VPR_FECHA < @fechaDiaIni
		ORDER BY vp.VPR_FECHA DESC ) vp
	OUTER APPLY (
		SELECT TOP (1) l.LIQ_PRECIO AS precio
		FROM BVQ_BACKOFFICE.DETALLE_LIQUIDACION dli
		INNER JOIN BVQ_BACKOFFICE.LIQUIDACION l ON l.DLI_ID = dli.DLI_ID
		WHERE dli.TIV_ID = b.tiv_id
			AND dli.DLI_ESTADO = @v_vig_dli
			-- Equivalente a datediff(dd, LIQ_FECHA_VALOR, @fecha) >= 0
			AND l.LIQ_FECHA_VALOR < @fechaDiaSig
		ORDER BY l.LIQ_ID DESC ) liq
	OUTER APPLY (
		SELECT TOP (1) CASE 
				WHEN htp.HTP_PRECIO_COMPRA <> 0 THEN htp.HTP_PRECIO_COMPRA
				WHEN htp.HTP_PRECIO_VENTA <> 0 THEN htp.HTP_PRECIO_VENTA
				ELSE 0.0 END AS precio
		FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO htp
		WHERE htp.TIV_ID = b.tiv_id
			AND htp.HTP_FECHA_OPERACION < @fechaDiaSig
			AND htp.HTP_ESTADO = @v_vig_htp
		ORDER BY htp.HTP_FECHA_OPERACION DESC ) htp
		
	ORDER BY b.tvl_id,b.tiv_fecha_vencimiento,b.tiv_codigo,b.tiv_id

	OPTION (RECOMPILE);
	
		--PV: Elimino tabla temporal
		--If(OBJECT_ID('tempdb..#tmpSaldo') Is Not Null)
		--Begin	Drop Table #tmpSaldo	End	
END
