IF OBJECT_ID('tempdb..#TitulosSinCamaraProd') IS NOT NULL
    DROP TABLE #TitulosSinCamaraProd;

select httpo_id, tiv_camara, tiv.tiv_codigo, fecha_compra
INTO #TitulosSinCamaraProd
from [192.168.2.225].sicav.bvq_backoffice.portafoliocorte pc
join [192.168.2.225].sicav.bvq_administracion.titulo_valor tiv on pc.tiv_id=tiv.tiv_id
where isnull(ipr_es_cxc,0)=0 and sal>0 --and tiv_camara IS NULL

IF OBJECT_ID('tempdb..#TitulosSinCamaraEst') IS NOT NULL
    DROP TABLE #TitulosSinCamaraEst;

select httpo_id, tiv_camara, tiv.tiv_codigo, fecha_compra
INTO #TitulosSinCamaraEst
from bvq_backoffice.portafoliocorte pc
join bvq_administracion.titulo_valor tiv on pc.tiv_id=tiv.tiv_id
where isnull(ipr_es_cxc,0)=0 and sal>0 --and tiv_camara IS NULL

---- EST con tiv_camara NULL que en PROD no está NULL
--SELECT 'EST null / PROD no null' AS caso, e.httpo_id, e.tiv_codigo,
--       e.tiv_camara AS est_camara, p.tiv_camara AS prod_camara
--FROM #TitulosSinCamaraEst e
--LEFT JOIN #TitulosSinCamaraProd p ON p.httpo_id = e.httpo_id
--WHERE e.tiv_camara IS NULL
--  AND NOT EXISTS (SELECT 1 FROM #TitulosSinCamaraProd p2
--                  WHERE p2.httpo_id = e.httpo_id AND p2.tiv_camara IS NULL)

-- PROD con tiv_camara NULL que en EST no está NULL
SELECT e.tiv_camara, p.fecha_compra as fc, 'PROD null / EST no null' AS caso, p.httpo_id, p.tiv_codigo
FROM #TitulosSinCamaraProd p
LEFT JOIN #TitulosSinCamaraEst e ON e.httpo_id = p.httpo_id
WHERE p.tiv_camara IS NULL
    AND NOT EXISTS (SELECT 1 FROM #TitulosSinCamaraEst e2
                    WHERE e2.httpo_id = p.httpo_id AND e2.tiv_camara IS NULL)

UNION ALL

SELECT 
CASE 
    WHEN OPC_VIA = 0 THEN 'Decevale'
    WHEN OPC_VIA = 1 THEN 'DCV'
END AS tiv_camara, fecha_compra fc, caso, httpo_id, tiv_codigo
FROM
(
SELECT p.fecha_compra, 'PROD null / EST null' AS caso, p.httpo_id, p.tiv_codigo, e.tiv_camara
FROM #TitulosSinCamaraProd p
LEFT JOIN #TitulosSinCamaraEst e ON e.httpo_id = p.httpo_id
WHERE p.tiv_camara IS NULL
  AND EXISTS (SELECT 1 FROM #TitulosSinCamaraEst e2
                  WHERE e2.httpo_id = p.httpo_id AND e2.tiv_camara IS NULL)
) AS d
JOIN BVQ_BACKOFFICE.TITULOS_PORTAFOLIO tpo ON tpo.TPO_ID = d.httpo_id
JOIN BVQ_BACKOFFICE.FONDO fon ON fon.FON_ID = tpo.FON_ID
LEFT JOIN BVQ_BACKOFFICE.OPERACIONES_CERRADAS oc ON fon.FON_NUMERO_LIQUIDACION = oc.OPC_NUM_OPE 
    AND year(TPO_FECHA_INGRESO) = OPC_ANO_OPE