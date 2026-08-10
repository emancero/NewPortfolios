create view [BVQ_BACKOFFICE].[CreditoCuota] as
    SELECT
        id_cuenta,
        datediff(m,fecha_corte,cut.fecha_vencimiento) mes,
        datediff(m,fecha_corte,cut.fecha_vencimiento) / 12.0 AS exponente,
        saldo AS recuperacion_capital,
        valor_pactado AS recuperacion_interes,
        ISNULL(saldo, 0) + ISNULL(valor_pactado, 0) AS recuperacion_total,
        0.0 AS valor_presente,
        tasa,
        plazo= right('    '+rtrim(plazo*360),5) +' a '+right('    '+rtrim((plazo + 1)*360),5),
        producto,
        fecha_corte
    --into #x
    --select count(*)
    FROM [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA_2] cut
    --where tasa is not null
    union all
    select
         id_cuenta
        ,mes=0--fecha_vencimiento=fecha_corte
        ,exponente=0--id_cuenta=max(id_cuenta)
        ,-sum(saldo) as saldo
        ,valor_pactado=null-- -sum(case when cut.id_rubro='I' then cut.valor_pactado end) as valor_pactado --no se utiliza
        ,-sum(saldo) --cut.id_credito--=cr.crc_numero_operacion
        ,0.0--id_numero_cuota=null
        ,tasa=tasa--cr.crc_tasa--null
        ,plazo= right('    '+rtrim(plazo*360),5) +' a '+right('    '+rtrim((plazo + 1)*360),5)
        ,producto=max(producto)
        ,fecha_corte
    from bvq_backoffice.credito_cartera_cuota_2 cut
    GROUP BY fecha_corte,tasa,id_cuenta,plazo
    --,id_credito--crc_numero_operacion--,CRC_FECHA_CIERRE
