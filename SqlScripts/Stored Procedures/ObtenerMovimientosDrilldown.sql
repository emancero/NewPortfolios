-- =============================================
-- SP: ObtenerMovimientosDrilldown
-- Descripcion: Obtiene los movimientos contables filtrados por periodo.
--                - Solo @Año            -> todo el año
--                - @Año + @Mes           -> mes completo
--                - @Año + @Mes + @Dia    -> dia especifico
-- =============================================
CREATE PROCEDURE BVQ_BACKOFFICE.ObtenerMovimientosDrilldown
    @subtipo VARCHAR(255) = '',
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
        MOV_FECHA, MOV_CONCEPTO, MOV_BENEFICIARIO, MOV_REFERENCIA_ASIENTO, MOV_COMPROBANTE, 
        ITC_NOMBRE
    FROM [_temp].[isspol_movimiento_contable_fuente] m
        LEFT JOIN BVQ_ADMINISTRACION.ITEM_CATALOGO itc ON m.mov_subtipo = itc.ITC_ID
    WHERE MOV_FECHA >= @FechaInicio AND MOV_FECHA < @FechaFin
        AND itc.ITC_NOMBRE = @subtipo
    ORDER BY MOV_FECHA;
END
GO

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