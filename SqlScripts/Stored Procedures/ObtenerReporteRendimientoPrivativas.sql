CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerReporteRendimientoPrivativas]
	@i_fecha_fin DATETIME = '20250909',
	@i_usar_mora BIT = 0,
	@i_lga_id INT = NULL
AS
BEGIN
    DECLARE @v_fecha_cierre DATE = (
        SELECT MAX(crc_fecha_cierre)
        FROM bvq_backoffice.creditos_cartera
        WHERE DATEDIFF(m, crc_fecha_cierre, @i_fecha_fin) >= 0
    )

    IF @i_usar_mora = 1
        SELECT *
        FROM bvq_backoffice.ReporteRendimientoPrivativasMora
        WHERE crc_fecha_cierre = @v_fecha_cierre
        ORDER BY rpp
    ELSE
        SELECT *
        FROM bvq_backoffice.ReporteRendimientoPrivativas
        WHERE crc_fecha_cierre = @v_fecha_cierre
        ORDER BY rpp
END
