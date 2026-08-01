CREATE view BVQ_BACKOFFICE.LiqIntProv as
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
		,liq_rendimiento=max(liq_rendimiento)
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
			,TPO_PRECIO_EFECTIVO--=case when TIPO_RENTA=154 then prEfectivo else hist.TPO_PRECIO_EFECTIVO end
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
			*
			case when e.evp_abono=1 and e.es_vencimiento_interes=0 then
				e.vep_valor_efectivo
			else
				coalesce(capMonto,-montooper)
			end
		)
	,2)
	--o valefe+comisiones

 
	,intacc=
	--round(
		--case when tvl_codigo not in ('PCO','FAC') then
			case when es_vencimiento_interes=1 then

				--depósito total capital+interés
					--depósito de interés:
					coalesce(nullif(e.vep_valor_efectivo,0), amount)
					+
					--depósito de capital:
					case when tvl_codigo in ('PCO','FAC') and tasa_cupon=0 and isnull(e.ipr_es_cxc,0)=0 then
						hist_precio_compra/100.0 * htp_compra
					else
						coalesce(capMonto,case when isnull(evp_abono,0)=0 then -montooper else 0 end)
					end
					+case when isnull(evp_abono,0)=1 then isnull(ufo_rendimiento-pr,0) else 0 end
				--fin depósito total capital+interés

				-
				round(
					coalesce(
						EVP_AJUSTE_VALOR_EFECTIVO
						,prEfectivo
						*coalesce(capMonto,case when isnull(evp_abono,0)=0 then -montooper else 0 end)
					)
				,2)
				-
				case when isnull(evp_abono,0)=0 then case when isnull(ipr_es_cxc,0)=0 then -1 else 1 end * isnull(UFO_USO_FONDOS,0) else 0 end
				-case when isnull(evp_abono,0)=0 then pr else 0 end

				--itrans con exclusiones especiales
				-case when tpo_fecha_ingreso>TFL_FECHA_INICIO
				and htp_tpo_id not in (2268,2269)
				and not exists(
					select * from BVQ_BACKOFFICE.SIN_INT_TRANS
					where TPO_NUMERACION=SIT_NUMERACION
					and convert(varchar,fecha,20)=SIT_FECHA
				)
					--and htp_tpo_id not in (2408,2409 ,2410,2411,2412 ,2413,2414,2415 ,2417,2418,2419)--not (isnull(evp_abono,0)=1 and htp_tpo_id in (2409,2410,2411,2412) and pr=0)
				then ISNULL(itrans,0) else 0 end
				--Fin itrans con exclusiones especiales

			else
				orgIAmortizacion-pr
			end
 
	,prov=pr
	,fechaIni=fecha,prop=convert(float,day(e.fecha))/e.dias_cupon
	,e.*
	,prov2=orgIAmortizacion-pr
	,valor_pago_cupon=
		case when tiv_tipo_renta<>154 and es_vencimiento_interes=1 then
			case when evp_abono=1 then --isnull(prEfectivo*capMonto,0)+vep_valor_efectivo-isnull(capMonto,0)--vep_valor_efectivo=(ie+pr);in=ve+(ie+pr+uf)-vn
				--ve
				round(
					coalesce(
						 e.ajusteVe
						,prEfectivo*isnull(e.vn,0)
					)
				,2)
				+pr--prv
				+round(iif(e.fecha>='20250730', isnull(ufo_uso_fondos,0), 0)+coalesce(nullif(e.vep_valor_efectivo,0), amount)+isnull(ufo_rendimiento-pr,0),2)--ia
				-round(isnull(e.vn,0),2)--vn
			else
				coalesce(nullif(e.vep_valor_efectivo,0),amount)
			end
		end
				--in=ve+ie+pr+uf-vn; in-pr-uf=ie-(vn-ve);
		--ie=in+(vn-ve)-pr-uf
		--la ganancia (no de interés) de la recuperación es la diferencia entre el vn y el ve del capital (vn-ve)
		--entonces esta ganacia se suma al interés nominal para se refleje en el interés efectivo
		--se resta la provisión y uso de fondos para que solo quede el interés efectivo del mes
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


			                  
			,descAm=-((1-l.hist_precio_compra/100.0)-case when /*e.es_vencimiento_interes*/0=0 then comisiones/(htp_compra+iif(htp_tpo_id in (2427,2547),1e-6, 0)) else 0 end)*montooper
			,l.htp_compra,l.hist_fecha_compra,l.hist_precio_compra
			,l.comisiones,l.por_ord
			,precio_efectivo=coalesce(
				l.TPO_PRECIO_EFECTIVO
				,case when l.hist_fecha_compra>='20220601' then (l.val_efe_compra+l.comisiones)/(l.htp_compra+iif(htp_tpo_id in (2427,2547),1e-6,0))*100.0 else l.hist_precio_compra end
			)
			,tiv.tiv_tipo_renta
			,l.plazo
			,capMonto
			,l.plazo_anterior
			--campos de evtCap
			,vn
			,ajusteVe
			from costo l
			join
			bvq_backoffice.evttemp e
			on l.htp_id=e.htp_id and l.es_vencimiento_interes=e.es_vencimiento_interes
			left join (select tiv_id,tiv_tipo_renta from bvq_administracion.titulo_valor tiv) tiv on tiv.tiv_id=e.tiv_id
			left join (
				select capMonto=evp_valor_efectivo,capHtpId=evt_id
				from bvq_backoffice.evento_portafolio
				where es_vencimiento_interes=0 and isnull(evp_abono,0)=0
			) eCap on isnull(e.evp_abono,0)=0 and ecap.capHtpId=e.htp_id
			--evtCap
			left join (
				select vn=nullif(vep_valor_efectivo,0)
				,ajusteVe=EVP_AJUSTE_VALOR_EFECTIVO
				,etempHtpId=htp_id
				,etempFecha=fecha from bvq_backoffice.evtTemp where es_vencimiento_interes=0 and htp_tiene_valnom=1
			) evtCap
			on evtCap.etempHtpId=e.htp_id and evtCap.etempFecha=e.fecha and e.tipo_renta=153
		) s
	) e
	--where tpo_numeracion='MDF-2013-12-19' and fecha='20231219'