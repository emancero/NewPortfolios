CREATE PROCEDURE [BVQ_BACKOFFICE].[GuardarCodigoPrestablecidoPAI]
    @i_tipo    VARCHAR(20),
    @i_nombre  VARCHAR(200),
    @i_codigo  VARCHAR(50),
    @i_lga_id  INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO
        WHERE PCP_TIPO = @i_tipo AND PCP_NOMBRE = @i_nombre
    )
        UPDATE BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO
        SET PCP_CODIGO = @i_codigo
        WHERE PCP_TIPO = @i_tipo AND PCP_NOMBRE = @i_nombre;
    ELSE
        INSERT INTO BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO (PCP_TIPO, PCP_NOMBRE, PCP_CODIGO)
        VALUES (@i_tipo, @i_nombre, @i_codigo);
END
