alter procedure BVQ_BACKOFFICE.GenerarValoracionSB AS
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
	,montooper=sum(htp_compra)
	,itrans=sum(itrans)
	,tpo_numeracion=htp_numeracion
	,oper=-1
	,htp_precio_compra=max(htp_precio_compra/case when tiv_tipo_renta=154 then 1 else 100 end)
	,tasa_cupon=max(tiv_tasa_interes)
	,liq_rendimiento=max(htp_rendimiento)
	,valorEfectivo=--sum(valEfeOper)
		sum(
			(case when min_tiene_valnom=1 or min_tiene_valnom=0 and httpo_id<1500 then

		  --isnull([TPO_INTERES_TRANSCURRIDO],0) + isnull([TPO_COMISION_BOLSA],0)
		  --+ [htp_compra]*[htp_precio_compra]
		  --+
		  coalesce(
			case when tpo_numeracion in ('ATX-2025-04-24','ATX-2025-04-25')
			then valnomCompraAnterior end,[montooper]
		  )
		  *
		  coalesce(
			case when tpo_numeracion in ('ATX-2025-04-24','ATX-2025-04-25')
			then precioCompraAnterior end, [htp_precio_compra]
		  )
		  /case when [tiv_tipo_renta]=153 then 100e else 1e end
	   end)
	   )

	,pc.tiv_id
	,fon_id=max(tpo.fon_id)
	,esCxc=max(isnull(ipr_es_cxc,0))
	,tpo_acta=max(pc.tpo_acta)
	,valor_pago_capital=null
	,valor_pago_cupon=null
	,Fecha_Ultimo_Pago=max(latest_inicio)
	,Saldo_Valor_Nominal=sum(sal)
	,Precio_de_mercado=sum(PRECIO_DE_HOY)
	,Valor_Mercado=sum(VALOR_NOMINAL)/sum(VALOR_UNITARIO)*sum(PRECIO_DE_HOY)+sum(INTERES_GANADO)
	,TPO_MANTIENE_VECTOR_PRECIO=max(convert(int,pc.TPO_MANTIENE_VECTOR_PRECIO))
	,evp_fecha_compra=min(pc.fecha_compra)
	from bvq_backoffice.portafolioCortePrcInt pc
	join bvq_backoffice.titulos_portafolio tpo on pc.httpo_id=tpo.tpo_id
	where sal>0 and isnull(ipr_es_cxc,0)=0
	--and tpo_numeracion like 'slu%'
	group by htp_numeracion,tfcorte,pc.tiv_id
	
END
