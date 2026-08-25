CREATE PROCEDURE bvq_backoffice.NotificarVencimientosIsspol
    @FechaIni DATETIME = NULL,   -- si es NULL, se usa el día de hoy
    @FechaFin DATETIME = NULL    -- si es NULL, se usa @FechaIni (o hoy)
AS
BEGIN
    SET NOCOUNT ON;

    IF @FechaIni IS NULL SET @FechaIni = GETDATE();
    IF @FechaFin IS NULL SET @FechaFin = @FechaIni;

    -- normalizar cada fecha a inicio/fin de su propio día
    SET @FechaIni = CONVERT(datetime, CONVERT(date, @FechaIni));                                       -- 00:00:00.000
    SET @FechaFin = DATEADD(millisecond, -3, DATEADD(day, 1, CONVERT(datetime, CONVERT(date, @FechaFin)))); -- 23:59:59.997

    IF @FechaIni > @FechaFin
    BEGIN
        RAISERROR('@FechaIni no puede ser mayor a @FechaFin.', 16, 1);
        RETURN;
    END

    DECLARE @idPortfolio INT = -1;

    ------------------------------------------------------------------
    -- 1. Refrescar bvq_backoffice.evtTemp (efecto secundario del SP
    --    fuente); @i_mostrar=0 evita que genere sus dos result sets.
    ------------------------------------------------------------------
    EXEC bvq_backoffice.ObtenerDetallePortafolioConLiquidez
        @i_idPortfolio = @idPortfolio,
        @i_fechaIni = @FechaIni,
        @i_fechaFin = @FechaFin,
        @i_mostrar = 0;

    ------------------------------------------------------------------
    -- 2. Leer evtTemp con el mismo filtro del SELECT final del SP fuente,
    --    agrupado por tpo_numeracion. capMonto se recalcula con el mismo
    --    join (eCap) que usa el SP fuente, porque no es una columna real
    --    de evtTemp.
    ------------------------------------------------------------------
    DECLARE @Detalle TABLE (
        tpo_numeracion VARCHAR(250),
        ems_nombre VARCHAR(200),
        tiv_fecha_vencimiento DATETIME,
        capital FLOAT,
        interes FLOAT
    );

    INSERT INTO @Detalle (tpo_numeracion, ems_nombre, tiv_fecha_vencimiento, capital, interes)
    SELECT
        e.tpo_numeracion,
        MAX(e.ems_nombre) AS ems_nombre,
        MAX(e.tiv_fecha_vencimiento) AS tiv_fecha_vencimiento,
        SUM(e.amount),
        SUM(e.iAmortizacion)
    FROM bvq_backoffice.evtTemp e
    LEFT JOIN (
        SELECT NULLIF(vep_valor_efectivo, 0) AS capMonto, htp_id AS capHtpId, fecha AS capFecha
        FROM bvq_backoffice.evtTemp
        WHERE es_vencimiento_interes = 0 AND htp_tiene_valnom = 1
    ) eCap ON eCap.capHtpId = e.htp_id AND eCap.capFecha = e.fecha
    WHERE e.fecha BETWEEN @FechaIni AND @FechaFin
      AND (@idPortfolio = e.por_id OR @idPortfolio = -1)
      AND (ABS(ROUND(e.amount, 2)) > 0.05 OR e.oper = 2 OR e.evp_abono = 1)
      AND e.htp_id IS NOT NULL
    GROUP BY e.tpo_numeracion;

    ------------------------------------------------------------------
    -- 3. Armar asunto/cuerpo: con datos o "sin registros"
    ------------------------------------------------------------------
    DECLARE @RangoTexto NVARCHAR(60) = CASE
        WHEN CONVERT(date, @FechaIni) = CONVERT(date, @FechaFin) THEN CONVERT(NVARCHAR(10), @FechaIni, 103)
        ELSE CONVERT(NVARCHAR(10), @FechaIni, 103) + N' - ' + CONVERT(NVARCHAR(10), @FechaFin, 103)
    END;

    DECLARE @HayDatos BIT = CASE WHEN EXISTS (SELECT 1 FROM @Detalle) THEN 1 ELSE 0 END;
    DECLARE @Asunto NVARCHAR(255);
    DECLARE @Cuerpo NVARCHAR(MAX);

    IF @HayDatos = 1
    BEGIN
        DECLARE @Filas NVARCHAR(MAX);
        SELECT @Filas = dbo.stringagg(
            N'<tr><td>' + ISNULL(ems_nombre, N'') + N'</td>'
                        + N'<td>' + ISNULL(tpo_numeracion, N'') + N'</td>'
                        + N'<td>' + ISNULL(CONVERT(VARCHAR(10), tiv_fecha_vencimiento, 103), N'') + N'</td>'
                        + N'<td>' + ISNULL(CONVERT(VARCHAR(30), CAST(capital AS DECIMAL(18,2))), N'') + N'</td>'
                        + N'<td>' + ISNULL(CONVERT(VARCHAR(30), CAST(interes AS DECIMAL(18,2))), N'') + N'</td></tr>',
            N''
        )
        FROM @Detalle;

        SET @Asunto = N'Vencimientos de títulos - ' + @RangoTexto;
        SET @Cuerpo = N'
        <html><body>
        <p>Detalle de vencimientos de t&iacute;tulos para ' + @RangoTexto + N':</p>
        <table border="1" cellpadding="4" cellspacing="0" style="border-collapse:collapse;font-family:Arial,sans-serif;font-size:12px;">
        <tr style="background-color:#f0f0f0;"><th>Emisor</th><th>C&oacute;digo</th><th>Fecha de vencimiento final</th><th>Capital</th><th>Inter&eacute;s</th></tr>'
        + @Filas + N'
        </table>
        </body></html>';
    END
    ELSE
    BEGIN
        SET @Asunto = N'Vencimientos de títulos - ' + @RangoTexto + N' (sin registros)';
        SET @Cuerpo = N'
        <html><body>
        <p>No se encontraron vencimientos de t&iacute;tulos para ' + @RangoTexto + N'.</p>
        </body></html>';
    END

    ------------------------------------------------------------------
    -- 4. Destinatarios (MAIL_VEN_ISSPOL / MVI_TO) y envío
    ------------------------------------------------------------------
    DECLARE @Correos VARCHAR(MAX);
    SELECT @Correos = dbo.stringagg(it.ITC_VALOR, ';')
    FROM BVQ_ADMINISTRACION.ITEM_CATALOGO it
    INNER JOIN BVQ_ADMINISTRACION.CATALOGO cat ON cat.CAT_ID = it.CAT_ID
    WHERE cat.CAT_CODIGO = 'MAIL_VEN_ISSPOL'
      AND it.ITC_CODIGO = 'MVI_TO';

    IF @Correos IS NULL OR LTRIM(RTRIM(@Correos)) = ''
    BEGIN
        RAISERROR('No hay correos de destino configurados en MAIL_VEN_ISSPOL / MVI_TO.', 16, 1);
        RETURN;
    END

    DECLARE @Profile SYSNAME = N'NotificacionesBvq';

    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = @Profile,
        @recipients   = @Correos,
        @subject      = @Asunto,
        @body         = @Cuerpo,
        @body_format  = 'HTML';
END

-- Uso normal (día de hoy, para el job diario):
-- EXEC bvq_backoffice.NotificarVencimientosIsspol;

-- Prueba con una fecha puntual que sabemos tiene datos:
-- EXEC bvq_backoffice.NotificarVencimientosIsspol @FechaIni = '20260825';

-- Prueba con un rango:
-- EXEC bvq_backoffice.NotificarVencimientosIsspol @FechaIni = '20260801', @FechaFin = '20260831';
