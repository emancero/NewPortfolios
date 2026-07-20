CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerReporteCesionDerechosFiduciarios]
	@fecha_corte DATE,
	@i_lga_id INT
AS
BEGIN
    DELETE FROM corteslist
    INSERT INTO corteslist VALUES (@fecha_corte, 1)
    EXEC bvq_backoffice.obtenerdetalleportafolioconliquidez -1,'19000101',@fecha_corte, NULL, 0, 1, NULL

    SELECT
        pc.ems_nombre AS nombre_fideicomiso,
        COALESCE(pc.valnomCompraAnterior, pc.htp_compra) AS desembolso_recursos,
        pc.tiv_tasa_interes AS rendimiento,
        pc.fecha_compra AS fecha_cesion,
        DATEDIFF(d, pc.fecha_compra, pc.tiv_fecha_vencimiento) AS plazo_recompra,
        pc.tiv_fecha_vencimiento AS fecha_vencimiento,
        CASE WHEN @fecha_corte >= pc.tiv_fecha_vencimiento THEN 'Vencido' ELSE 'Vigente' END AS estado,
        'Un solo pago' AS pagos_capital,
        pc.htp_compra AS capital_renovado,
        det.fecha AS fecha_pago,
        det.capital AS capital_recuperado,
        det.iamortizacion AS intereses_pagados,
        pc.sal AS saldo_recuperar,
        pc.sal AS capital_impago,
        NULL AS interes_impagos,
        pc.sal AS registro_contable,
        pc.sal AS valoracion,
        100.0 AS porcentaje_constitucion,
        pc.por_codigo AS fondo,
        pc.httpo_id
    FROM bvq_backoffice.PortafolioCorte pc
        LEFT JOIN bvq_backoffice.DetalleRecuperacionesIsspolFondos det ON pc.httpo_id = det.htp_tpo_id
    WHERE
        pc.IPR_ES_CXC = 1
        AND pc.tvl_codigo = 'der'
        AND pc.sal > 0
        AND det.fecha_pago <= @fecha_corte
    ORDER BY pc.ems_nombre, pc.fecha_pago
END