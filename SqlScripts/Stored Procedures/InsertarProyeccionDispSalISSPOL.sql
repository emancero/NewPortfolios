CREATE PROCEDURE [BVQ_BACKOFFICE].[InsertarProyeccionDispSalISSPOL]
    @i_pdc_id INT,
    @i_portafolio VARCHAR(200),
    @i_fecha DATE,
    @i_saldo_final MONEY,
    @i_lga_id INT
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO [BVQ_BACKOFFICE].[ISSPOL_PROYECCION_DISP_SAL]
        (PDS_PDC_ID, PDS_PORTAFOLIO, PDS_FECHA, PDS_SALDO_FINAL)
    VALUES
        (@i_pdc_id, @i_portafolio, @i_fecha, @i_saldo_final)
END
