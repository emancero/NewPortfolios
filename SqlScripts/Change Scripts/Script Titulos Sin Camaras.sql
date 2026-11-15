use sicavest
go
IF OBJECT_ID('tempdb..#TitulosSinCamaraProd') IS NOT NULL
    DROP TABLE #TitulosSinCamaraProd;

delete from [192.168.2.225].sicav.dbo.corteslist;
insert into [192.168.2.225].sicav.dbo.corteslist values('2025-12-31T23:59:59',1);
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




--create table _temp.bak2026nov13camara (tiv_id int unique,tiv_camara varchar(max))
print 'fix the bulk'
set XACT_ABORT on
begin distributed tran
go
    exec bvq_backoffice.generarcompraventaflujo
    select sum(valefe) from bvq_backoffice.portafoliocorte
    ;with a as(
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
            WHEN OPC_VIA = 1 THEN 'DCV-BCE'
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
        where opc_via is not null
    ), b as (
        select distinct
            Emisor=ems_nombre,Tipo=tvl_nombre,[Fecha de compra]=tpo_fecha_ingreso,Custodio=a.tiv_camara,tpo.tiv_id,caso
        from a
        join bvq_backoffice.titulos_portafolio tpo on tpo.tpo_id=a.httpo_id
        join bvq_administracion.titulo_valor tiv on tpo.tiv_id=tiv.tiv_id
        join bvq_administracion.tipo_valor tvl on tiv.tiv_tipo_valor=tvl.tvl_id
        join bvq_administracion.emisor ems on tiv_emisor=ems_id
    )
--order by tpo_fecha_ingreso,ems_nombre,tipo
    --select count(*) over (partition by tiv.tiv_id),tiv.tiv_id,tiv.tiv_camara,b.custodio,*--[fecha de compra],Emisor,Tipo,Custodio),*
    update tiv set tiv_camara=custodio
    from b
    left join /*sicavprod*/[192.168.2.225].sicav.bvq_administracion.titulo_valor tiv on tiv.tiv_id=b.tiv_id
    --order by 1 desc

    exec bvq_backoffice.generarcompraventaflujo
    select sum(valefe) from bvq_backoffice.portafoliocorte



--use sicavprod
--use sicavprod
if object_id('_temp.TitulosSinCamara') is not null
    drop table _temp.TitulosSinCamara
go
print 'rest'
select v.tiv_id,tiv.tiv_camara,montooper,v.htp_tpo_id,tpo.fon_id,tpo.TPO_FECHA_INGRESO,tpo.tpo_acta
,ems_nombre,tvl_nombre
--into _temp.TitulosSinCamara
FROM [192.168.2.225].sicav.bvq_backoffice.ObtenerDetallePortafolioConLiquidezView v
join [192.168.2.225].sicav.bvq_backoffice.titulos_portafolio tpo on tpo.tpo_id=v.htp_tpo_id
join [192.168.2.225].sicav.bvq_administracion.titulo_valor tiv on tpo.tiv_id=tiv.tiv_id
WHERE ISNULL(v.IPR_ES_CXC, 0) = 0
AND v.oper = 0 AND v.compra_htp_id = v.htp_id
and year(htp_fecha_operacion)=2025 and tiv.tiv_camara is null
and isnull(tpo.tpo_acta,'') not in ('BONSOB2035')
/*
print 'update the rest'
select distinct ems_nombre,tvl_nombre,tpo_fecha_ingreso
,coalesce(tiv.tiv_camara
,CASE 
    WHEN OPC_VIA = 0 THEN 'Decevale'
    WHEN OPC_VIA = 1 THEN 'DCV-BCE'
END) custodio
--,tpo_acta,fon_numeracion,tiv.tiv_camara,*
from _temp.TitulosSinCamara dst
left join sicavest.bvq_administracion.titulo_valor tiv
    on dst.tiv_id=tiv.tiv_id and tiv.tiv_camara is not null
left join sicavest.bvq_backoffice.fondo fon on fon.fon_id=dst.fon_id
LEFT JOIN sicavest.BVQ_BACKOFFICE.OPERACIONES_CERRADAS oc ON fon.FON_NUMERO_LIQUIDACION = oc.OPC_NUM_OPE 
    AND year(TPO_FECHA_INGRESO) = OPC_ANO_OPE
    and opc_via is not null
order by custodio,ems_nombre
--where tiv.tiv_camara is null and opc_via is null
*/
commit tran

