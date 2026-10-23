CREATE PROCEDURE [BVQ_BACKOFFICE].[GuardarFacturaPAI]
    @i_paf_id         INT,
    @i_pfc_id         INT,
    @i_pfc_nombre     VARCHAR(200) = NULL,
    @i_fecha_factura  DATE,
    @i_fecha_corte    DATE = NULL,
    @i_monto          FLOAT,
    @i_lga_id         INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_paf_id INT;

    SET @i_pfc_nombre = LTRIM(RTRIM(@i_pfc_nombre));

    IF ISNULL(@i_pfc_id, 0) = 0 AND ISNULL(@i_pfc_nombre, '') <> ''
    BEGIN
        SELECT @i_pfc_id = PFC_ID
        FROM BVQ_BACKOFFICE.PAI_FACTURA_CUSTODIO
        WHERE LTRIM(RTRIM(PFC_NOMBRE)) = @i_pfc_nombre;

        IF ISNULL(@i_pfc_id, 0) = 0
        BEGIN
            INSERT INTO BVQ_BACKOFFICE.PAI_FACTURA_CUSTODIO (PFC_NOMBRE)
            VALUES (@i_pfc_nombre);

            SET @i_pfc_id = SCOPE_IDENTITY();

            EXEC [BVQ_SEGURIDAD].[RegistrarAuditoria]
                @i_lga_id = @i_lga_id,
                @i_tabla = N'PAI_FACTURA_CUSTODIO',
                @i_esquema = N'BVQ_BACKOFFICE',
                @i_operacion = N'I',
                @i_subTipo = N'N',
                @i_columIdName = N'PFC_ID',
                @i_idAfectado = @i_pfc_id;
        END
    END

    IF EXISTS (SELECT 1 FROM BVQ_BACKOFFICE.PAI_FACTURA WHERE PAF_ID = @i_paf_id)
    BEGIN
        SET @v_paf_id = @i_paf_id;

        EXEC [BVQ_SEGURIDAD].[RegistrarAuditoria]
            @i_lga_id = @i_lga_id,
            @i_tabla = N'PAI_FACTURA',
            @i_esquema = N'BVQ_BACKOFFICE',
            @i_operacion = N'U',
            @i_subTipo = N'A',
            @i_columIdName = N'PAF_ID',
            @i_idAfectado = @i_paf_id;

        UPDATE BVQ_BACKOFFICE.PAI_FACTURA
        SET PFC_ID = @i_pfc_id,
            PAF_FECHA_FACTURA = @i_fecha_factura,
            PAF_FECHA_CORTE = @i_fecha_corte,
            PAF_MONTO = @i_monto
        WHERE PAF_ID = @i_paf_id;

        EXEC [BVQ_SEGURIDAD].[RegistrarAuditoria]
            @i_lga_id = @i_lga_id,
            @i_tabla = N'PAI_FACTURA',
            @i_esquema = N'BVQ_BACKOFFICE',
            @i_operacion = N'U',
            @i_subTipo = N'N',
            @i_columIdName = N'PAF_ID',
            @i_idAfectado = @i_paf_id;
    END
    ELSE
    BEGIN
        INSERT INTO BVQ_BACKOFFICE.PAI_FACTURA (PFC_ID, PAF_FECHA_FACTURA, PAF_FECHA_CORTE, PAF_MONTO)
        VALUES (@i_pfc_id, @i_fecha_factura, @i_fecha_corte, @i_monto);

        SET @v_paf_id = SCOPE_IDENTITY();

        EXEC [BVQ_SEGURIDAD].[RegistrarAuditoria]
            @i_lga_id = @i_lga_id,
            @i_tabla = N'PAI_FACTURA',
            @i_esquema = N'BVQ_BACKOFFICE',
            @i_operacion = N'I',
            @i_subTipo = N'N',
            @i_columIdName = N'PAF_ID',
            @i_idAfectado = @v_paf_id;
    END

    -- PAF_ID guardado, para registrar los montos por fondo (PAI_FACTURA_FONDO)
    SELECT @v_paf_id AS PAF_ID;
END
