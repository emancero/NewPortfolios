CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerTasaInternaRetornoIsspol]
    @i_fecha_corte DATE,
    @i_lga_id      INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * FROM
    (
        SELECT
            '' AS POR_CODIGO,
            DATEDIFF(M, @i_fecha_corte, fecha_vencimiento) AS mes,
            DATEDIFF(M, @i_fecha_corte, fecha_vencimiento) / 12.0 AS exponente,
            ISNULL(SUM(saldo), 0) AS recuperacion_capital,
            ISNULL(SUM(valor_pactado), 0) AS recuperacion_interes,
            SUM(ISNULL(saldo, 0) + ISNULL(valor_pactado, 0)) AS recuperacion_total, -- COEFICIENTE
            SUM((ISNULL(saldo, 0) + ISNULL(valor_pactado, 0)) / POWER(1.08, DATEDIFF(M, @i_fecha_corte, fecha_vencimiento) / 12.0)) AS valor_presente
        FROM [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA]
        GROUP BY DATEDIFF(M, @i_fecha_corte, fecha_vencimiento)

        UNION

        SELECT
            '' AS POR_CODIGO,
            DATEDIFF(M, @i_fecha_corte, CRC_FECHA_CIERRE) AS mes,
            1 AS exponente,
            NULL AS recuperacion_capital,
            NULL AS recuperacion_interes,
            -SUM(CRC_SALDO_PRESTAMO) AS recuperacion_total,
            -SUM(CRC_SALDO_PRESTAMO) AS valor_presente
        FROM BVQ_BACKOFFICE.CREDITOS_CARTERA
        WHERE DATEDIFF(M, @i_fecha_corte, CRC_FECHA_CIERRE) = 0
        GROUP BY CRC_FECHA_CIERRE
    ) AS t
    ORDER BY mes
END
GO