CREATE PROCEDURE BVQ_BACKOFFICE.ObtenerPerdidaEsperadaTIR
    @FechaCierre DATE,
    @i_lga_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SaldoMora FLOAT;
    DECLARE @SaldoTotal FLOAT;

    SELECT @SaldoMora = SUM(CRC_SALDO_PRESTAMO)
    FROM bvq_backoffice.creditos_cartera
    WHERE CRC_FECHA_CIERRE = @FechaCierre
      AND dias_morosidad >= 30;

    SELECT @SaldoTotal = SUM(CRC_SALDO_PRESTAMO)
    FROM BVQ_BACKOFFICE.CREDITOS_CARTERA
    WHERE CRC_FECHA_CIERRE = @FechaCierre;

    SELECT
        @FechaCierre AS FechaCierre,
        ISNULL(@SaldoMora, 0) AS SaldoMora,
        ISNULL(@SaldoTotal, 0) AS SaldoTotal,
        CASE 
            WHEN ISNULL(@SaldoTotal, 0) = 0 THEN NULL
            ELSE ISNULL(@SaldoMora, 0) / @SaldoTotal
        END AS PerdidaEsperada
    FROM (SELECT 1 AS aux) x;
END