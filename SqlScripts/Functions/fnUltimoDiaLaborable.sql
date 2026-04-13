CREATE FUNCTION [dbo].[fnUltimoDiaLaborable]
(
    @Fecha DATETIME
)
RETURNS DATETIME
AS
BEGIN
    DECLARE @UltimoDiaMes DATETIME;
    DECLARE @DiaCandidato DATETIME;
    DECLARE @EsLaborable BIT;

    -- Obtener el último día del mes
    SET @UltimoDiaMes = EOMONTH(@Fecha);
    SET @DiaCandidato = @UltimoDiaMes;

    -- Iterar hacia atrás hasta encontrar un día laborable
    WHILE 1 = 1
    BEGIN
        SET @EsLaborable = 1;

        -- Verificar si es fin de semana (1=Domingo, 7=Sábado en DATEPART con DATEFIRST=7)
        IF DATEPART(WEEKDAY, @DiaCandidato) IN (1, 7)
            SET @EsLaborable = 0;

        -- Verificar si es feriado (solo si no es ya fin de semana)
        IF @EsLaborable = 1
        BEGIN
            IF EXISTS (
                SELECT 1
                FROM [sicav].[BVQ_BACKOFFICE].[DIA_FERIADO]
                WHERE CAST(DFE_FECHA_INICIO AS DATE) <= CAST(@DiaCandidato AS DATE)
                  AND CAST(DFE_FECHA_FIN AS DATE)   >= CAST(@DiaCandidato AS DATE)
            )
                SET @EsLaborable = 0;
        END

        -- Si es laborable, retornar
        IF @EsLaborable = 1
            RETURN @DiaCandidato;

        -- Retroceder un día
        SET @DiaCandidato = DATEADD(DAY, -1, @DiaCandidato);
    END

    RETURN NULL; -- Fallback (no debería llegar aquí)
END