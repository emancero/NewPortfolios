
CREATE PROCEDURE BVQ_BACKOFFICE.ObtenerComprobanteIsspol
(
@i_tpo_numeracion varchar(250),
@i_tiv_id int, 
@i_fecha datetime, 
@i_efectivo_siempre bit=false, 
@i_lga_id int=null
) 
AS
BEGIN  
 SELECT  
   tpo_numeracion  
  ,tiv_id  
  ,oper  
  ,fecha  
  --,htp_id  
  ,tipPap  
  ,cuenta  
  ,nombre  
  ,debe=sum(debe)
  ,haber=sum(haber)
  ,saldo
  ,htp_compra  
  ,ems_nombre
  ,tvl_nombre
  ,fecha_compra
  ,tiv_fecha_vencimiento
  ,tasa_cupon
  ,oper
  ,tiv_fecha_emision
  ,rubro,monto  
  ,hist_fecha_compra
  ,hist_precio_compra=max(hist_precio_compra)
  ,rubroOrd  
  ,tipo,por_ord,aux  
  --,sum(htp_compra) over (partition by rubro) totalCompra  
  ,sum(case when (sum(haber) is not null or cuenta like '7.1.3%') and deterioro=0 then htp_compra else 0 end) over (partition by rubro) totalCompra  
  ,tfl_fecha_inicio_orig  
  ,precio_efectivo=max(precio_efectivo)
  ,ICR_CODIGO  
  ,plazo
  ,ipr_es_cxc
  ,deterioro
  ,itrans
  ,evp_referencia
  ,UFO_USO_FONDOS=sum(UFO_USO_FONDOS)
  ,UFO_RENDIMIENTO=sum(UFO_RENDIMIENTO)
 FROM BVQ_BACKOFFICE.ComprobanteIsspol  
 WHERE tpo_numeracion=@i_tpo_numeracion and tiv_id=@i_tiv_id and fecha=@i_fecha  
 and not (@i_efectivo_siempre=0 and isnull(debe,0)=0 and isnull(haber,0)=0) --excluir mov sin afectación
 group by
   tpo_numeracion  
  ,tiv_id  
  ,oper  
  ,fecha  
  --,htp_id  
  ,tipPap  
  ,cuenta  
  ,nombre  
  --,debe  
  --,haber  
  ,saldo
  ,htp_compra  
  ,ems_nombre
  ,tvl_nombre
  ,fecha_compra
  ,tiv_fecha_vencimiento
  ,tasa_cupon
  ,oper
  ,tiv_fecha_emision
  ,rubro
  ,monto  
  ,hist_fecha_compra
  --,hist_precio_compra  
  ,rubroOrd  
  ,tipo
  ,por_ord
  ,aux  
  --,sum(htp_compra) over (partition by rubro) totalCompra  
  --,sum(case when haber is not null or cuenta like '7.1.3%' then htp_compra else 0 end) over (partition by rubro) totalCompra  
  ,tfl_fecha_inicio_orig  
  --,precio_efectivo  
  ,ICR_CODIGO  
  ,plazo
  ,ipr_es_cxc
  ,deterioro
  ,itrans
  ,evp_referencia
 --and oper=1  
 order by rubroOrd,tipo desc,por_ord  
END 