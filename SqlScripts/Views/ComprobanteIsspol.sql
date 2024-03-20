create  view [BVQ_BACKOFFICE].[ComprobanteIsspol] as  
 with LiqComprob as(  
  select
   tpo_numeracion  
  ,tiv_id  
  ,fecha  
  ,oper  
  ,htp_id  
  ,tipPap
  ,s.por_id
  ,es_vencimiento_interes
  ,prefijo  
  ,tasa_cupon,fechaini,diasTrans=datediff(d,fechaIni,fecha),dias_cupon,iamortizacion,prop  
  ,cuenta=case when tipo='C' then acreedoraSinAux when tipo='D' then deudoraSinAux end  
  ,aux=case when tipo='C' then acreedoraAux when tipo='D' then deudoraAux end  
  ,nombre=case when tipo='C' then nomAcreedora when tipo='D' then nomDeudora end  
  ,debe=case when tipo='D' then round(abs(monto),2) end  
  ,haber=case when tipo='C' then round(abs(monto),2) end  
  ,saldo,htp_compra  
  ,ems_nombre
  ,tvl_nombre
  ,fecha_compra
  ,tiv_fecha_vencimiento
  ,tiv_fecha_emision  
  ,monto
  ,hist_fecha_compra
  ,hist_precio_compra
  ,por_ord
  ,valefeoper  
  ,rubro--=case when tipo='D' and deudora like '2.1.90.03.%' then null else rubro end  
  ,rubroOrd=s.ord--case when tipo='D' and deudora like '2.1.90.03.%' then null else s.ord end  
  ,tipo  
  ,tfl_fecha_inicio_orig  
  ,isnull(comisiones,0) as comisiones  
  ,ICR_CODIGO  
  ,htp_tpo_id  
  ,plazo  
  ,precio_efectivo
  ,ipr_es_cxc
  ,deterioro
  ,itrans
  ,evp_referencia
  ,UFO_USO_FONDOS
  ,UFO_RENDIMIENTO
  ,TPO_BOLETIN

  ,TPO_FECHA_COMPRA_ANTERIOR
  ,TPO_PRECIO_COMPRA_ANTERIOR
  ,TPO_FECHA_VENCIMIENTO_ANTERIOR
  ,plazo_anterior
  ,TPO_TABLA_AMORTIZACION
  ,provision
  ,intacc
  ,TFL_PERIODO
  ,htp_fecha_operacion
  --select distinct por_id  
  from bvq_backoffice.comprobanteIsspolRubros s 
  where ipr_es_cxc = 1 or (ipr_es_cxc is null or ipr_es_cxc = 0 ) and deterioro = 0
 )  
 select distinct
  tpo_numeracion
 ,tiv_id
 ,oper
 ,fecha
 ,tipPap
 ,cuenta
 ,nombre
 ,debe
 ,haber
 ,saldo
 ,htp_compra  
 ,ems_nombre
 ,tvl_nombre
 ,fecha_compra
 ,tiv_fecha_vencimiento
 ,tasa_cupon
 ,tiv_fecha_emision
 ,rubro,monto  
 ,rubroOrd  
 ,valefeoper
 ,hist_precio_compra
 ,hist_fecha_compra
 ,por_ord
 ,tipo
 ,aux  
 ,tfl_fecha_inicio_orig  
 ,comisiones  
 --  
 --,(hist_precio_compra + (comisiones/htp_compra)) / 100.0 as precio_efectivo  
 ,precio_efectivo  
 ,ICR_CODIGO
 ,htp_tpo_id
 ,tvl_codigo=tippap  
 ,ri=null  
 ,plazo  
 ,ipr_es_cxc
 ,deterioro
 ,itrans
 ,evp_referencia
 ,UFO_USO_FONDOS
 ,UFO_RENDIMIENTO
 ,TPO_BOLETIN

 ,TPO_FECHA_COMPRA_ANTERIOR
 ,TPO_PRECIO_COMPRA_ANTERIOR
 ,TPO_FECHA_VENCIMIENTO_ANTERIOR
 ,plazo_anterior
 ,TPO_TABLA_AMORTIZACION
 ,provision
 ,intacc
 ,TFL_PERIODO
 ,htp_fecha_operacion
 from liqComprob where  
 (  
  (  
   tipo='C' or tipo='D' and cuenta<>'2.1.90.03'  
  )  
  and not (  
   tipo='D' and cuenta='2.1.90.03'  
   or tipo='D' and cuenta like'7.1.5.03.%'  
   or tipo='C' and cuenta like'2.1.02.%'  
  )  
  or cuenta is null  
 )  
 and (isnull(debe,0)+isnull(haber,0)>0  
 or rubro='amount' or rubro='valnom' or rubro='montooper')
 --where tippap='CD' and oper=1  
 union all
 select
  tpo_numeracion
 ,tiv_id,oper
 ,fecha
 ,tipPap
 ,cuenta
 ,nombre
 ,debe=sum(debe)
 ,haber=sum(haber)
 ,saldo=null
 ,htp_compra=null  
 ,ems_nombre
 ,tvl_nombre
 ,fecha_compra
 ,tiv_fecha_vencimiento
 ,tasa_cupon
 ,tiv_fecha_emision
 ,rubro=null
 ,monto=null  
 ,rubroOrd=min(rubroOrd)  
 ,valefeoper=null
 ,hist_precio_compra
 ,hist_fecha_compra
 ,por_ord=null
 ,tipo,aux  
 ,tfl_fecha_inicio_orig  
 ,sum(isnull(comisiones,0)) as comisiones  
 --,(hist_precio_compra + ((sum(comisiones)/min(htp_compra))) * 100) as precio_efectivo  
 ,precio_efectivo  
 ,ICR_CODIGO
 ,htp_tpo_id
 ,tvl_codigo=tippap  
 ,ri
 ,plazo
 ,ipr_es_cxc
 ,deterioro
 ,itrans
 ,evp_referencia
 ,UFO_USO_FONDOS=null
 ,UFO_RENDIMIENTO=null
 ,TPO_BOLETIN=MAX(TPO_BOLETIN)
 ,TPO_FECHA_COMPRA_ANTERIOR
 ,TPO_PRECIO_COMPRA_ANTERIOR
 ,TPO_FECHA_VENCIMIENTO_ANTERIOR
 ,plazo_anterior
 ,TPO_TABLA_AMORTIZACION = max(TPO_TABLA_AMORTIZACION)
 ,provision=max(provision)
 ,intacc=max(intacc)
 ,TFL_PERIODO=max(TFL_PERIODO)
 ,htp_fecha_operacion=max(htp_fecha_operacion)
 from liqComprob  
 join (select '2.1.90.03' pr, 'DIDENT' ri union select '7.1.5.03.%','CUXC' union select '2.1.02.%','CUXP') ri  
 on cuenta like pr  
 where  
 (  
     tipo='D' and cuenta='2.1.90.03'  
  or tipo='D' and cuenta like '7.1.5.03.%'  
  or tipo='C' and cuenta like '2.1.02.%'  
  or cuenta is null  
 )  
 --where tippap='CD' and oper=1  
 group by
  tpo_numeracion
 ,tiv_id
 ,oper
 ,fecha
 ,tipPap  
 --,cuenta,nombre  
 ,ems_nombre
 ,tvl_nombre
 ,fecha_compra
 ,tiv_fecha_vencimiento
 ,tasa_cupon
 ,oper
 ,tiv_fecha_emision  
 --,monto  
 ,hist_fecha_compra
 ,hist_precio_compra
 ,cuenta
 ,nombre
 ,tipo
 ,aux
 ,tfl_fecha_inicio_orig  
 ,ICR_CODIGO  
 ,htp_tpo_id
 ,ri
 ,plazo
 ,ipr_es_cxc
 ,precio_efectivo
 ,deterioro
 ,itrans
 ,evp_referencia
 ,TPO_FECHA_COMPRA_ANTERIOR
 ,TPO_PRECIO_COMPRA_ANTERIOR
 ,TPO_FECHA_VENCIMIENTO_ANTERIOR
 ,plazo_anterior
  --having htp_id=3002050000075 
