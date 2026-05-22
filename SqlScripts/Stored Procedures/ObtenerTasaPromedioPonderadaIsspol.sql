CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerTasaPromedioPonderadaIsspol]
	@i_fechaCorte DateTime,
	@i_lga_id int=null
AS
BEGIN
    truncate table corteslist
    insert into corteslist values (@i_fechaCorte,1)
 
    exec bvq_administracion.generarcompraventacorte

    SELECT pc.ems_nombre + ' ' + pc.htp_numeracion AS titulo,
           SUM(sal) AS monto,
           Sum(CASE
                 WHEN pc.[tvl_codigo] IN ( 'FAC', 'PCO', 'OBL', 'OCA', 'VCC' )
                       OR pc.[tvl_codigo] IN ( 'BE' )
                          AND ( pc.fecha_compra >= '20251118'
                                 OR tpo_acta LIKE 'BE%' ) THEN [htp_rendimiento]
                 ELSE [tiv_tasa_interes]
               END / 100.0 * sal) / NULLIF(Sum(sal), 0) AS tpp
    FROM   bvq_backoffice.portafoliocorte pc
    WHERE  Isnull(ipr_es_cxc, 0) = 0
           AND sal > 0
    GROUP  BY pc.ems_nombre,
              pc.htp_numeracion

    SELECT 
        [SECTOR_DETALLADO] collate modern_spanish_ci_ai AS titulo,
        SUM(sal) AS monto,
        SUM(CASE
                WHEN pc.[tvl_codigo] IN ('FAC','PCO','OBL','OCA','VCC')
                  OR pc.[tvl_codigo] IN ('BE')
                     AND (pc.fecha_compra >= '20251118' OR tpo_acta LIKE 'BE%') 
                    THEN [htp_rendimiento]
                ELSE [tiv_tasa_interes]
            END / 100.0 * sal) / NULLIF(SUM(sal), 0) AS tpp
    FROM   bvq_backoffice.portafoliocorte pc
    WHERE  ISNULL(ipr_es_cxc, 0) = 0
           AND sal > 0
    GROUP BY SECTOR_DETALLADO collate modern_spanish_ci_ai

    SELECT 'Tasa Promedio Ponderada General' AS titulo,
           SUM(sal) AS monto,
           Sum(CASE
                 WHEN pc.[tvl_codigo] IN ( 'FAC', 'PCO', 'OBL', 'OCA', 'VCC' )
                       OR pc.[tvl_codigo] IN ( 'BE' )
                          AND ( pc.fecha_compra >= '20251118'
                                 OR tpo_acta LIKE 'BE%' ) THEN [htp_rendimiento]
                 ELSE [tiv_tasa_interes]
               END / 100.0 * sal) / NULLIF(Sum(sal), 0) AS tpp
    FROM   bvq_backoffice.portafoliocorte pc
    WHERE  Isnull(ipr_es_cxc, 0) = 0
           AND sal > 0
           AND tiv_tipo_renta = 153
    ORDER  BY 1 
END