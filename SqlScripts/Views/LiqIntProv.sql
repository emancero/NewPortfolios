create view BVQ_BACKOFFICE.LiqIntProv as
	with LiqProp as
	(
		select
		 saldo=sum(monto)
		,htp_compra=max(case when r=1 then htp_compra end)
		,hist_fecha_compra=max(case when r=1 then hist_fecha_operacion end)
		,hist_precio_compra=max(case when r=1 then htp_precio_compra end)
		,val_efe_compra=max(case when r=1 then htp_compra*htp_precio_compra/100.0 end)
		,htp_id
		,es_vencimiento_interes
		,TPO_COMISION_BOLSA=max(case when r=1 then TPO_COMISION_BOLSA end)
		,TPO_COMISIONES=max(case when r=1 then TPO_COMISIONES end)
		,tpo_id=max(tpo_id)
		,por_ord
		,plazo=max(plazo)
		,TPO_PRECIO_EFECTIVO=max(TPO_PRECIO_EFECTIVO)
		,itrans=sum(itrans)
		,evp_referencia=max(evp_referencia)
		,plazo_anterior=max(plazo_anterior)
		from
		(
			--cross product
			select
			 monto=hist.montooper
			,e.*
			,por.por_ord
			,r=row_number() over (partition by e.htp_id,e.es_vencimiento_interes order by hist.fecha,hist.htp_id)
			,htp_compra
			,hist_fecha_operacion=hist.htp_fecha_operacion
			,htp_precio_compra
			,TPO_COMISION_BOLSA
			,TPO_COMISIONES,TPO_ID
			,plazo=dbo.fnDias(hist.htp_fecha_operacion,tiv_fecha_vencimiento,case when tvl_codigo in ('BE','VCC','OBL') then 354 else 355 end)
			,plazo_anterior=dbo.fnDias(hist.TPO_FECHA_COMPRA_ANTERIOR,hist.TPO_FECHA_VENCIMIENTO_ANTERIOR,case when tvl_codigo in ('BE','VCC','OBL') then 354 else 355 end)
			,TPO_PRECIO_EFECTIVO
			from bvq_backoffice.evttemp e
			join bvq_backoffice.portafolio por on e.por_id=por.por_id
			left join (
				select hist.montooper,hist.htp_tpo_id,hist.fecha,hist.htp_id
				,htp.htp_compra,htp.htp_fecha_operacion,htp.HTP_PRECIO_COMPRA,TPO_COMISION_BOLSA,TPO_COMISIONES,TPO_ID,TPO_PRECIO_INGRESO
				,TPO_PRECIO_EFECTIVO
				,TPO.TPO_FECHA_VENCIMIENTO_ANTERIOR
				,TPO.TPO_FECHA_COMPRA_ANTERIOR
				from bvq_backoffice.evttemp hist
				left join bvq_backoffice.historico_titulos_portafolio htp on htp.htp_id=hist.htp_id
				left join bvq_backoffice.titulos_portafolio tpo on tpo.tpo_id=htp.htp_tpo_id
				where isnull(hist.es_vencimiento_interes,0)=0
			) hist
			on hist.htp_tpo_id=e.htp_tpo_id
			and
			(
				hist.fecha<e.fecha
				or hist.fecha=e.fecha and hist.htp_id<e.htp_id
				or oper=0 and hist.htp_id = e.htp_id
			)
		) s
		group by s.htp_id,s.es_vencimiento_interes,por_ord--,evp_referencia --,s.fecha,s.dias_cupon
	)
	, Costo as (
		select comisiones=isnull(tpo_comision_bolsa,0)+isnull(tpo_comisiones,0)
		,* 
		from LiqProp
	)
	select
	--vep_valor_efectivo,
	amount0=amount,
	amountCosto=
	round(
		coalesce(
			EVP_AJUSTE_VALOR_EFECTIVO
			,prEfectivo
			*coalesce(capMonto,-montooper)
		)
	,2)
	--o valefe+comisiones

 
	,intacc=
	--round(
		--case when tvl_codigo not in ('PCO','FAC') then
			case when es_vencimiento_interes=1 then

				--depósito total capital+interés
					--depósito de interés
					coalesce(nullif(e.vep_valor_efectivo,0),amount)
					--depósito de capital
					+
					case when tvl_codigo in ('PCO','FAC') and tasa_cupon=0 then
						hist_precio_compra/100.0 * htp_compra
					else
						coalesce(capMonto,-montooper)
					end
				--fin depósito total capital+interes

				-
				round(
					coalesce(
						EVP_AJUSTE_VALOR_EFECTIVO
						,prEfectivo
						*coalesce(capMonto,-montooper)
					)
				,2)
				-
				isnull(UFO_USO_FONDOS,0)
				-pr
				-case when tpo_fecha_ingreso>TFL_FECHA_INICIO then ISNULL(itrans,0) else 0 end
			end
 
	,prov=pr
	,fechaIni=fecha,prop=convert(float,day(e.fecha))/e.dias_cupon
	,e.*
	,prov2=orgIAmortizacion-pr
	from
	(
		select
		 pr=s.provision
		,orgIAmortizacion=iamortizacion+descAm
		,*
		from(
			select e.*
			,diasTran=dbo.fnDias(case when hist_fecha_compra>TFL_FECHA_INICIO then hist_fecha_compra else tfl_fecha_inicio end,dateadd(d,-day(e.fecha),e.fecha),355)
			,diasInteres=case when tvl_codigo not in ('PCO','FAC') then convert(float,day(e.fecha)) else dias_cupon-dbo.fnDiasEu(hist_fecha_compra,dateadd(d,-day(e.fecha),e.fecha), 354) end


			                  
			,descAm=-((1-l.hist_precio_compra/100.0)-case when /*e.es_vencimiento_interes*/0=0 then comisiones/htp_compra else 0 end)*montooper
			,l.htp_compra,l.hist_fecha_compra,l.hist_precio_compra
			,l.comisiones,l.por_ord
			,precio_efectivo=coalesce(
				l.TPO_PRECIO_EFECTIVO
				,case when l.hist_fecha_compra>='20220601' then (l.val_efe_compra+l.comisiones)/l.htp_compra*100.0 else l.hist_precio_compra end
			)
			,tiv.tiv_tipo_renta
			,l.plazo
			,capMonto
			,l.plazo_anterior
			from costo l
			join
			bvq_backoffice.evttemp e
			on l.htp_id=e.htp_id and l.es_vencimiento_interes=e.es_vencimiento_interes
			left join (select tiv_id,tiv_tipo_renta from bvq_administracion.titulo_valor tiv) tiv on tiv.tiv_id=e.tiv_id
			left join (select capMonto=evp_valor_efectivo,capHtpId=evt_id from bvq_backoffice.evento_portafolio where es_vencimiento_interes=0 and isnull(evp_abono,0)=0) eCap on ecap.capHtpId=e.htp_id
		) s
	) e
	--where tpo_numeracion='MDF-2013-12-19' and fecha='20231219'
