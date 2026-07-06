CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerCreditosCarteraCuotaISSPOL]
    @i_fechaCorte DATE,
    @i_portafolio NVARCHAR(200) = NULL,
    @i_anio INT = NULL,
    @i_mes INT = NULL,
    @i_dia INT = NULL,
    @i_segmento VARCHAR(200) = NULL,
    @i_producto VARCHAR(200) = NULL,
    @i_tasa FLOAT = NULL,
    @i_id_rubro VARCHAR(200) = NULL,
    @i_estado CHAR(10) = NULL,
    @i_lga_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        ccc.id_credito,
        ccc.por_codigo,
        ccc.fecha_vencimiento,
        cupon=sum(round(ccc.total,2)-round(ccc.abono,2))+sum(case when datediff(d,@i_fechaFin,ccc.fecha_pago)>=1 then ccc.abono else 0 end)
    FROM [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA] ccc
    WHERE
        ccc.total > 0.05
        AND DATEDIFF(d, @i_fechaCorte, ccc.fecha_vencimiento) >= 1
        AND (@i_portafolio IS NULL OR ccc.por_codigo = @i_portafolio)
        AND (@i_anio IS NULL OR YEAR(ccc.fecha_vencimiento) = @i_anio)
        AND (@i_mes IS NULL OR MONTH(ccc.fecha_vencimiento) = @i_mes)
        AND (@i_dia IS NULL OR DAY(ccc.fecha_vencimiento) = @i_dia)
        AND (@i_segmento IS NULL OR ccc.segmento = @i_segmento)
        AND (@i_producto IS NULL OR ccc.producto = @i_producto)
        AND (@i_tasa IS NULL OR ccc.tasa = @i_tasa)
        AND (@i_id_rubro IS NULL OR ccc.id_rubro = @i_id_rubro)
        AND (@i_estado IS NULL OR ccc.estado = @i_estado)
    GROUP BY
        ccc.id_credito,
        ccc.por_codigo,
        CONVERT(DATE, ccc.fecha_vencimiento)
END