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
        fecha_cesion DATE, plazo_recompra INT, fecha_vencimiento DATE, estado VARCHAR(20),
        pagos_capital VARCHAR(50), capital_renovado FLOAT, fecha_pago DATE,
        capital_recuperado FLOAT, intereses_pagados FLOAT, saldo_recuperar FLOAT,
        capital_impago FLOAT, interes_impagos FLOAT, registro_contable FLOAT,
        valoracion FLOAT, porcentaje_constitucion FLOAT, fondo VARCHAR(50), httpo_id INT
    );

    INSERT INTO #reporte_sis
    SELECT
        pc.ems_nombre AS nombre_fideicomiso,
        COALESCE(pc.valnomCompraAnterior, pc.htp_compra) AS desembolso_recursos,
        pc.tiv_tasa_interes AS rendimiento,
        pc.fecha_compra AS fecha_cesion,
        DATEDIFF(d, pc.fecha_compra, pc.tiv_fecha_vencimiento) AS plazo_recompra,
        pc.tiv_fecha_vencimiento AS fecha_vencimiento,
        CASE WHEN @fecha_corte >= pc.tiv_fecha_vencimiento THEN 'Vencido' ELSE 'Vigente' END AS estado,
        'Un solo pago' AS pagos_capital,
        pc.htp_compra AS capital_renovado,
        det.fecha AS fecha_pago,
        det.capital AS capital_recuperado,
        det.iamortizacion AS intereses_pagados,
        pc.sal AS saldo_recuperar,
        pc.sal AS capital_impago,
        NULL AS interes_impagos,
        pc.sal AS registro_contable,
        pc.sal AS valoracion,
        100.0 AS porcentaje_constitucion,
        pc.por_codigo AS fondo,
        pc.httpo_id
    FROM bvq_backoffice.PortafolioCorte pc
        LEFT JOIN bvq_backoffice.DetalleRecuperacionesIsspol det ON pc.htp_numeracion = det.tpo_numeracion AND det.fecha <= @fecha_corte
    WHERE
        pc.IPR_ES_CXC = 1
        AND pc.tvl_codigo = 'der'
        AND pc.sal > 0;

    -------------------------------------------------------------------------------
    -- 1) Mapeo manual: CDF_NOMBRE_FIDEICOMISO (Excel) -> nombre_fideicomiso (sistema).
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
    -- Nota: las siguientes CDF_NOMBRE_FIDEICOMISO NO tienen mapeo a proposito (ya estan
    -- totalmente recuperadas / saldo=0, no aparecen en el reporte del sistema):
    -- ADOKASA, DISMOTEXTIL, IMBAUTO, SONOTEC A, UTE DOS.

    -------------------------------------------------------------------------------
    -- 2) Resultado final: reporte del sistema + filas del Excel no encontradas en el sistema.
    -------------------------------------------------------------------------------
    SELECT
        nombre_fideicomiso, desembolso_recursos, rendimiento,
        fecha_cesion, plazo_recompra, fecha_vencimiento, estado,
        pagos_capital, capital_renovado, fecha_pago,
        capital_recuperado, intereses_pagados, saldo_recuperar,
        capital_impago, interes_impagos, registro_contable,
        valoracion, porcentaje_constitucion, fondo,
        NULL AS fila_excel,
        'SICAV' AS origen
    FROM #reporte_sis
    UNION ALL
    (SELECT
        map.nombre_sistema AS nombre_fideicomiso,
        cdf.CDF_DESEMBOLSO_RECURSOS_ISSPOL AS desembolso_recursos,
        cdf.CDF_RENDIMIENTO_INTERES AS rendimiento,
        cdf.CDF_FECHA_CESION AS fecha_cesion,
        cdf.CDF_PLAZO_RECOMPRA_DIAS AS plazo_recompra,
        cdf.CDF_FECHA_VENCIMIENTO_RECOMPRA AS fecha_vencimiento,
        cdf.CDF_ESTADO AS estado,
        cdf.CDF_MODALIDAD_PAGO AS pagos_capital,
        cdf.CDF_CAPITAL_RENOVADO AS capital_renovado,
        cdf.CDF_FECHA_PAGO_DETALLE AS fecha_pago,
        cdf.CDF_CAPITAL_RECUPERADO AS capital_recuperado,
        cdf.CDF_INTERESES_PAGADOS AS intereses_pagados,
        cdf.CDF_SALDO_POR_RECUPERAR_CAPITAL AS saldo_recuperar,
        cdf.CDF_CAPITAL_IMPAGO AS capital_impago,
        cdf.CDF_INTERESES_IMPAGOS AS interes_impagos,
        cdf.CDF_REGISTRO_CONTABLE_SALDO AS registro_contable,
        cdf.CDF_VALORACION_UTILIDAD_DETERIORO AS valoracion,
        cdf.CDF_PCT_CONSTITUCION_UTILIDAD AS porcentaje_constitucion,
        cdf.CDF_FONDO_PERTENECE AS sistema_fondo,
        cdf.CDF_FILA_EXCEL AS fila_excel,
        'XLS' AS origen
    FROM BVQ_BACKOFFICE.CDF_MATRIZ_CESION_DERECHOS_FID cdf
    LEFT JOIN #mapeo_nombres map ON map.CDF_NOMBRE_FIDEICOMISO = cdf.CDF_NOMBRE_FIDEICOMISO
    LEFT JOIN #reporte_sis sis
        ON sis.nombre_fideicomiso = map.nombre_sistema
        AND sis.fecha_cesion = cdf.CDF_FECHA_CESION
        AND (map.nombre_sistema <> 'INMOBILIARIA TESLA BUILDINGS CORP'
            OR map.nombre_sistema = 'INMOBILIARIA TESLA BUILDINGS CORP' AND sis.fecha_vencimiento <> cdf.CDF_FECHA_VENCIMIENTO_RECOMPRA)
    WHERE (nombre_sistema IS NULL OR sis.fecha_cesion IS NULL)
        AND NOT (map.nombre_sistema = 'INMOBILIARIA TESLA BUILDINGS CORP' AND cdf.CDF_FECHA_CESION IN ('20190328', '20180328'))
        AND NOT (map.nombre_sistema = 'INTEROCEANICA' AND cdf.CDF_FECHA_CESION IN ('20181010', '20190502', '20171011'))
        AND NOT (map.nombre_sistema = 'MINERIA BELORO' AND cdf.CDF_FECHA_CESION < '20221021')
        AND NOT (map.nombre_sistema = 'CONSORCIO TPB' AND cdf.CDF_FECHA_CESION = '20171117')
        AND NOT (map.nombre_sistema = 'INMOBILIARIA GIOVANNINI MORETTI INT' AND cdf.CDF_FECHA_CESION <= '20190328')
        AND NOT (map.nombre_sistema = 'MOPROCORP' AND cdf.CDF_FECHA_CESION = '20170412')
        AND (cdf.CDF_SALDO_POR_RECUPERAR_CAPITAL IS NULL OR cdf.CDF_SALDO_POR_RECUPERAR_CAPITAL <= 0))
    ORDER BY nombre_fideicomiso, fecha_cesion, fecha_pago;

END
