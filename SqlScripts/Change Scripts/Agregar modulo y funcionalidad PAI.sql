-- =============================================
-- Inserta Módulo PAI y Liquidez solo si no existe
-- =============================================
IF NOT EXISTS (
    SELECT 1
    FROM BVQ_SEGURIDAD.MODULO
    WHERE MOD_ID = 7
)
BEGIN
    INSERT INTO BVQ_SEGURIDAD.MODULO
        (MOD_ID, MOD_DESCRIPCION, MOD_NOMBRE, MOD_CODIGO, MOD_ESTADO)
    VALUES
        (7, N'Módulo PAI y Liquidez', N'PAI', '^PAI', 'A');
END

-- =============================================
-- Inserta Funcionalidades del Módulo PAI y Liquidez
-- (IDs calculados dinámicamente desde MAX(FUN_ID) + 1)
-- =============================================

DECLARE @NextId INT;
DECLARE @IdPAI INT;
DECLARE @IdPlan INT;

SET @NextId = ISNULL((SELECT MAX(FUN_ID) FROM BVQ_SEGURIDAD.FUNCIONALIDAD), 0) + 1;

-- PAI (nodo padre)
IF NOT EXISTS (SELECT 1 FROM BVQ_SEGURIDAD.FUNCIONALIDAD WHERE FUN_CODIGO = 'PAI_ISSPOL')
BEGIN
    SET @IdPAI = @NextId;

    INSERT INTO BVQ_SEGURIDAD.FUNCIONALIDAD
        (FUN_ID, MOD_ID, FUN_NOMBRE, FUN_TIPO, FUN_CODIGO, FUN_ESTADO,
         FUN_NOMBRE_DLL, FUN_NOMBRE_CLASE, FUN_PADRE, FUN_AUDITAR, FUN_ORDEN, FUN_ES_VERSION2)
    VALUES
        (@IdPAI, 7, N'PAI', 88, 'PAI_ISSPOL', 82, NULL, NULL, NULL, 1, 86, NULL);

    SET @NextId = @NextId + 1;
END
ELSE
BEGIN
    SET @IdPAI = (SELECT FUN_ID FROM BVQ_SEGURIDAD.FUNCIONALIDAD WHERE FUN_CODIGO = 'PAI_ISSPOL');
END

-- Plan anual de inversión
IF NOT EXISTS (SELECT 1 FROM BVQ_SEGURIDAD.FUNCIONALIDAD WHERE FUN_CODIGO = 'PAI_PLAN')
BEGIN
    SET @IdPlan = @NextId;

    INSERT INTO BVQ_SEGURIDAD.FUNCIONALIDAD
        (FUN_ID, MOD_ID, FUN_NOMBRE, FUN_TIPO, FUN_CODIGO, FUN_ESTADO,
         FUN_NOMBRE_DLL, FUN_NOMBRE_CLASE, FUN_PADRE, FUN_AUDITAR, FUN_ORDEN, FUN_ES_VERSION2)
    VALUES
        (@IdPlan, 7, N'Plan anual de inversión', 89, 'PAI_PLAN', 82,
         'Bvq.Sipla.Isspol.Module.dll', 'Bvq.Sipla.Isspol.Module.AnnualInvestmentPlanView', @IdPAI, 1, 1, NULL);

    SET @NextId = @NextId + 1;
END
ELSE
BEGIN
    SET @IdPlan = (SELECT FUN_ID FROM BVQ_SEGURIDAD.FUNCIONALIDAD WHERE FUN_CODIGO = 'PAI_PLAN');
END

-- =============================================
-- Inserta Perfil-Funcionalidad (Perfil 41 → Funcionalidades de PAI)
-- (usa los IDs recién generados o los existentes)
-- =============================================

-- Perfil 41 / PAI (nodo padre)
IF NOT EXISTS (SELECT 1 FROM BVQ_SEGURIDAD.PERFIL_FUNCIONALIDAD WHERE PRF_ID = 41 AND FUN_ID = @IdPAI)
BEGIN
    INSERT INTO BVQ_SEGURIDAD.PERFIL_FUNCIONALIDAD (PRF_ID, FUN_ID)
    VALUES (41, @IdPAI);
END

-- Perfil 41 / Plan anual de inversión
IF NOT EXISTS (SELECT 1 FROM BVQ_SEGURIDAD.PERFIL_FUNCIONALIDAD WHERE PRF_ID = 41 AND FUN_ID = @IdPlan)
BEGIN
    INSERT INTO BVQ_SEGURIDAD.PERFIL_FUNCIONALIDAD (PRF_ID, FUN_ID)
    VALUES (41, @IdPlan);
END