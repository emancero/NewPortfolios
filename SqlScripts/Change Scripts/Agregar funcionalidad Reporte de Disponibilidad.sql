-- =============================================
-- Inserta Funcionalidades de Disponibilidad
-- (IDs calculados dinámicamente desde MAX(FUN_ID) + 1)
-- =============================================

DECLARE @NextId INT;
DECLARE @ModuloId INT;
DECLARE @IdPadre INT;

DECLARE @IdDisponibilidad    INT;

-- Créditos (nodo padre)
SET @ModuloId = ISNULL((SELECT MOD_ID FROM BVQ_SEGURIDAD.MODULO WHERE MOD_CODIGO = 'CRED'), 0);
SET @IdPadre = ISNULL((SELECT FUN_ID FROM BVQ_SEGURIDAD.FUNCIONALIDAD WHERE FUN_CODIGO = 'PAI'), 0);

SET @NextId = ISNULL((SELECT MAX(FUN_ID) FROM BVQ_SEGURIDAD.FUNCIONALIDAD), 0) + 1;

-- Disponibilidad
IF NOT EXISTS (SELECT 1 FROM BVQ_SEGURIDAD.FUNCIONALIDAD WHERE FUN_CODIGO = 'ISSPOL_AVAILABILITY')
BEGIN
    SET @IdDisponibilidad = @NextId;
    INSERT INTO BVQ_SEGURIDAD.FUNCIONALIDAD
        (FUN_ID, MOD_ID, FUN_NOMBRE, FUN_TIPO, FUN_CODIGO, FUN_ESTADO,
         FUN_NOMBRE_DLL, FUN_NOMBRE_CLASE, FUN_PADRE, FUN_AUDITAR, FUN_ORDEN, FUN_ES_VERSION2)
    VALUES
        (@IdDisponibilidad, @ModuloId, N'Reporte de disponibilidad', 89, 'ISSPOL_AVAILABILITY', 82,
         'Bvq.Sipla.Isspol.Module.dll', 'Bvq.Sipla.Isspol.Module.AvailabilityReportView', @IdPadre, 1, 1, NULL);
END
ELSE
    SET @IdDisponibilidad = (SELECT FUN_ID FROM BVQ_SEGURIDAD.FUNCIONALIDAD WHERE FUN_CODIGO = 'ISSPOL_AVAILABILITY');

-- =============================================
-- Inserta Perfil-Funcionalidad (Perfil 41 → Funcionalidades de Créditos)
-- (usa los IDs recién generados o los existentes)
-- =============================================

-- Perfil 41 / Cartera de créditos
IF NOT EXISTS (SELECT 1 FROM BVQ_SEGURIDAD.PERFIL_FUNCIONALIDAD WHERE PRF_ID = 41 AND FUN_ID = @IdDisponibilidad)
BEGIN
    INSERT INTO BVQ_SEGURIDAD.PERFIL_FUNCIONALIDAD (PRF_ID, FUN_ID)
    VALUES (41, @IdDisponibilidad);
END