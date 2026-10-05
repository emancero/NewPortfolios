CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerReporteDisponibilidadISSPOL]
    @i_fechaFin datetime = '2024-05-31T23:59:59',
    @i_lga_id int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_fechaIni datetime, @v_oper int
    DECLARE @fechaCorte date,
            @fecha_inicio date

    SET @v_fechaIni = DATEADD(s, -3, DATEADD(dd, 1, DATEDIFF(dd, 0, @i_fechaFin)))
    SET @v_oper = 1

    SET @fechaCorte = DATEADD(s, -3, DATEADD(dd, 1, DATEDIFF(dd, 0, @i_fechaFin)))
    SET @fecha_inicio = DATEADD(yy, DATEDIFF(yy, 0, @i_fechaFin), 0)

    TRUNCATE TABLE corteslist
    INSERT INTO corteslist (c, cortenum)
    SELECT @v_fechaIni, 1

    EXEC bvq_administracion.generarcompraventacorte
    EXEC bvq_administracion.generarvectores
    EXEC bvq_administracion.PrepararValoracionLinealCache

    --[+] Carga de homologacion de fondos y portafolios
    IF (OBJECT_ID('[BVQ_BACKOFFICE].[FONDO_HOMOLOGACION]') IS NULL)
    BEGIN
        SELECT DISTINCT por.por_id, por.por_codigo, c.descripcion, c.id_cuenta
        INTO [BVQ_BACKOFFICE].[FONDO_HOMOLOGACION]
        FROM BVQ_ADMINISTRACION.ISSPOL_MAPA_FONDOS imf
            JOIN BVQ_BACKOFFICE.PORTAFOLIO por ON por.POR_ID = imf.IMF_SICAV
            JOIN inversion.r_fondo_inversion fi ON imf.IMF_SIS = fi.id_seguro_tipo
            JOIN isspolBanco.cuenta c ON c.id_cuenta = fi.id_cuenta
    END
    ELSE
    BEGIN
        TRUNCATE TABLE [BVQ_BACKOFFICE].[FONDO_HOMOLOGACION]
        INSERT INTO [BVQ_BACKOFFICE].[FONDO_HOMOLOGACION]
        SELECT DISTINCT por.por_id, por.por_codigo, c.descripcion, c.id_cuenta
        FROM BVQ_ADMINISTRACION.ISSPOL_MAPA_FONDOS imf
            JOIN BVQ_BACKOFFICE.PORTAFOLIO por ON por.POR_ID = imf.IMF_SICAV
            JOIN inversion.r_fondo_inversion fi ON imf.IMF_SIS = fi.id_seguro_tipo
            JOIN isspolBanco.cuenta c ON c.id_cuenta = fi.id_cuenta
    END
    --[+] Fin de carga de homologacion de fondos y portafolios

    --[+] Cuentas contables del linked server: una sola lectura remota
    SELECT cta.id_cuenta,
           cuenta = cta.cuenta COLLATE DATABASE_DEFAULT
    INTO #cuenta
    FROM siisspolweb.siisspolweb.contabilidad.cuenta cta

    CREATE CLUSTERED INDEX ix_cuenta ON #cuenta (cuenta)

    exec dropifexists '_temp.avail'
    SELECT *
    INTO _temp.avail
    FROM
    (
    SELECT
        portafolio = ICB_DESCRIPCION,
        mov_cuenta_contable,
        fecha_vencimiento = mov_fecha,
        cupon = SUM(ISNULL(fte.MOV_DEBE, 0) - ISNULL(fte.MOV_HABER, 0)),
        origen = 'Real',
        [real] = 1,
        [itc_valor] = UPPER(sbt.ITC_VALOR),
        [tipo] = ISNULL(tipAct.ITC_VALOR, 'Sin clasificación'),
        id_cuenta = cta.id_cuenta,
        [I/E] = tipMov.ITC_VALOR,
        CRC_NUMERO_OPERACION = NULL,
        id_rubro = NULL,
        tasa = NULL,
        producto = NULL,
        segmento = NULL,
        estado = NULL,
        valor = NULL,
        abono = NULL,
        tipo_papel = NULL,
        id_asiento
    FROM _temp.isspol_movimiento_contable_fuente fte
        JOIN bvq_backoffice.isspol_cuentas_contables_de_bancos icb ON icb.icb_cuenta = fte.mov_cuenta_contable
        LEFT JOIN #cuenta cta ON icb.icb_cuenta = cta.cuenta
        LEFT JOIN [BVQ_ADMINISTRACION].[ITEM_CATALOGO] tipMov ON fte.mov_tipo_movimiento = tipMov.ITC_ID
        LEFT JOIN [BVQ_ADMINISTRACION].[ITEM_CATALOGO] tipAct ON fte.mov_tipo_actividad = tipAct.ITC_ID
        LEFT JOIN [BVQ_ADMINISTRACION].[ITEM_CATALOGO] sbt ON fte.mov_subtipo = sbt.ITC_ID AND sbt.CAT_ID = 328
    WHERE fte.mov_fecha >= '20230101'
    GROUP BY 
        MOV_SEC, [ICB_DESCRIPCION], cta.id_cuenta, mov_cuenta_contable, mov_fecha, sbt.itc_valor, 
        tipAct.ITC_VALOR, tipMov.ITC_VALOR, id_asiento

    UNION

    SELECT
        portafolio = ICB_DESCRIPCION,
        NULL,
        fecha_vencimiento = mov_fecha,
        cupon = SUM(fte.MOV_SALDO),
        origen = '0 Saldo Inicial',
        [real] = 1,
        [itc_valor] = UPPER(sbt.ITC_VALOR),
        [tipo] = '0 Saldo Inicial',
        id_cuenta = cta.id_cuenta,
        [I/E] = '0 Saldo Inicial',
        CRC_NUMERO_OPERACION = NULL,
        id_rubro = NULL,
        tasa = NULL,
        producto = NULL,
        segmento = NULL,
        estado = NULL,
        valor = NULL,
        abono = NULL,
        tipo_papel = NULL,
        id_asiento
    FROM BVQ_BACKOFFICE.isspol_saldo_inicial fte
        JOIN bvq_backoffice.isspol_cuentas_contables_de_bancos icb ON icb_cuenta = mov_cuenta_contable
        LEFT JOIN #cuenta cta ON icb.icb_cuenta = cta.cuenta
        LEFT JOIN [BVQ_ADMINISTRACION].[ITEM_CATALOGO] tipMov ON fte.mov_tipo_movimiento = tipMov.ITC_ID
        LEFT JOIN [BVQ_ADMINISTRACION].[ITEM_CATALOGO] tipAct ON fte.mov_tipo_actividad = tipAct.ITC_ID
        LEFT JOIN [BVQ_ADMINISTRACION].[ITEM_CATALOGO] sbt ON fte.mov_subtipo = sbt.ITC_ID AND sbt.CAT_ID = 328
    WHERE fte.mov_fecha >= '20230101'
    GROUP BY [ICB_DESCRIPCION], mov_fecha, sbt.itc_valor, tipAct.ITC_VALOR, cta.id_cuenta, id_asiento

    UNION ALL

    SELECT DISTINCT
        portafolio = ISNULL(icb.ICB_DESCRIPCION, 'N/A'),
        NULL,
        fecha_vencimiento = CONVERT(date, HTP_FECHA_OPERACION),
        cupon = SUM(case when dpf.es_vencimiento_interes=0 then htp_venta when dpf.es_vencimiento_interes=1 then idiff else 0 end),
        origen = 'Proyectado',
        [real] = 0,
        [itc_valor] = 'REDENCIÓN NO PRIVATIVAS',
        [tipo] = 'Proyectado',
        id_cuenta = cta.id_cuenta,
        [I/E] = '1 Ingreso',
        CRC_NUMERO_OPERACION = NULL,
        id_rubro = NULL,
        tasa = NULL,
        producto = NULL,
        segmento = NULL,
        estado = NULL,
        valor = NULL,
        abono = NULL,
        tipo_papel = TVL_NOMBRE,
        id_asiento = NULL
    FROM bvq_backoffice.DetallePortafolio dpf
        LEFT JOIN [BVQ_BACKOFFICE].[FONDO_HOMOLOGACION] fnd ON fnd.POR_ID = dpf.por_id
        LEFT JOIN BVQ_BACKOFFICE.ISSPOL_CUENTAS_CONTABLES_DE_BANCOS icb ON fnd.por_id = icb.ICB_POR_ID
        LEFT JOIN #cuenta cta ON cta.cuenta = icb.icb_cuenta
        LEFT JOIN BVQ_ADMINISTRACION.TITULO_VALOR tiv ON tiv.TIV_ID = dpf.tiv_id
        LEFT JOIN BVQ_ADMINISTRACION.TIPO_VALOR tvl ON tvl.TVL_ID = tiv.TIV_TIPO_VALOR
    WHERE (idiff > 0.05e OR total > 0.05e)
        AND DATEDIFF(d, @i_fechaFin, dpf.htp_fecha_operacion) >= 1
        AND (@v_oper IS NULL OR oper = @v_oper)
    GROUP BY fnd.descripcion, CONVERT(date, HTP_FECHA_OPERACION), fnd.id_cuenta, tvl.TVL_NOMBRE, cta.id_cuenta, icb.ICB_DESCRIPCION

    UNION

    SELECT
        icb.ICB_DESCRIPCION,
        NULL,
        ccc.fecha_vencimiento,
        cupon = SUM(ROUND(ccc.total, 2) - ROUND(ccc.total, 2))
            + SUM(CASE WHEN ccc.fecha_vencimiento >= DATEADD(day, 1, CAST(@i_fechaFin AS date)) THEN ccc.total ELSE 0 END),
        origen = 'Proyectado',
        [real] = 0,
        [itc_valor] = 'REDENCIÓN PRIVATIVAS',
        [tipo] = 'Proyectado',
        id_cuenta = cta.id_cuenta,
        [I/E] = '1 Ingreso',
        CRC_NUMERO_OPERACION = COUNT(*),
        ccc.id_rubro,
        ccc.tasa,
        ccc.producto,
        ccc.segmento,
        NULL, --estado
        SUM(ccc.total),
        SUM(CASE WHEN ccc.fecha_vencimiento >= DATEADD(day, 1, CAST(@i_fechaFin AS date)) THEN ccc.total ELSE 0 END),
        tipo_papel = NULL,
        id_asiento = NULL
    FROM [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA_2] ccc
		join (select top 1 fcrc_fecha from bvq_backoffice.fechas_cierre_creditos_cartera where fcrc_fecha<@i_fechaFin order by fcrc_fecha desc) fcc on ccc.fecha_corte = fcc.fcrc_fecha
        LEFT JOIN [BVQ_BACKOFFICE].[FONDO_HOMOLOGACION] fnd ON fnd.id_cuenta = ccc.id_cuenta
        LEFT JOIN BVQ_BACKOFFICE.ISSPOL_CUENTAS_CONTABLES_DE_BANCOS icb ON icb.ICB_POR_ID = fnd.por_id
        LEFT JOIN #cuenta cta ON cta.cuenta = icb.icb_cuenta
    WHERE ccc.total > 0.05
        AND ccc.fecha_vencimiento >= DATEADD(day, 1, CAST(@i_fechaFin AS date))
    GROUP BY ccc.por_codigo, ccc.fecha_vencimiento, ccc.id_cuenta, id_rubro, tasa, producto, segmento, cta.id_cuenta, icb.ICB_DESCRIPCION

    UNION

    SELECT
        portafolio,
        cuenta_contable,
        fecha_vencimiento,
        cupon,
        origen,
        [real],
        [itc_valor],
        [tipo],
        id_cuenta,
        [I/E],
        CRC_NUMERO_OPERACION,
        id_rubro,
        tasa,
        producto,
        segmento,
        estado,
        valor,
        abono,
        tipo_papel,
        id_asiento = NULL
    FROM BVQ_BACKOFFICE.PensionesProyectadas
    ) AS A

    --[+] Saldos del linked server: una sola lectura remota, solo las cuentas del reporte
    SELECT sal.id_cuenta, sal.saldo_ini, per.fecha_desde, per.fecha_hasta
    INTO #saldo
    FROM siisspolweb.siisspolweb.contabilidad.saldo sal
        INNER JOIN siisspolweb.siisspolweb.contabilidad.periodo per ON sal.id_periodo = per.id_periodo
    WHERE sal.id_cuenta IN (SELECT DISTINCT id_cuenta FROM _temp.avail WHERE id_cuenta IS NOT NULL)

    CREATE CLUSTERED INDEX ix_saldo ON #saldo (id_cuenta, fecha_hasta DESC)

    SELECT
        saldo_ini = b.saldo_ini,
        total = NULL,
        saldo = NULL,
        match_tipo = NULL,
        fecha_hasta = NULL,
        descripcion = NULL,
        av.*
    FROM _temp.avail av
    OUTER APPLY (
        SELECT TOP 1 s.saldo_ini
        FROM #saldo s
        WHERE s.id_cuenta = av.id_cuenta
        ORDER BY
            CASE WHEN av.fecha_vencimiento BETWEEN s.fecha_desde AND s.fecha_hasta THEN 0 ELSE 1 END,
            s.fecha_hasta DESC
    ) b
END
