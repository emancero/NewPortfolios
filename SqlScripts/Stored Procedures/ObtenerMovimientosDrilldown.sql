-- =============================================
-- SP: ObtenerMovimientosDrilldown
-- Descripcion: Obtiene los movimientos contables filtrados por periodo.
--                - Solo @Año            -> todo el año
--                - @Año + @Mes           -> mes completo
--                - @Año + @Mes + @Dia    -> dia especifico
--              @subtipo y @portafolio son filtros OPCIONALES:
--                - NULL  -> no se filtra por ese campo
--                - ''    -> filtra por el campo IS NULL (ITC_VALOR / ICB_DESCRIPCION)
--                - valor -> filtro exacto de igualdad
-- MODIFICACION: <tu nombre> <fecha> - @subtipo/@portafolio pasan a ser
--               filtros opcionales con distinción NULL vs '' (antes exigían
--               igualdad exacta y el popup quedaba sin resultados si el
--               campo no estaba en el área de columnas/filas del pivot).
-- =============================================
CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerMovimientosDrilldown]
    @portafolio VARCHAR(255) = NULL,
    @subtipo VARCHAR(255) = NULL,
    @anio INT = NULL,
    @mes INT = NULL,
    @dia INT = NULL,
    @i_lga_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @anio IS NULL
    BEGIN
        RAISERROR('Debe especificar @Año (Mes y Dia solo aplican junto con Año).', 16, 1);
        RETURN;
    END

    DECLARE @FechaInicio DATETIME = NULL;
    DECLARE @FechaFin    DATETIME = NULL;

    IF @mes IS NOT NULL AND @dia IS NOT NULL
    BEGIN
        -- año + mes + dia -> dia especifico
        SET @FechaInicio = CONVERT(DATETIME,
            CAST(@anio AS VARCHAR(4)) + '-' +
            RIGHT('0' + CAST(@mes AS VARCHAR(2)), 2) + '-' +
            RIGHT('0' + CAST(@dia AS VARCHAR(2)), 2), 120);
        SET @FechaFin = DATEADD(DAY, 1, @FechaInicio);
    END
    ELSE IF @mes IS NOT NULL
    BEGIN
        -- año + mes -> mes completo
        SET @FechaInicio = CONVERT(DATETIME,
            CAST(@anio AS VARCHAR(4)) + '-' +
            RIGHT('0' + CAST(@mes AS VARCHAR(2)), 2) + '-01', 120);
        SET @FechaFin = DATEADD(MONTH, 1, @FechaInicio);
    END
    ELSE
    BEGIN
        -- solo año -> año completo
        SET @FechaInicio = CONVERT(DATETIME, CAST(@anio AS VARCHAR(4)) + '-01-01', 120);
        SET @FechaFin = DATEADD(YEAR, 1, @FechaInicio);
    END

    SELECT 
        MOV_FECHA, MOV_CONCEPTO, MOV_BENEFICIARIO, MOV_REFERENCIA_ASIENTO, 
        MOV_COMPROBANTE, ISNULL(MOV_DEBE, 0) - ISNULL(MOV_HABER, 0) AS MOV_MONTO, 
        MOV_CUENTA_CONTABLE_NOMBRE,
        ITC_VALOR
    FROM [_temp].[isspol_movimiento_contable_fuente] m
        LEFT JOIN BVQ_ADMINISTRACION.ITEM_CATALOGO itc ON m.mov_subtipo = itc.ITC_ID
        LEFT JOIN BVQ_BACKOFFICE.isspol_cuentas_contables_de_bancos ccb ON m.MOV_CUENTA_CONTABLE = ccb.ICB_CUENTA
    WHERE MOV_FECHA >= @FechaInicio AND MOV_FECHA < @FechaFin
        AND (
            @subtipo IS NULL
            OR (@subtipo = '' AND itc.ITC_VALOR IS NULL)
            OR (@subtipo <> '' AND itc.ITC_VALOR = @subtipo)
        )
        AND (
            @portafolio IS NULL
            OR (@portafolio = '' AND ICB_DESCRIPCION IS NULL)
            OR (@portafolio <> '' AND ICB_DESCRIPCION = @portafolio)
        )
    ORDER BY MOV_FECHA;
END

-- =============================================
-- Ejemplos de uso
-- =============================================
-- Todo el año 2026:
 --EXEC BVQ_BACKOFFICE.ObtenerMovimientosDrilldown 
 --@subtipo = 'CONCESIÓN PRIVATIVAS', @anio = 2026;

-- Agosto 2026 completo:
 --EXEC BVQ_BACKOFFICE.ObtenerMovimientosDrilldown 
 --@subtipo = 'CONCESIÓN PRIVATIVAS', @anio = 2026, @mes = 8;

-- Dia 10 de agosto de 2026:
-- EXEC BVQ_BACKOFFICE.ObtenerMovimientosDrilldown 
-- @subtipo = 'CONCESIÓN PRIVATIVAS', @anio = 2026, @mes = 8, @dia = 10;