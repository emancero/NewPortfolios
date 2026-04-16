CREATE PROCEDURE BVQ_ADMINISTRACION.ObtenerFirmasPorFecha
    @fecha DATE,
	@i_lga_id int
AS
BEGIN
    SET NOCOUNT ON;

    WITH FirmasConRango AS (
        SELECT 
            ISNULL(
                LEAD(FIR_FECHA_VINCULACION) 
                OVER (PARTITION BY FIR_CARGO ORDER BY FIR_FECHA_VINCULACION ASC),
                '99991231'
            ) AS FIR_FECHA_HASTA,
            *
        FROM BVQ_ADMINISTRACION.FIRMA
    )
    SELECT *
    FROM FirmasConRango
    WHERE @fecha >= FIR_FECHA_VINCULACION
      AND @fecha <  FIR_FECHA_HASTA;

END