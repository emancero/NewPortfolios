CREATE PROCEDURE [BVQ_BACKOFFICE].[InsertarProyeccionDispCabISSPOL]
    @i_nombre VARCHAR(200),
    @i_fecha_corte DATE,
    @i_fecha_inicio DATE,
    @i_fecha_fin DATE,
    @i_lga_id INT
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO [BVQ_BACKOFFICE].[ISSPOL_PROYECCION_DISP_CAB]
        (PDC_NOMBRE, PDC_FECHA_CORTE, PDC_FECHA_INICIO, PDC_FECHA_FIN)
    VALUES
        (@i_nombre, @i_fecha_corte, @i_fecha_inicio, @i_fecha_fin)

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS PDC_ID
END
