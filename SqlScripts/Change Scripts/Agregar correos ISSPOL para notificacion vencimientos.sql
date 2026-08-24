DECLARE @CatIdMail INT;
DECLARE @EstadoActivo INT;
--DECLARE @Correos VARCHAR(MAX) = 'ddavebet@gmail.com; emancero@bolsadequito.com';
DECLARE @Correos VARCHAR(MAX) = 'jsilva@isspol.org.ec; rjaneta@isspol.org.ec; jvelez@isspol.org.ec; palcivar@isspol.org.ec; mtorresa@isspol.org.ec; ecorrea@isspol.org.ec; maherrera@isspol.org.ec; lcondolo@isspol.org.ec'; 

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

-- 4. Eliminar el ítem MLVI_TO si ya existía, para volver a insertarlo limpio
DELETE FROM BVQ_ADMINISTRACION.ITEM_CATALOGO
WHERE CAT_ID = @CatIdMail
  AND ITC_CODIGO = 'MVI_TO';

-- 5. Insertar el ítem con los correos de destino
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
VALUES (
    @CatIdMail,
    NULL,
    'Correo(s) de destino (TO) para notificación de vencimientos de títulos (separar múltiples direcciones con ;)',
    'Correo destino',
    'MVI_TO',
    @Correos,
    @EstadoActivo,
    GETDATE(),
    1,
    NULL, NULL, NULL, NULL, NULL, NULL, NULL
);
