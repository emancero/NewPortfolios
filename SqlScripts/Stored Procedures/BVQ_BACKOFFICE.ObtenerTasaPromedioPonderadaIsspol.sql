CREATE PROCEDURE BVQ_BACKOFFICE.ObtenerTasaPromedioPonderadaIsspol
	@i_fechaCorte DateTime,
	@i_lga_id int=null
AS
BEGIN
    truncate table corteslist
    insert into corteslist values (@i_fechaCorte,1)
 
    exec bvq_administracion.generarcompraventacorte

    SELECT pc.ems_nombre + ' ' + pc.htp_numeracion AS titulo,
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

    SELECT CASE [sector_general] collate modern_spanish_ci_ai WHEN 'SEC_PRI_FIN' then 'PRIVADO FINANCIERO Y ECONOMÍA POPULAR SOLIDARIA' WHEN 'SEC_PRI_NFIN' THEN 'PRIVADO NO FINANCIERO' WHEN 'SEC_PUB_FIN' THEN 'PUBLICO' WHEN 'SEC_PUB_NFIN' THEN 'PUBLICO' END AS titulo,
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
    GROUP  BY pc.sector_general 

    SELECT 'Tasa Promedio Ponderada General' AS titulo,
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
           AND sector_general = 'SEC_PUB_NFIN'
    ORDER  BY 1 
 

END