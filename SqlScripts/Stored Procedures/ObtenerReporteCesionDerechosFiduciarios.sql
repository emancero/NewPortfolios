CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerReporteCesionDerechosFiduciarios]
	@fecha_corte DATE,
	@i_lga_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM corteslist
    INSERT INTO corteslist VALUES (@fecha_corte, 1)
    EXEC bvq_backoffice.obtenerdetalleportafolioconliquidez -1,'19000101',@fecha_corte, NULL, 1, 0, NULL

    -------------------------------------------------------------------------------
    -- 0) Reporte base del sistema -> tabla temporal.
    -------------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#reporte_sis') IS NOT NULL DROP TABLE #reporte_sis;
    CREATE TABLE #reporte_sis (
        nombre_fideicomiso VARCHAR(300), desembolso_recursos FLOAT, rendimiento FLOAT,
        fecha_cesion DATE, fecha_emision DATE, fecha_suscripcion DATE, plazo_recompra INT, fecha_vencimiento DATE, estado VARCHAR(20),
        pagos_capital VARCHAR(50), capital_renovado FLOAT, fecha_pago DATE,
        capital_recuperado FLOAT, intereses_pagados FLOAT, saldo_recuperar FLOAT,
        capital_impago FLOAT, interes_impagos FLOAT, registro_contable FLOAT,
        valoracion FLOAT, porcentaje_constitucion FLOAT, fondo VARCHAR(MAX), numeracion VARCHAR(250)
    );
    INSERT INTO #reporte_sis
    SELECT
        pc.ems_nombre AS nombre_fideicomiso,
        SUM(COALESCE(pc.valnomCompraAnterior, pc.htp_compra)) AS desembolso_recursos,
        pc.tiv_tasa_interes AS rendimiento,
        pc.fecha_compra AS fecha_cesion,
        pc.tiv_fecha_emision AS fecha_emision,
        pc.tpo_fecha_susc_convenio AS fecha_suscripcion,
        DATEDIFF(d, pc.fecha_compra, pc.tiv_fecha_vencimiento) AS plazo_recompra,
        pc.tiv_fecha_vencimiento AS fecha_vencimiento,
        CASE WHEN @fecha_corte >= pc.tiv_fecha_vencimiento THEN 'Vencido' ELSE 'Vigente' END AS estado,
        'Un solo pago' AS pagos_capital,
        sum(pc.htp_compra) AS capital_renovado,
        det.fecha AS fecha_pago,
        SUM(det.capital) AS capital_recuperado,
        SUM(det.iamortizacion) AS intereses_pagados,
        SUM(pc.sal) AS saldo_recuperar,
        SUM(pc.sal) AS capital_impago,
        NULL AS interes_impagos,
        SUM(pc.sal) AS registro_contable,
        SUM(pc.sal) AS valoracion,
        100.0 AS porcentaje_constitucion,
        dbo.StringAgg(pc.por_codigo,'/') AS fondo,
        pc.htp_numeracion AS numeracion
    FROM bvq_backoffice.PortafolioCorte pc
        LEFT JOIN bvq_backoffice.DetalleRecuperacionesIsspol det ON pc.htp_numeracion = det.tpo_numeracion AND det.fecha <= @fecha_corte
    WHERE
        pc.IPR_ES_CXC = 1
        AND pc.tvl_codigo = 'der'
        AND pc.sal > 0
    GROUP BY pc.ems_nombre, pc.tiv_tasa_interes, pc.fecha_compra, pc.tiv_fecha_emision, pc.tpo_fecha_susc_convenio, DATEDIFF(d, pc.fecha_compra, pc.tiv_fecha_vencimiento),
        pc.tiv_fecha_vencimiento, CASE WHEN @fecha_corte >= pc.tiv_fecha_vencimiento THEN 'Vencido' ELSE 'Vigente' END, det.fecha, pc.htp_numeracion;

    -------------------------------------------------------------------------------
    -- 1) Mapeo manual nombre: CDF_NOMBRE_FIDEICOMISO (Excel) -> nombre_fideicomiso (sistema).
    -------------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#mapeo_nombres') IS NOT NULL DROP TABLE #mapeo_nombres;
    CREATE TABLE #mapeo_nombres (
        CDF_NOMBRE_FIDEICOMISO VARCHAR(300) NOT NULL,
        nombre_sistema VARCHAR(300) NOT NULL
    );
    INSERT INTO #mapeo_nombres (CDF_NOMBRE_FIDEICOMISO, nombre_sistema) VALUES
    ('FIDEICOMISO FINCA EL VIUDO', 'TEKA VIUDO'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACIÓN ALPHA BUILDERS; ; TESLA BUILDINGS CORP', 'INMOBILIARIA TESLA BUILDINGS CORP'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION ARQUITECTURA Y ADMINISTRACION (ECOARQUITECTOS)', 'ECO & ARQUITECTOS'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION ASPHALTVIAS', 'ASPHALTVIAS'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION BELORO', 'MINERIA BELORO'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION CARTERA LARGO PLAZO (CREDIMETRICA)', 'CREDIMETRICA S.A.'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION CARTERA MALLORCA (CONSTRUDIPRO)', 'CONSTRUCTORA DE DISEÑOS PRODUCTIVOS CONSTRUDIPRO S.A.'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION CENTINELA COSTA CLUB', 'CENTINELA COSTA CLUB'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACIÓN CONSORCIO TPB', 'CONSORCIO TPB'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION DRILLING TECHNOLOGIES', 'SDT DRILLINGTECHNOLOGIES'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION ECUAPET', 'ECUAPET'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION ECUEMPIRE', 'ECUEMPIRE'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION EDIFICIO ISMARLY', 'FID. ISMARLY'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION GIOVANINNI MORETTI', 'INMOBILIARIA GIOVANNINI MORETTI INT'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION GREEN OIL', 'GREEN OIL'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION INTEROCEANICA', 'INTEROCEANICA'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACIÓN JORGE SAGUAY E HIJOS (LA CIGARRA)', 'LA CIGARRA'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACIÓN LA ESPERANZA WHOSALE II', 'LA ESPERANZA COMERCIALIZADORA WHOLESALEINN S.A.'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION LATITUD CERO', 'LATITUD CERO'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION MARCELO SAENZ', 'MARCELO SAENZ'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACIÓN MOPROCORP', 'MOPROCORP'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION PROMOSTOCK', 'PROMOSTOCK'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACIÓN PURA VIDA', 'AGRICOLA PURA VIDA'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION SAN JUAN DE LA VIÑA (SAN JUAN DE INCHALILLO)', 'FIDEICOMISO SAN JUAN INCHALILLO'),
    ('FIDEICOMISO MERCANTIL DE ADMINISTRACION SARVIMPORT', 'SARVIMPORT'),
    ('FIDEICOMISO MERCANTIL GARANTIA DELCORP', 'DELCORP S.A.'),
    ('FIDEICOMISO MERCANTIL INMOBILIARIO NEIMPRO ALTOS DEL PACIFICO', 'NEIMPRO S.A.'),
    ('FIDEICOMISO MERCANTIL INMOBILIARIO PLAZA PROYECTA', 'PLAZA PROYECTA'),
    ('FIDEICOMISO MERCANTIL INMOBILIARIO SAN CAYETANO (MAKTRADECORP)', 'MAKTRADE PROINCO INMOBILIARIA');

    -------------------------------------------------------------------------------
    -- 1b) Mapeo manual numeracion -> fila_excel, verificado a mano.
    -------------------------------------------------------------------------------
    IF OBJECT_ID('tempdb..#match_manual') IS NOT NULL DROP TABLE #match_manual;
    CREATE TABLE #match_manual (numeracion VARCHAR(250) NOT NULL, fila_excel INT NOT NULL);
    INSERT INTO #match_manual (numeracion, fila_excel) VALUES
    ('ASPHALTVIAS-2019-06-28-3', 20),
    ('ASPHALTVIAS-2019-06-28-4', 21),
    ('BELORO-2022-10-21-3', 425),
    ('BELORO-2022-10-21-4', 434),
    ('BELORO-2022-10-21-5', 430),
    ('BELORO-2022-10-21-6', 437),
    ('BELORO-2022-10-21-7', 440),
    ('BELORO-2022-10-21-8', 443),
    ('BELORO-2022-10-21-9', 447),
    ('CDD-2017-12-27', 77),
    ('CDM-2018-09-24', 85),
    ('CENTINELA-2018-07-09', 28),
    ('CENTINELA-2018-07-09-2', 29),
    ('CENTINELA-2018-09-03-2', 32),
    ('CONSORCIO_TPB-2018-11-26', 64),
    ('CONSORCIO_TPB-2018-11-26-2', 64),
    ('CONSORCIO_TPB-2018-11-26-3', 64),
    ('CONSORCIO_TPB-2018-11-26-4', 64),
    ('GIO_MOR-2019-03-28', 382),
    ('GREEN_OIL-2019-07-03', 290),
    ('GREEN_OIL-2019-07-03-2', 291),
    --('INM_TESLA-2023-01-31-2', 0),
    ('INM_TESLA-2023-01-31-3', 545),
    ('INM_TESLA-2023-01-31-4', 464),
    ('INM_TESLA-2023-01-31-5', 464),
    ('INTEROCEANICA-2022-10-05-2', 650),
    ('INTEROCEANICA-2022-10-05-3', 586),
    ('INTEROCEANICA-2022-10-05-4', 586),
    ('INTEROCEANICA-2022-10-05-5', 629),
    ('MOPROCORP-2018-09-28', 419),
    ('NEIMPRO-2019-02-22-4', 581),
    ('PURA_VIDA-2019-06-17', 11),
    ('PURA_VIDA-2019-06-17-2', 15),
    ('PURA_VIDA-2019-06-17-3', 13),
    ('SDT-2019-04-03', 405),
    ('SDT-2019-04-03-2', 405),
    ('SDT-2019-04-03-3', 405),
    ('SDT-2019-04-03-4', 405),
    ('SDT-2019-04-03-5', 405),
    ('SDT-2019-04-03-6', 405)
    --('WLN-2019-07-19', 0),
    --('WLN-2019-07-19-2', 0),
    --('WLN-2019-07-19-3', 0),
    --('WLN-2019-07-19-4', 0),
    --('WLN-2019-07-19-5', 0),
    --('WLN-2019-07-19-6', 0),
    --('WLN-2019-08-08', 0),
    --('WLN-2019-08-08-2', 0)
    ;

    IF OBJECT_ID('tempdb..#resultado_1') IS NOT NULL DROP TABLE resultado_1;
    SELECT
        sis.numeracion AS numeracion,
        cdf.CDF_ID,
        cdf.CDF_FILA_EXCEL AS fila_excel,
        cdf.CDF_ID_INVERSION AS id_inversion,
        COALESCE(map.nombre_sistema, sis.nombre_fideicomiso, cdf.CDF_NOMBRE_FIDEICOMISO) AS nombre_fideicomiso,
        COALESCE(sis.desembolso_recursos, cdf.CDF_DESEMBOLSO_RECURSOS_ISSPOL) AS desembolso_recursos,
        COALESCE(sis.rendimiento, cdf.CDF_RENDIMIENTO_INTERES * 100) AS rendimiento,
        COALESCE(sis.fecha_cesion, cdf.CDF_FECHA_CESION) AS fecha_cesion,
        COALESCE(sis.plazo_recompra, cdf.CDF_PLAZO_RECOMPRA_DIAS) AS plazo_recompra,
        COALESCE(sis.fecha_vencimiento, cdf.CDF_FECHA_VENCIMIENTO_RECOMPRA) AS fecha_vencimiento,
        COALESCE(sis.estado, cdf.CDF_ESTADO) AS estado,
        COALESCE(sis.pagos_capital, cdf.CDF_MODALIDAD_PAGO) AS pagos_capital,
        COALESCE(sis.capital_renovado, cdf.CDF_CAPITAL_RENOVADO) AS capital_renovado,
        COALESCE(sis.fecha_pago, cdf.CDF_FECHA_PAGO_DETALLE) AS fecha_pago,
        COALESCE(sis.capital_recuperado, cdf.CDF_CAPITAL_RECUPERADO) AS capital_recuperado,
        COALESCE(sis.intereses_pagados, cdf.CDF_INTERESES_PAGADOS) AS intereses_pagados,
        COALESCE(sis.saldo_recuperar, cdf.CDF_SALDO_POR_RECUPERAR_CAPITAL) AS saldo_recuperar,
        COALESCE(sis.capital_impago, cdf.CDF_CAPITAL_IMPAGO) AS capital_impago,
        COALESCE(sis.interes_impagos, cdf.CDF_INTERESES_IMPAGOS) AS interes_impagos,
        COALESCE(sis.registro_contable, cdf.CDF_REGISTRO_CONTABLE_SALDO) AS registro_contable,
        COALESCE(sis.valoracion, cdf.CDF_VALORACION_UTILIDAD_DETERIORO) AS valoracion,
        COALESCE(sis.porcentaje_constitucion, cdf.CDF_PCT_CONSTITUCION_UTILIDAD) AS porcentaje_constitucion,
        COALESCE(sis.fondo, cdf.CDF_FONDO_PERTENECE) AS fondo
    INTO #resultado_1
    FROM #reporte_sis sis
        LEFT JOIN #mapeo_nombres map ON map.nombre_sistema = sis.nombre_fideicomiso
        FULL JOIN BVQ_BACKOFFICE.CDF_MATRIZ_CESION_DERECHOS_FID cdf
            ON map.CDF_NOMBRE_FIDEICOMISO = cdf.CDF_NOMBRE_FIDEICOMISO
            AND sis.fecha_cesion = cdf.CDF_FECHA_CESION
            AND sis.fecha_vencimiento = cdf.CDF_FECHA_VENCIMIENTO_RECOMPRA 
            AND sis.saldo_recuperar = cdf.CDF_SALDO_POR_RECUPERAR_CAPITAL;

    IF OBJECT_ID('tempdb..#res_match_1') IS NOT NULL DROP TABLE #res_match_1;
    SELECT * INTO #res_match_1 FROM #resultado_1
    WHERE (CDF_ID IS NOT NULL AND numeracion IS NOT NULL);

    IF OBJECT_ID('tempdb..#res_match_2') IS NOT NULL DROP TABLE #res_match_2;
    SELECT
        base.numeracion,
        COALESCE(base.CDF_ID, cdf2.CDF_ID) AS CDF_ID,
        COALESCE(base.fila_excel, cdf2.CDF_FILA_EXCEL) AS fila_excel,
        COALESCE(base.id_inversion, cdf2.CDF_ID_INVERSION) AS id_inversion,
        COALESCE(base.nombre_fideicomiso, cdf2.CDF_NOMBRE_FIDEICOMISO) AS nombre_fideicomiso,
        COALESCE(base.desembolso_recursos, cdf2.CDF_DESEMBOLSO_RECURSOS_ISSPOL) AS desembolso_recursos,
        COALESCE(base.rendimiento, cdf2.CDF_RENDIMIENTO_INTERES * 100) AS rendimiento,
        COALESCE(base.fecha_cesion, cdf2.CDF_FECHA_CESION) AS fecha_cesion,
        COALESCE(base.plazo_recompra, cdf2.CDF_PLAZO_RECOMPRA_DIAS) AS plazo_recompra,
        COALESCE(base.fecha_vencimiento, cdf2.CDF_FECHA_VENCIMIENTO_RECOMPRA) AS fecha_vencimiento,
        COALESCE(base.estado, cdf2.CDF_ESTADO) AS estado,
        COALESCE(base.pagos_capital, cdf2.CDF_MODALIDAD_PAGO) AS pagos_capital,
        COALESCE(base.capital_renovado, cdf2.CDF_CAPITAL_RENOVADO) AS capital_renovado,
        COALESCE(base.fecha_pago, cdf2.CDF_FECHA_PAGO_DETALLE) AS fecha_pago,
        COALESCE(base.capital_recuperado, cdf2.CDF_CAPITAL_RECUPERADO) AS capital_recuperado,
        COALESCE(base.intereses_pagados, cdf2.CDF_INTERESES_PAGADOS) AS intereses_pagados,
        COALESCE(base.saldo_recuperar, cdf2.CDF_SALDO_POR_RECUPERAR_CAPITAL) AS saldo_recuperar,
        COALESCE(base.capital_impago, cdf2.CDF_CAPITAL_IMPAGO) AS capital_impago,
        COALESCE(base.interes_impagos, cdf2.CDF_INTERESES_IMPAGOS) AS interes_impagos,
        COALESCE(base.registro_contable, cdf2.CDF_REGISTRO_CONTABLE_SALDO) AS registro_contable,
        COALESCE(base.valoracion, cdf2.CDF_VALORACION_UTILIDAD_DETERIORO) AS valoracion,
        COALESCE(base.porcentaje_constitucion, cdf2.CDF_PCT_CONSTITUCION_UTILIDAD) AS porcentaje_constitucion,
        COALESCE(base.fondo, cdf2.CDF_FONDO_PERTENECE) AS fondo
    INTO #res_match_2
    FROM
        (SELECT * FROM #resultado_1 WHERE (CDF_ID IS NULL AND numeracion IS NOT NULL)) base
        LEFT JOIN #match_manual mm ON mm.numeracion = base.numeracion
        LEFT JOIN BVQ_BACKOFFICE.CDF_MATRIZ_CESION_DERECHOS_FID cdf2 ON cdf2.CDF_FILA_EXCEL = mm.fila_excel
    ORDER BY nombre_fideicomiso, id_inversion, base.numeracion, fecha_cesion, fecha_vencimiento, fecha_pago;
    
    SELECT
        numeracion, CDF_ID, fila_excel, id_inversion, 
        COALESCE(map.nombre_sistema, nombre_fideicomiso) AS nombre_fideicomiso,
        desembolso_recursos, rendimiento, fecha_cesion, plazo_recompra, 
        fecha_vencimiento, estado, pagos_capital, capital_renovado, fecha_pago,
        capital_recuperado, intereses_pagados, saldo_recuperar, capital_impago, 
        interes_impagos, registro_contable, valoracion, porcentaje_constitucion, fondo
    INTO #res_match_3
    FROM #resultado_1 r1
        LEFT JOIN #mapeo_nombres map ON r1.nombre_fideicomiso = map.CDF_NOMBRE_FIDEICOMISO
    WHERE 
        (r1.fila_excel NOT IN
            (SELECT DISTINCT fila_excel FROM #res_match_1 WHERE fila_excel IS NOT NULL
            UNION ALL
            SELECT DISTINCT fila_excel FROM #res_match_2 WHERE fila_excel IS NOT NULL)
        AND r1.fila_excel IS NOT NULL);

    -------------------------------------------------------------------------------
    -- 2) Resultado final
    -------------------------------------------------------------------------------
    SELECT '1' as Q, * from #res_match_1
    UNION ALL
    SELECT '2' as Q, * from #res_match_2
    UNION ALL
    SELECT '3' as Q, * from #res_match_3
    ORDER BY nombre_fideicomiso, fila_excel, id_inversion;

END
