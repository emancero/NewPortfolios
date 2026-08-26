DECLARE @CatIdMail INT;
DECLARE @EstadoActivo INT;
--DECLARE @Correos VARCHAR(MAX) = 'emancero@bolsadequito.com; ddavebet@gmail.com;';
DECLARE @Correos VARCHAR(MAX) = 'emancero@bolsadequito.com; mchuquicondor@isspol.org.ec; atapia@isspol.org.ec; rjaneta@isspol.org.ec; jvelez@isspol.org.ec; palcivar@isspol.org.ec; mtorresa@isspol.org.ec; ecorrea@isspol.org.ec; maherrera@isspol.org.ec; lcondolo@isspol.org.ec';

-- 1. Obtener el valor numérico del estado 'ACTIVO' (código 'A') desde el catálogo 'GENSTATUS'
SELECT @EstadoActivo = it.ITC_ID
FROM BVQ_ADMINISTRACION.ITEM_CATALOGO it
INNER JOIN BVQ_ADMINISTRACION.CATALOGO cat ON it.CAT_ID = cat.CAT_ID
WHERE cat.CAT_CODIGO = 'GENSTATUS'
  AND it.ITC_CODIGO = 'A';

-- 2. Crear el catálogo 'MAIL_VEN_ISSPOL' solo si no existe (NO borrar/recrear: rompe el CAT_ID
--    de los items hijos ya insertados y puede violar la FK con ITEM_CATALOGO)
IF NOT EXISTS (SELECT 1 FROM BVQ_ADMINISTRACION.CATALOGO WHERE CAT_CODIGO = 'MAIL_VEN_ISSPOL')
BEGIN
    INSERT INTO BVQ_ADMINISTRACION.CATALOGO
        ([CAT_PADRE_ID],[CAT_NOMBRE],[CAT_CODIGO],[CAT_DESCRIPCION],[CAT_ESTADO],[CAT_VALOR_DEFECTO])
    VALUES
        (NULL
        ,'Mail Vencimiento Isspol'
        ,'MAIL_VEN_ISSPOL'
        ,'Mail para notificar sobre vencimientos de títulos'
        ,@EstadoActivo
        ,NULL);
END

-- 3. Obtener el ID del catálogo 'MAIL_VEN_ISSPOL' por su código
SELECT @CatIdMail = CAT_ID
FROM BVQ_ADMINISTRACION.CATALOGO
WHERE CAT_CODIGO = 'MAIL_VEN_ISSPOL';

IF @CatIdMail IS NULL
BEGIN
    RAISERROR('No se encontró el catálogo MAIL_VEN_ISSPOL.', 16, 1);
    RETURN;
END

-- 4. Eliminar todos los MVI_TO existentes, para volver a insertarlos limpios
DELETE FROM BVQ_ADMINISTRACION.ITEM_CATALOGO
WHERE CAT_ID = @CatIdMail
  AND ITC_CODIGO = 'MVI_TO';

-- 5. Insertar un registro POR CADA correo (separados por ';' en @Correos)
INSERT INTO BVQ_ADMINISTRACION.ITEM_CATALOGO (
    CAT_ID,
    ITC_PADRE_ID,
    ITC_DESCRIPCION,
    ITC_NOMBRE,
    ITC_CODIGO,
    ITC_VALOR,
    ITC_ESTADO,
    ITC_FECHA_CREACION,
    ITC_EDITABLE,
    ITC_ORDEN,
    ITC_CODIGO_SIC,
    ITC_CODIGO_SUBCUENTA,
    ITC_CODIGO_SPI,
    ITC_VALOR_DECEVALE,
    ITC_SWIFT,
    ITC_CODIGO_ABA
)
SELECT
    @CatIdMail,
    NULL,
    'Correo de destino (TO) para notificación de vencimientos de títulos',
    'Correo destino',
    'MVI_TO',
    LTRIM(RTRIM(s.val)),
    @EstadoActivo,
    GETDATE(),
    1,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL   -- ITC_ORDEN, ITC_CODIGO_SIC, ITC_CODIGO_SUBCUENTA, ITC_CODIGO_SPI, ITC_VALOR_DECEVALE, ITC_SWIFT, ITC_CODIGO_ABA (7 columnas, no 6)
FROM dbo.fnSplitString(@Correos, ';') s
WHERE LTRIM(RTRIM(s.val)) <> '';

-- Verificación
SELECT ITC_ID, ITC_CODIGO, ITC_VALOR
FROM BVQ_ADMINISTRACION.ITEM_CATALOGO
WHERE CAT_ID = @CatIdMail AND ITC_CODIGO = 'MVI_TO'
ORDER BY ITC_ID;

