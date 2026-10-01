CREATE PROCEDURE [BVQ_BACKOFFICE].[InsertarProyeccionDispDetISSPOL]
    @i_pdc_id INT,
    @i_fecha_vencimiento DATE,
    @i_portafolio VARCHAR(200) = NULL,
    @i_subtipo VARCHAR(200) = NULL,
    @i_tipo_papel VARCHAR(200) = NULL,
    @i_ie VARCHAR(20)  = NULL,
    @i_monto MONEY,
    @i_lga_id INT
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO [BVQ_BACKOFFICE].[ISSPOL_PROYECCION_DISP_DET]
        (PDD_PDC_ID, PDD_FECHA_VENCIMIENTO, PDD_PORTAFOLIO, PDD_SUBTIPO,
         PDD_TIPO_PAPEL, PDD_IE, PDD_MONTO)
    VALUES
        (@i_pdc_id, @i_fecha_vencimiento, @i_portafolio, @i_subtipo,
         @i_tipo_papel, @i_ie, @i_monto)
END
