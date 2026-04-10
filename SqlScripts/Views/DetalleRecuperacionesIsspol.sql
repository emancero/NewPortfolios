ALTER VIEW BVQ_BACKOFFICE.DetalleRecuperacionesIsspol AS
SELECT
    tipo_renta,
    sector,
    tvl_nombre,
    fecha_compra,
    fecha_vencimiento,
    nombre,
    saldo_valor_nominal,
    rendimiento,
    plazo_cupon,
    capital,
    iamortizacion,
    prov,
    fecha_pago,
    fecha_de_vencimiento_flujo,
    vencimiento_feriado = CASE
        WHEN DATEPART(WEEKDAY, fecha_de_vencimiento_flujo) IN (1, 7) THEN 1
        WHEN EXISTS (
            SELECT 1 FROM bvq_backoffice.dia_feriado df
            WHERE fecha_de_vencimiento_flujo BETWEEN df.dfe_fecha_inicio AND df.dfe_fecha_fin
        ) THEN 1
        ELSE 0
    END,
    acciones_judiciales,
    primer_nivel,
    tipo_flujo,
    EMS_NOMBRE,
    tpo_numeracion,
    oper,
    fecha_pago AS fecha,
    tiv_id,
    deterioro
FROM (
    SELECT
        tipo_renta,
        MAX(sector) AS sector,
        tvl_nombre,
        MAX(fecha_compra) AS fecha_compra,
        MAX(fecha_vencimiento) AS fecha_vencimiento,
        MAX(nombre) AS nombre,
        SUM(saldo_valor_nominal) AS saldo_valor_nominal,
        NULL AS rendimiento,
        MAX(plazo_cupon) AS plazo_cupon,
        SUM(capital) AS capital,
        SUM(iamortizacion) AS iamortizacion,
        SUM(prov) AS prov,
        fecha_pago,
        MAX(fecha_de_vencimiento_flujo) AS fecha_de_vencimiento_flujo,
        acciones_judiciales,
        MAX(primer_nivel) AS primer_nivel,
        MAX(tipo_flujo) AS tipo_flujo,
        EMS_NOMBRE,
        tpo_numeracion,
        oper,
        MAX(deterioro) AS deterioro,
        tiv_id
    FROM
        BVQ_BACKOFFICE.DetalleRecuperacionesIsspolFondos
    GROUP BY
        tipo_renta,
        tvl_nombre,
        EMS_NOMBRE,
        tpo_numeracion,
        oper,
        fecha_pago,
        tiv_id,
        acciones_judiciales
) q