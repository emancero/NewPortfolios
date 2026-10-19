CREATE PROCEDURE [BVQ_BACKOFFICE].[EliminarFondosFacturaPAI]
    @i_paf_id  INT,
    @i_lga_id  INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_pff_id INT;

    DECLARE curFondos CURSOR LOCAL FAST_FORWARD FOR
        SELECT PFF_ID FROM BVQ_BACKOFFICE.PAI_FACTURA_FONDO WHERE PAF_ID = @i_paf_id;

    OPEN curFondos;
    FETCH NEXT FROM curFondos INTO @v_pff_id;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC [BVQ_SEGURIDAD].[RegistrarAuditoria]
            @i_lga_id = @i_lga_id,
            @i_tabla = N'PAI_FACTURA_FONDO',
            @i_esquema = N'BVQ_BACKOFFICE',
            @i_operacion = N'D',
            @i_subTipo = N'A',
            @i_columIdName = N'PFF_ID',
            @i_idAfectado = @v_pff_id;

        FETCH NEXT FROM curFondos INTO @v_pff_id;
    END
    CLOSE curFondos;
    DEALLOCATE curFondos;

    DELETE FROM BVQ_BACKOFFICE.PAI_FACTURA_FONDO
    WHERE PAF_ID = @i_paf_id;
END
