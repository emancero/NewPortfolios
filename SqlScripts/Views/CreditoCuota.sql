create view [BVQ_BACKOFFICE].[CreditoCuota] as
    SELECT
        '' AS POR_CODIGO,
        datediff(m,fecha_corte,cut.fecha_vencimiento) mes,
        datediff(m,fecha_corte,cut.fecha_vencimiento) / 12.0 AS exponente,
        saldo AS recuperacion_capital,
        valor_pactado AS recuperacion_interes,
        ISNULL(saldo, 0) + ISNULL(valor_pactado, 0) AS recuperacion_total,
        0.0 AS valor_presente,
        tasa,
        plazo= right('    '+rtrim(datediff(d,fecha_corte,fecha_vencimiento_credito)/360*360),5) +' a '+right('    '+rtrim((datediff(d,fecha_corte,fecha_vencimiento_credito) / 360 + 1)*360),5),
        producto,
        fondo
    --into #x
    --select count(*)
    FROM [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA_2] cut
    where tasa is not null
