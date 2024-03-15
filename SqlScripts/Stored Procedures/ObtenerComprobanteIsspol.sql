
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
	 *
	FROM(
		SELECT  
		 tpo_numeracion  
		,tiv_id  
		,oper  
		,fecha  
		--,htp_id  
		,tipPap  
		,cuenta=coalesce(EDPI_CUENTA,cuenta) 
		,nombre=coalesce(EDPI_NOM_CUENTA,nombre)  
		,debe=sum(debe)
		,haber=sum(haber)
		,saldo
		,htp_compra  
		,ems_nombre
		,tvl_nombre
		,fecha_compra
		,tiv_fecha_vencimiento
		,tasa_cupon
		,tiv_fecha_emision
		,rubro,monto  
		,hist_fecha_compra
		,hist_precio_compra=max(hist_precio_compra)
		,rubroOrd  
		,tipo,por_ord
		,aux=coalesce(EDPI_AUX,aux) 
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
		,TPO_BOLETIN=max(TPO_BOLETIN)
		,TPO_FECHA_COMPRA_ANTERIOR
		,TPO_PRECIO_COMPRA_ANTERIOR
		,TPO_FECHA_VENCIMIENTO_ANTERIOR
		,plazo_anterior
		,TPO_TABLA_AMORTIZACION = max(TPO_TABLA_AMORTIZACION)
		,provision=max(provision)
		,intacc=max(intacc)
		,ri=max(ri)
		FROM BVQ_BACKOFFICE.ComprobanteIsspol ci
		left join BVQ_BACKOFFICE.EXCEPCIONES_DEP_POR_IDENTIFICAR edpi
		on edpi.edpi_numeracion=ci.tpo_numeracion and ci.cuenta='2.1.90.03'
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
		,TPO_FECHA_COMPRA_ANTERIOR
		,TPO_PRECIO_COMPRA_ANTERIOR
		,TPO_FECHA_VENCIMIENTO_ANTERIOR
		,plazo_anterior
		,EDPI_CUENTA
		,EDPI_NOM_CUENTA
		,EDPI_AUX
	) ci
	left join bvq_backoffice.Liquidez_Referencias_table ref on ci.tpo_numeracion=ref.tpo_numeracion and ci.fecha=ref.fecha
		and ci.ri in ('DIDENT','DIDENT02')
		and round(debe,1)=round(ref.valor,1)
	--and oper=1  
	order by deterioro,rubroOrd,tipo desc,por_ord  
END 