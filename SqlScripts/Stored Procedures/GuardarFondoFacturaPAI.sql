CREATE PROCEDURE [BVQ_BACKOFFICE].[GuardarFondoFacturaPAI]
    @i_paf_id  INT,
    @i_por_id  INT,
    @i_monto   FLOAT,
    @i_lga_id  INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_pff_id INT;

    INSERT INTO BVQ_BACKOFFICE.PAI_FACTURA_FONDO (PAF_ID, POR_ID, PFF_MONTO)
    VALUES (@i_paf_id, @i_por_id, @i_monto);

    SET @v_pff_id = SCOPE_IDENTITY();

    EXEC [BVQ_SEGURIDAD].[RegistrarAuditoria]
        @i_lga_id = @i_lga_id,
        @i_tabla = N'PAI_FACTURA_FONDO',
        @i_esquema = N'BVQ_BACKOFFICE',
        @i_operacion = N'I',
        @i_subTipo = N'N',
        @i_columIdName = N'PFF_ID',
        @i_idAfectado = @v_pff_id;
END
