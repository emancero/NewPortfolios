CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerCreditosCarteraCuotaISSPOL]
    @i_fechaCorte DATE,
    @i_portafolio NVARCHAR(200) = NULL,
    @i_anio INT = NULL,
    @i_mes INT = NULL,
    @i_dia INT = NULL,
    @i_lga_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        ccc.id_credito,
        ccc.por_codigo,
        ccc.fecha_vencimiento,
        cupon = SUM(ccc.total)
    FROM [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA] ccc
    WHERE
        ccc.total > 0.05
        AND DATEDIFF(d, @i_fechaCorte, ccc.fecha_vencimiento) >= 1
        AND (@i_portafolio IS NULL OR ccc.por_codigo = @i_portafolio)
        AND (@i_anio IS NULL OR YEAR(ccc.fecha_vencimiento) = @i_anio)
        AND (@i_mes IS NULL OR MONTH(ccc.fecha_vencimiento) = @i_mes)
        AND (@i_dia IS NULL OR DAY(ccc.fecha_vencimiento) = @i_dia)
    GROUP BY
        ccc.id_credito,
        ccc.por_codigo,
        CONVERT(DATE, ccc.fecha_vencimiento)
END