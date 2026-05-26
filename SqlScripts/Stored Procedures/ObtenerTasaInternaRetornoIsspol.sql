CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerTasaInternaRetornoIsspol]
    @i_fecha_corte DATE,
    @i_lga_id      INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        POR_CODIGO,
        DATEDIFF(M, @i_fecha_corte, fecha_vencimiento)                  AS mes,
        ISNULL(saldo, 0)                                                AS recuperacion_capital,
        ISNULL(valor_pactado, 0)                                        AS recuperacion_interes,
        ISNULL(saldo, 0) + ISNULL(valor_pactado, 0)                     AS recuperacion_total,
        (ISNULL(saldo, 0) + ISNULL(valor_pactado, 0))
            / POWER(1.08, DATEDIFF(M, @i_fecha_corte, fecha_vencimiento) / 12.0) AS valor_presente
    FROM [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA];
END