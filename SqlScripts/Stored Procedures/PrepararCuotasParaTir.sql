    declare @i_fecha_corte date='20260430'
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
        ,id_credito
        ,id_numero_cuota
        ,fecha_corte
        ,tasa
        --,fecha_vencimiento_credito
    )
    select 
		    --b.descripcion as por_codigo
		    --,
                sum(total) as total
		    ,convert(date,cut.fecha_vencimiento) as fecha_vencimiento
		    ,null--cr.id_cuenta
		    ,max(convert(int,cut.pagada)) as pagada
		    ,max(cut.id_rubro) as id_rubro
		    ,sum(case when cut.id_rubro = 'K' then round(cut.total,2)-round(cut.abono,2) end) as saldo
		    ,'V' as id_estado
		    ,sum(case when cut.id_rubro='I' then cut.valor_pactado end) as valor_pactado
            ,cut.id_credito
            ,id_numero_cuota
            ,fecha_corte=@i_fecha_corte
            --,mes=datediff(m,@i_fecha_corte,cut.fecha_vencimiento)
            ,crc_tasa=cr.crc_tasa--null
            --,cr.fecha_vencimiento
    from	bvq_backoffice.credito_cartera_cuota_full cut
            join bvq_backoffice.creditos_cartera cr on cut.id_credito=cr.crc_numero_operacion and DATEDIFF(M, @i_fecha_corte, CRC_FECHA_CIERRE) = 0
		    --join siisspolweb.siisspolweb.credito.credito cr on cr.id_credito=cut.id_credito
		    --join siisspolweb.siisspolweb.banco.cuenta b on b.id_cuenta=cr.id_cuenta
    where cut.fecha_vencimiento>@i_fecha_corte and cr.crc_fecha_otorgamiento<=@i_fecha_corte
    group by cut.id_credito,id_numero_cuota,cut.fecha_vencimiento, cr.crc_tasa--, cr.fecha_vencimiento
    union all
    select
         total=-sum(total)
        ,fecha_vencimiento=@i_fecha_corte
        ,id_cuenta=null
        ,pagada=0
        ,id_rubro=null
        ,-sum(case when cut.id_rubro = 'K' then round(cut.total,2)-round(cut.abono,2) end) as saldo
        ,'V'--max(cr.crc_estado) as id_estado
        ,null-- -sum(case when cut.id_rubro='I' then cut.valor_pactado end) as valor_pactado
        ,id_credito=cr.crc_numero_operacion
        ,id_numero_cuota=null
        ,fecha_corte=@i_fecha_corte
        ,crc_tasa=max(cr.crc_tasa)
        --,crc_fecha_vencimiento=max(cr.crc_fecha_vencimiento)
    from bvq_backoffice.credito_cartera_cuota_full cut
    join bvq_backoffice.creditos_cartera cr on cut.id_credito=cr.crc_numero_operacion
    where cut.fecha_vencimiento>@i_fecha_corte and cr.crc_fecha_otorgamiento<=@i_fecha_corte
    and DATEDIFF(M, @i_fecha_corte, CRC_FECHA_CIERRE) = 0
    GROUP BY crc_numero_operacion,CRC_FECHA_CIERRE