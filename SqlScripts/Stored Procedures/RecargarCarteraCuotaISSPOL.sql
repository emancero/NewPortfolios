CREATE procedure [BVQ_BACKOFFICE].[RecargarCarteraCuotaISSPOL] as
begin

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    TRUNCATE TABLE [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA_FULL];

    INSERT INTO [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA_FULL]
        (por_codigo
		, total
		, fecha_vencimiento
		, id_cuenta
		, pagada
		, id_rubro
		, tasa
		, abono
		, estado
		, valor_pactado
		, id_credito
		, id_numero_cuota
		, fecha_pago
        , producto
        , segmento
		, fecha_otorgamiento
		)
    SELECT
         null--b.descripcion AS por_codigo
        ,valor
        ,cut.fecha_vencimiento
        ,null--,cr.id_cuenta
        ,CONVERT(INT, cut.pagada) AS pagada
        ,cut.id_rubro AS id_rubro
        ,cut.tasa
        ,abono
        ,null--,estado
        ,valor_pactado
		,cut.id_credito
		,cut.id_numero_cuota
		,cut.fecha_pago
        ,null--,cr.id_producto
        ,null--,cr.id_segmento
		,null--,cr.fecha_otorgamiento
	--select count(*)--top 1 cut.id_credito,cut.id_numero_cuota
    FROM siisspolweb.siisspolweb.credito.cuota cut
    --JOIN siisspolweb.siisspolweb.credito.credito cr ON cr.id_credito = cut.id_credito
    --JOIN siisspolweb.siisspolweb.banco.cuenta b ON b.id_cuenta = cr.id_cuenta
    WHERE cut.fecha_vencimiento > '20251130' --or 
	--cut.fecha_vencimiento <= '20251130'and cr.id_estado='V' and cut.pagada=0;
	--select top 10 * from siisspolweb.siisspolweb.credito.credito


	--Cargar en tabla de cubo -------------------------------------------------------------------------

	--Preparar calendario
	delete from bvq_backoffice.fechas_cierre_creditos_cartera
	insert into bvq_backoffice.fechas_cierre_creditos_cartera(fcrc_fecha)
	select distinct crc_fecha_cierre from bvq_backoffice.creditos_cartera

	--Proceso principal
	truncate table [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA_2]
	insert into [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA_2](
		 total
		,fecha_vencimiento
		,id_cuenta
		,pagada
		,id_rubro
		,saldo
		,id_estado
		,valor_pactado
		,fecha_corte
		,tasa
		,plazo
		,producto
		,segmento
		,por_codigo
	)
	select 
		 total=sum(total)
		,fecha_vencimiento=convert(date,cut.fecha_vencimiento)
		,id_cuenta=max(crc_id_cuenta)
		,max(convert(int,cut.pagada)) as pagada
		,max(cut.id_rubro) as id_rubro
		,sum(case when cut.id_rubro = 'K' then round(cut.total,2)-round(cut.abono,2) end) as saldo
		,'V' as id_estado
		,sum(case when cut.id_rubro='I' then cut.valor_pactado end) as valor_pactado
		,fecha_corte=crc_fecha_cierre--@i_fecha_corte
		,tasa=max(cr.crc_tasa)--null
		,plazo=datediff(d,crc_fecha_cierre,crc_fecha_vencimiento)/360
		,producto=max(crc_id_producto)
		,segmento=max(cr.CRC_SEGMENTO)
		,por_codigo=max(fh.por_codigo)
	from	bvq_backoffice.credito_cartera_cuota_full cut
	join bvq_backoffice.fechas_cierre_creditos_cartera fcrc on fcrc_fecha>='20260131'
	join bvq_backoffice.creditos_cartera cr on cut.id_credito=cr.crc_numero_operacion and crc_fecha_cierre=fcrc_fecha-- and DATEDIFF(M, @i_fecha_corte, CRC_FECHA_CIERRE) = 0
		and cut.fecha_vencimiento>fcrc_fecha
		and cr.crc_fecha_otorgamiento<=fcrc_fecha
	join bvq_backoffice.fondo_homologacion fh on fh.id_cuenta=cut.id_cuenta
	group by crc_fecha_cierre
	, cut.fecha_vencimiento
	, cr.crc_tasa
	, datediff(d,crc_fecha_cierre,crc_fecha_vencimiento)/360
	, crc_id_cuenta
	--Fin proceso principal

	--Fin cargar en tabla de cubo----------------------------------------------------------------------

end
