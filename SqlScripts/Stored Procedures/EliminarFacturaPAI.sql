CREATE PROCEDURE [BVQ_BACKOFFICE].[EliminarFacturaPAI]
    @i_paf_id  INT,
    @i_lga_id  INT
AS
BEGIN
    SET NOCOUNT ON;

    EXEC [BVQ_SEGURIDAD].[RegistrarAuditoria]
        @i_lga_id = @i_lga_id,
        @i_tabla = N'PAI_FACTURA',
        @i_esquema = N'BVQ_BACKOFFICE',
        @i_operacion = N'D',
        @i_subTipo = N'A',
        @i_columIdName = N'PAF_ID',
        @i_idAfectado = @i_paf_id;

    DELETE FROM BVQ_BACKOFFICE.PAI_FACTURA
    WHERE PAF_ID = @i_paf_id;
END
