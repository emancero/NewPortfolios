CREATE PROCEDURE [bvq_backoffice].[ObtenerReporteCesionDerechosFiduciarios]
	@fecha_corte DATE='20260830',
	@i_lga_id INT=null
AS
begin


--universo: estos son los que se consideran -todos- los derechos fid. que pueden tener un pago a futuro
--pues tenían saldo en la fecha de migración 20240830

--delete from corteslist;insert into corteslist values ('20240830',1)
--drop table _temp.ocxc
--select * into _temp.ocxc from bvq_backoffice.otrascuentasporcobrarview o


--select * from bvq_backoffice.titulos_portafolio where tpo_f1 between 202 and 204
--select * from bvq_backoffice.historico_titulos_portafolio where htp_tpo_id between 909 and 911

;with ant as(
    select id=cdf_id_inversion,* from bvq_backoffice.CDF_MATRIZ_CESION_DERECHOS_FID
)
,a as(
    select --c=count(*) over (partition by cdf_id_inversion,cdf_fecha_cesion,CDF_FECHA_VENCIMIENTO_RECOMPRA)
    --,df=max(cdf_saldo_por_recuperar_capital) over (partition by cdf_id_inversion,cdf_fecha_cesion,CDF_FECHA_VENCIMIENTO_RECOMPRA)
    ---min(cdf_saldo_por_recuperar_capital) over (partition by cdf_id_inversion,cdf_fecha_cesion,CDF_FECHA_VENCIMIENTO_RECOMPRA)
    --,round(stdev(cdf_saldo_por_recuperar_capital) over (partition by cdf_id_inversion,cdf_fecha_cesion,CDF_FECHA_VENCIMIENTO_RECOMPRA),6)
     cdf_fecha_pago,cdf_id_inversion
     ,cdf_fecha_cesion=--case when cdf_fecha_cesion is null then case when cdf_id_inversion in (423,428) then '20181207' end else cdf_fecha_cesion end
     (
        select top 1 cdf_fecha_cesion from ant
        where ant.cdf_fecha_cesion is not null and cdf.cdf_id_inversion=ant.id
        and ant.cdf_id<=cdf.cdf_id
        order by ant.cdf_id desc
    )
     ,cdf_fecha_vencimiento_recompra=--case when cdf_fecha_vencimiento_recompra is null then case when cdf_id_inversion in (423) then '20191202' when cdf_id_inversion in (423)  then '20200602' end
        --else cdf_fecha_vencimiento_recompra end
    (
        select top 1 cdf_fecha_vencimiento_recompra from ant
        where ant.cdf_fecha_vencimiento_recompra is not null and cdf.cdf_id_inversion=ant.id
        and ant.cdf_id<=cdf.cdf_id
        order by ant.cdf_id desc
    )

     --,CDF_FECHA_VENCIMIENTO_RECOMPRA
    ,CDF_SALDO_POR_RECUPERAR_CAPITAL=CDF_SALDO_POR_RECUPERAR_CAPITAL
    ,mn.nombre_sistema
    ,cdf.cdf_nombre_fideicomiso
    --,
    --select *
    ,cdf_por_siglas=case cdf_fondo_pertenece when 'Fondo Reserva' then '5FR' when 'Vida Activos' then '3SVA' else null end

, cdf_desembolso_recursos_isspol
, cdf_fila_excel
--, cdf_fondo_pertenece
--, cdf_capital_renovado
, cdf_id
, cdf_rendimiento_interes
, CDF_PLAZO_RECOMPRA_DIAS
, CDF_ESTADO
, CDF_CAPITAL_RENOVADO
, CDF_FECHA_PAGO_DETALLE
, CDF_CAPITAL_RECUPERADO
, CDF_INTERESES_PAGADOS
, CDF_CAPITAL_IMPAGO
, CDF_INTERESES_IMPAGOS
, CDF_REGISTRO_CONTABLE_SALDO
, CDF_VALORACION_UTILIDAD_DETERIORO
, CDF_PCT_CONSTITUCION_UTILIDAD
, CDF_FONDO_PERTENECE
    from BVQ_BACKOFFICE.CDF_MATRIZ_CESION_DERECHOS_FID cdf
    left join _temp.mapeo_nombres mn on cdf.CDF_NOMBRE_FIDEICOMISO=mn.cdf_nombre_fideicomiso
    --left join (values(),(),()) s 
    --XXX
    --where CDF_SALDO_POR_RECUPERAR_CAPITAL>0-- and o.decreto_emisor is null
)
--select * from _temp.mapeo_nombres where cdf_nombre_fideicomiso like '%adokasa%'
--select * from bvq_backoffice.cdf_matriz_cesion_derechos_fid where cdf_nombre_fideicomiso like '%adokasa%'
--where CDF_SALDO_POR_RECUPERAR_CAPITAL>0-- is null-->0

, fileConSaldos as(
    select c=count(*) over (partition by cdf_id_inversion,cdf_fecha_cesion,CDF_FECHA_VENCIMIENTO_RECOMPRA),*
    from a
    --where isnull(CDF_SALDO_POR_RECUPERAR_CAPITAL,0)>0-->0 --quitar hace que se hagan 178
), b as(
    select distinct
     cdf_id_inversion
    ,cdf_fecha_cesion,cdf_fecha_vencimiento_recompra
    ,cdf_saldo_por_recuperar_capital,nombre_sistema,cdf_por_siglas
    ,cdf_nombre_fideicomiso
    from fileConSaldos
    --where not (c>1 and cdf_fecha_cesion is null)--filtra grupos (de más de una fila) sin celda combinada en fecha de cesión
)
--select * from b where CDF_SALDO_POR_RECUPERAR_CAPITAL>0-- where nombre_sistema like '%gio%'
--1578,1594,1610
--select rank() over (partition by cdf_id_inversion order by cdf_fecha_cesion desc),cdf_id_inversion,cdf_fecha_cesion,cdf_saldo_por_recuperar_capital from b
--order by b.cdf_id_inversion

, ocxc as(
    select --distinct
    cnt=count(*) over (partition by o.decreto_emisor,o.fecha_valor_de_compra,o.fecha_vencimiento_original,desg)
    ,valor_nominal=sum(valor_nominal_fix) over (partition by o.decreto_emisor,o.fecha_valor_de_compra,o.fecha_vencimiento_original,desg)
    ,decreto_emisor,fecha_valor_de_compra,o.fecha_vencimiento_original,desg,por_siglas--=case when desg in (49,50,51) then por_siglas end--,htp_compra--,*
    ,desglosarb,tpo_f1,fon_id
    ,htp_compra=sum(htp_compra) over (partition by o.decreto_emisor,o.fecha_valor_de_compra,o.fecha_vencimiento_original,desg)
    ,yield
    ,tfcorte
    from (
        select
         desg=case when tpo_f1 in (49,50,51/*plaza*/, 83,84,179,180/*centinela*/, 202,203,204) then tpo_f1 else 0 end
        ,valor_nominal_fix=iif(tpo_f1 in (202,203,204/*pura vida*/),valor_nominal-otros_costos,valor_nominal)
        ,* from _temp.ocxc outer apply (select fon_id from bvq_backoffice.fondo where fon_numeracion=desglosarb) fon
        --where decreto_emisor like '%pura vida%'
    ) o where tvl_codigo='der' --order by 1 desc
    --order by cnt desc
)
,cxcRank as(
    select rnkSis=rank() over (order by decreto_emisor,fecha_valor_de_compra,fecha_vencimiento_original)
    ,* from ocxc
)

--select * from cxcrank where rnksis=1

, c as(
    select 
    dFechaCesion=iif(o.fecha_valor_de_compra=b.cdf_fecha_cesion,0,1),
    dFechaVencimiento=iif(o.fecha_vencimiento_original=b.cdf_fecha_vencimiento_recompra,0,1),
    dSaldo=case when abs(round(o.valor_nominal-b.cdf_saldo_por_recuperar_capital,1))=0 then 0 else 1 end,--,0,1),
    dPor=case when cdf_por_siglas is null then 0 when por_siglas=cdf_por_siglas then 0 else 1 end,
    rnk=rank() over (order by cdf_id_inversion,cdf_fecha_cesion,CDF_FECHA_VENCIMIENTO_RECOMPRA),
    --rnkSis=rank() over (order by decreto_emisor,fecha_valor_de_compra,fecha_vencimiento_original),
    *
    from b
    left join cxcRank o on CDF_SALDO_POR_RECUPERAR_CAPITAL>0
    and o.decreto_emisor=b.nombre_sistema
    
    and o.fecha_valor_de_compra=b.cdf_fecha_cesion
    and o.fecha_vencimiento_original=b.cdf_fecha_vencimiento_recompra
    and abs(round(o.valor_nominal-b.cdf_saldo_por_recuperar_capital,1))=0
    and (cdf_por_siglas is null or por_siglas=cdf_por_siglas)
    left join (select o2_desglosarb=desglosarb,o2_valor_nominal=valor_nominal,o2_tpo_f1=tpo_f1 from cxcrank) o2 on o.decreto_emisor is null and CDF_SALDO_POR_RECUPERAR_CAPITAL>0
        and (
            abs(round(o2.o2_valor_nominal-b.cdf_saldo_por_recuperar_capital,1))=0
            or cdf_id_inversion=63 and o2_desglosarb like 'CONSORCIO_TPB-2018-11-26%'
        )

    --and o.FECHA_VALOR_DE_COMPRA=b.CDF_FECHA_CESION
    --and o.FECHA_Vencimiento_original=b.CDF_FECHA_VENCIMIENTO_RECOMPRA
    --where b.nombre_sistema is null or o.decreto_emisor is null
    --join _temp.mapeo_nombres mn on b.cdf_no
)
, d as(
    select
        --desglosarb,
        tfcorte,
        --htp_compra_in=case when cdf_desembolso_recursos_isspol is not null then htp_compra end,
        --cdf_desembolso_recursos_isspol,
        --valor_nominal,

        cdf_fondo_pertenece=case cdf_fila_excel when 276 then 'Vida Contratado' when 346 then 'Fondo Reserva' when 355 then 'Fondo Reserva' else cdf_fondo_pertenece end,
        cdf_capital_renovado,
        numeracion				= desglosarb,
        CDF_ID					= cdf.cdf_id,
        fila_excel				= cdf.cdf_fila_excel,--null,
        id_inversion			= cdf.CDF_ID_INVERSION,
        nombre_fideicomiso		= cdf.CDF_NOMBRE_FIDEICOMISO,
        desembolso_recursos		= coalesce(null/*htp_compra*/, cdf_desembolso_recursos_isspol),
        rendimiento				= coalesce(yield, cdf_rendimiento_interes*100.0),
        fecha_cesion			= coalesce(FECHA_VALOR_DE_COMPRA, cdf.cdf_fecha_cesion),
        plazo_recompra			= COALESCE(DATEDIFF(d, fecha_valor_de_compra, fecha_vencimiento_original), cdf.CDF_PLAZO_RECOMPRA_DIAS),
        fecha_vencimiento		= COALESCE(fecha_vencimiento_original, cdf.CDF_FECHA_VENCIMIENTO_RECOMPRA),
        estado					= CASE WHEN fecha_vencimiento_original is not null then
                case when tfcorte < fecha_vencimiento_original THEN 'Vigente' ELSE 'Vencido' END
            else
                cdf.CDF_ESTADO
            end,
        pagos_capital			= 'Un solo pago',
        capital_renovado_raw	= COALESCE(htp_compra, cdf.CDF_CAPITAL_RENOVADO),
        fecha_pago				= COALESCE(null, cdf.CDF_FECHA_PAGO_DETALLE),
        capital_recuperado_raw	= COALESCE(null, cdf.CDF_CAPITAL_RECUPERADO),
        intereses_pagados_raw	= COALESCE(null, cdf.CDF_INTERESES_PAGADOS),
        saldo_recuperar			= COALESCE(VALOR_NOMINAL, cdf.CDF_SALDO_POR_RECUPERAR_CAPITAL),
        capital_impago			= COALESCE(VALOR_NOMINAL, cdf.CDF_CAPITAL_IMPAGO),
        interes_impagos 		= COALESCE(null, cdf.CDF_INTERESES_IMPAGOS),
        registro_contable		= COALESCE(VALOR_NOMINAL, cdf.CDF_REGISTRO_CONTABLE_SALDO),
        valoracion				= COALESCE(VALOR_NOMINAL, cdf.CDF_VALORACION_UTILIDAD_DETERIORO),
        porcentaje_constitucion	= COALESCE(100.0, cdf.CDF_PCT_CONSTITUCION_UTILIDAD),
        fondo					= COALESCE(por_siglas, cdf.CDF_FONDO_PERTENECE),
        error_desembolso        = cdf_desembolso_recursos_isspol - htp_compra
    --from c

    from a cdf--bvq_backoffice.CDF_MATRIZ_CESION_DERECHOS_FID cdf
    left join c
    on cdf.cdf_nombre_fideicomiso=c.cdf_nombre_fideicomiso
    and cdf.cdf_fecha_cesion=c.cdf_fecha_cesion
    and cdf.cdf_fecha_vencimiento_recompra=c.cdf_fecha_vencimiento_recompra
    and cdf.cdf_saldo_por_recuperar_capital=c.cdf_saldo_por_recuperar_capital
        
        --and cdf.CDF_FECHA_PAGO_DETALLE=det.fecha
)
, e as(
    select
     filaEnInversion=rank() over (partition by id_inversion order by isnull(fecha_cesion,'29991231'), fecha_vencimiento,cdf_fondo_pertenece)
    ,filaEnConvenio=row_number() over (partition by id_inversion,fecha_cesion, fecha_vencimiento,cdf_fondo_pertenece order by cdf_id)
    ,filaEnExcelRow=row_number() over (partition by fila_excel order by cdf_id)
    ,* from d--distinct d.id_inversion,desembolso_recursos from d
) /*select
    capital_renovado=case when filaEnInversion=1 and not (id_inversion in (192) and fecha_cesion in ('20170629','20170622')) then 0 else
        capital_renovado_raw
    end
,sumd=sum(desembolso_recursos) over (order by fila_excel)
,**/
, newPagos as(
    select
    fecha=null,
    tfcorte
    ,
      cdf_fondo_pertenece
    , cdf_capital_renovado
    , numeracion
    , CDF_ID
    , fila_excel
    , id_inversion
    , nombre_fideicomiso
    , desembolso_recursos
    , rendimiento
    , fecha_cesion
    , plazo_recompra
    , fecha_vencimiento
    , estado
    , pagos_capital
    , capital_renovado_raw
    , fecha_pago
    , capital_recuperado_raw
    , intereses_pagados_raw
    , saldo_recuperar
    , capital_impago
    , interes_impagos
    , registro_contable
    , valoracion
    , porcentaje_constitucion
    , fondo=cdf_fondo_pertenece
    , error_desembolso
    , filaEnExcelRow
    , filaEnConvenio
    , filaEnInversion
    from e
    where 1=1
    union all
    select
    det.fecha,
    tfcorte=@fecha_corte
    ,
      cdf_fondo_pertenece
    , cdf_capital_renovado=null
    , numeracion
    , CDF_ID=1e4
    , fila_excel
    , id_inversion
    , nombre_fideicomiso
    , desembolso_recursos=null
    , rendimiento
    , fecha_cesion
    , plazo_recompra
    , fecha_vencimiento
    , estado
    , pagos_capital
    , capital_renovado_raw=null
    , fecha_pago=det.fecha
    , capital_recuperado_raw=capital--null
    , intereses_pagados_raw=iamortizacion
    , saldo_recuperar
    , capital_impago
    , interes_impagos
    , registro_contable
    , valoracion
    , porcentaje_constitucion
    , fondo=cdf_fondo_pertenece
    , error_desembolso
    , filaEnExcelRow
    , filaEnConvenio
    , filaEnInversion
    from e
    JOIN (select capital,iamortizacion,tpo_numeracion,fecha from _temp.bvq_backoffice__DetalleRecuperacionesIsspol) det
        ON numeracion = det.tpo_numeracion and
        det.fecha>'20240830' and det.fecha <= @fecha_corte
        and filaEnCOnvenio=1 and filaEnExcelRow=1
    where 1=1
    --and numeracion like '%tesla%1%'
        --and not exists(
        --    select * from bvq_backoffice.CDF_MATRIZ_CESION_DERECHOS_FID
        --    --where CDF_CAPITAL_RECUPERADO=44669.43
        --                --where CDF_ID_INVERSION=423 and CDF_FECHA_CESION='20181207' and CDF_FECHA_VENCIMIENTO_RECOMPRA='20191202'-- and CDF_FECHA_PAGO_DETALLE='20240430'

        --    where e.id_inversion=CDF_ID_INVERSION and e.fecha_cesion=CDF_FECHA_CESION and e.fecha_vencimiento=CDF_FECHA_VENCIMIENTO_RECOMPRA and fecha=CDF_FECHA_PAGO_DETALLE
        --)
)
,f as (
    select cc=count(distinct id_inversion),minid=min(id_inversion)+1,maxid=max(id_inversion),nombre_fideicomiso,fecha_cesion,fecha_vencimiento,cdf_fondo_pertenece--,fondo
    from e
    --where nombre_fideicomiso like '%moretti%'
    group by nombre_fideicomiso,fecha_cesion,fecha_vencimiento,cdf_fondo_pertenece
    having count(distinct id_inversion)>1 and fecha_cesion is not null
    and abs(min(id_inversion)-max(id_inversion))<4
    --order by id_inversion,fila_excel,fecha_pago
),g  as (
    select
    --f2=fecha,fp=fecha_pago,
    --det_capital=capital--case when filaEnExcelRow=1 then capital end
    --,det_interes=iamortizacion
    --,
    intereses_pagados=case when filaEnExcelRow=1--filaEnConvenio=1 or filaEnExcelRow>1
    then
        intereses_pagados_raw
    end
    ,
    capital_recuperado=case when filaEnExcelRow=1--filaEnConvenio=1 or filaEnExcelRow>1
    then
        capital_recuperado_raw
    end
    ,
    capital_renovado_file=case when filaEnConvenio=1
        --and fila_excel not in (77,78,363,391,394 ,201,210,219)
    then--not (id_inversion in (192) and fecha_cesion in ('20170629','20170622')) then 0 else
        cdf_capital_renovado--capital_renovado_raw
    end
    ,
    capital_renovado=case
    when filaEnConvenio=1 and fila_excel in (77,78,363,391,394 ,201,210,219) then --prueba: no hay desembolsos seguidos con renovación
        cdf_capital_renovado
    when filaEnConvenio=1 and filaEnInversion>1
    --and fila_excel not in (443,447)
    then--not (id_inversion in (192) and fecha_cesion in ('20170629','20170622')) then 0 else
        capital_renovado_raw--capital_renovado_raw
        +case when fila_excel=90 then 392175 else 0 end --prueba: en el archivo general estaría mal se renovó 720000 (327825/*htp_compra en original*/+392175)
    end
    ,
    sumd=sum(desembolso_recursos) over (order by fila_excel)
    ,*
    --into _temp.IdInversionErr
    from newPagos --join bvq_backoffice.cdf_matriz_cesion_derechos_fid s on s.cdf_fila_excel between minid and maxid
)
--select * from g where nombre_fideicomiso like '%tesla%'

select case when fecha_cesion is not null then fecha_cesion end,fila_excel,sum(capital_renovado) over (order by cdf_id)
,sum(capital_recuperado) over (order by cdf_id)--,sum(capital_renovado)--,sum(capital_renovado_sis)--id_inversion,fila_excel--,valor_nominal--,format(sum(capital_renovado) over (order by cdf_id),'n2')
,sum(intereses_pagados) over (order by cdf_id)--,sum(capital_renovado)--,sum(capital_renovado_sis)--id_inversion,fila_excel--,valor_nominal--,format(sum(capital_renovado) over (order by cdf_id),'n2')
,
*--/1e6
from g
--order by cdf_id
--where fecha_cesion is null--fondo is null--fecha_vencimiento is null
--*
order by id_inversion,g.fila_excel,filaEnExcelRow,fecha_cesion,fecha_vencimiento,fecha_pago--fila_excel,fecha_pago----cdf_fecha_cesion,d.cdf_fecha_vencimiento_recompra
end
