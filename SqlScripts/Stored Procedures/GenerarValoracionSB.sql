CREATE procedure BVQ_BACKOFFICE.GenerarValoracionSB AS
BEGIN
	truncate table BVQ_BACKOFFICE.VALORACION_SB
	insert into BVQ_BACKOFFICE.VALORACION_SB(
		 htp_fecha_operacion
		,montooper
		,itrans
		,tpo_numeracion
		,oper
		,htp_precio_compra
		,tasa_cupon
		,liq_rendimiento
		,valorEfectivo
		,tiv_id
		,fon_id
		,esCxc
		,tpo_acta
		,valor_pago_capital
		,valor_pago_cupon
		,Fecha_Ultimo_Pago
		,Saldo_Valor_Nominal
		,Precio_de_mercado
		,Valor_Mercado
		,TPO_MANTIENE_VECTOR_PRECIO
		,evp_fecha_compra
	)
	select
	 htp_fecha_operacion=tfcorte
	,montooper=sum(sal)
	,itrans=sum(itrans)
	,tpo_numeracion=htp_numeracion
	,oper=-1
	,htp_precio_compra=max(precio_de_hoy)
	,tasa_cupon=max(tiv_tasa_interes)
	,liq_rendimiento=max(htp_rendimiento)
	,valorEfectivo=sum(valEfeOper)
	,pc.tiv_id
	,fon_id=max(tpo.fon_id)
	,esCxc=max(isnull(ipr_es_cxc,0))
	,tpo_acta=max(pc.tpo_acta)
	,valor_pago_capital=null
	,valor_pago_cupon=null
	,Fecha_Ultimo_Pago=null
	,Saldo_Valor_Nominal=sum(sal)
	,Precio_de_mercado=sum(PRECIO_DE_HOY)
	,Valor_Mercado=sum(VALOR_NOMINAL)/sum(VALOR_UNITARIO)*sum(PRECIO_DE_HOY)+sum(INTERES_GANADO)
	,TPO_MANTIENE_VECTOR_PRECIO=max(convert(int,pc.TPO_MANTIENE_VECTOR_PRECIO))
	,evp_fecha_compra=min(pc.fecha_compra)
	select precio_de_hoy,*
	from bvq_backoffice.portafolioCortePrcInt pc
	join bvq_backoffice.titulos_portafolio tpo on pc.httpo_id=tpo.tpo_id
	where sal>0 and isnull(ipr_es_cxc,0)=0
	and tpo_numeracion like 'slu%'
	group by htp_numeracion,tfcorte,pc.tiv_id
	
END
