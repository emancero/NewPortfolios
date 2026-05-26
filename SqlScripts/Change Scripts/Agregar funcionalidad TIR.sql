-- =============================================
-- Inserta funcionalidad: Tasa Interna de Retorno (ISSPOL_TIR)
-- Padre: CREDITOS_ISSPOL
-- =============================================

DECLARE @IdFunc  INT;
DECLARE @IdPadre INT;

-- Obtiene el FUN_ID del padre por su FUN_CODIGO
SET @IdPadre = (SELECT FUN_ID FROM BVQ_SEGURIDAD.FUNCIONALIDAD WHERE FUN_CODIGO = 'CREDITOS_ISSPOL');

IF NOT EXISTS (SELECT 1 FROM BVQ_SEGURIDAD.FUNCIONALIDAD WHERE FUN_CODIGO = 'ISSPOL_TIR')
BEGIN
    SET @IdFunc = ISNULL((SELECT MAX(FUN_ID) FROM BVQ_SEGURIDAD.FUNCIONALIDAD), 0) + 1;

    INSERT INTO BVQ_SEGURIDAD.FUNCIONALIDAD
        (FUN_ID, MOD_ID, FUN_NOMBRE, FUN_TIPO, FUN_CODIGO, FUN_ESTADO,
         FUN_NOMBRE_DLL, FUN_NOMBRE_CLASE, FUN_PADRE, FUN_AUDITAR, FUN_ORDEN, FUN_ES_VERSION2)
    VALUES
        (@IdFunc,
         4,                                                  -- MOD_ID
         N'Tasa Interna de Retorno',                         -- FUN_NOMBRE
         89,                                                 -- FUN_TIPO
         'ISSPOL_TIR',                                       -- FUN_CODIGO
         82,                                                 -- FUN_ESTADO
         'Bvq.Sipla.Isspol.Module.dll',                      -- FUN_NOMBRE_DLL
         'Bvq.Sipla.Isspol.Module.TasaInternaRetornoView',   -- FUN_NOMBRE_CLASE
         @IdPadre,                                           -- FUN_PADRE (CREDITOS_ISSPOL)
         1,                                                  -- FUN_AUDITAR
         1,                                                  -- FUN_ORDEN
         NULL);                                              -- FUN_ES_VERSION2
END
ELSE
BEGIN
    SET @IdFunc = (SELECT FUN_ID FROM BVQ_SEGURIDAD.FUNCIONALIDAD WHERE FUN_CODIGO = 'ISSPOL_TIR');
END

-- =============================================
-- Asigna al Perfil 41
-- =============================================
IF NOT EXISTS (
    SELECT 1 FROM BVQ_SEGURIDAD.PERFIL_FUNCIONALIDAD
    WHERE PRF_ID = 41 AND FUN_ID = @IdFunc
)
BEGIN
    INSERT INTO BVQ_SEGURIDAD.PERFIL_FUNCIONALIDAD (PRF_ID, FUN_ID)
    VALUES (41, @IdFunc);
END