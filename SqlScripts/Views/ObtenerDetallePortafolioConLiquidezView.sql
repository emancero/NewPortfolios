CREATE view bvq_backoffice.ObtenerDetallePortafolioConLiquidezView as

	select
	evt.nombre,
	evt.por_codigo,
	evt.liquidez_descripcion,
	evt.ems_nombre,
	evt.grc_codigo,
	evt.tvl_codigo,
	evt.tiv_fecha_vencimiento,
	evt.tiv_tipo_valor,
	evt.tpo_numeracion,
	oper= case when evt.tvl_codigo in ('ACC','CDP','ENC','VTP')
		and evp.evp_abono=1 then
			1
		else evt.oper end,
	evt.htp_id,
	evt.htp_fecha_operacion,
	evt.tasa_cupon,
	evt.porv_retencion,
	es_vencimiento_interes=coalesce(evp.es_vencimiento_interes,isnull(evt.es_ven_interes,0)),
	--evt.fecha,
	fecha=coalesce(evp.evt_fecha,evt.fecha),

	evt.cliente_nombre,
	evt.por_tipo,
	evt.tpo_categoria,
	evt.htp_tpo_id,
	evt.fecha_compra,
	evt.htp_numeracion_clean,
	evt.compra_htp_id,
	evt.liq_compra,

	evt.iAmortizacion,
	evt.montoOper,

	evt.por_id,
	evt.saldo_liquidez,

	evt.amount,


	--evp_change_0
	--vep.vep_fecha,
	vep_fecha=evp.evt_fecha,

	vep_valor_efectivo=isnull(evp.evp_valor_efectivo,0),
	en_liquidez=case when vep_id is not null then 1 else 0 end,


	vep.vep_id,
	vep_cta_id,
	vep_other_account,

	vep.com_id,
	voucher_exists=case when vep.com_id is not null then 1 else 0 end,
	lip_documento,
	lip_cliente_id,

	vep.ttl_id,

	--evp_change_1
	--vep.vep_observaciones,
	evp.evp_observaciones vep_observaciones,

	ttl.ttl_nombre,
	
	--evp_change_2
	--account=case when vep.vep_id is not null then isnull(ctb_descripcion_grid,'') else '' end,
	account=isnull(ctb_descripcion_grid,''),

	--evp_change_3
	--lip_retencion=isnull(vep.lip_retencion,0),
	lip_retencion=isnull(evp.evp_retencion,0),

	vep_renovacion=case when evp_renovacion=1 then 'Renovación' else '' end,
	com_numero_comprobante,

	en_espera=isnull(evp_cobrado,0)--case when evp_cobrado=0 then 0 else 1 end
	/*case when oper=1 then
		case when evp.evt_fecha>='2099-12-31' then 1 else 0 end
	else
		0
	end*/
	,evp.evp_id
	
	,evt.tvl_nombre
	,evt.liq_numero_bolsa
	
	,
	valefeoper--=null
	
	--POR_PUBLIC_2
	,por_public
	
	,evt.TIV_ID
	,evt.dias_cupon
	,evt.TIV_FECHA_EMISION
	,evt.TFL_FECHA_INICIO
	,evt.TFL_FECHA_INICIO_ORIG
	,EVP_AJUSTE_PROVISION

	,evt.TPO_FECHA_INGRESO
	,evt.TPO_RECURSOS
	,evt.tiv_serie
	,evt.tiv_numero_emision_seb
	,evt.TIV_FRECUENCIA
	,evt.IPR_ES_CXC
	,fecha_original=evt.fecha
	,evp_valor_efectivo=isnull(evp.evp_pago_efectivo,0)
	,evt.htp_comision_bolsa
	,prEfectivo=case when ipr_es_cxc=1 and evt.tasa_cupon=0 and montooper<>0 then
		(-montooper-isnull(evt.UFO_RENDIMIENTO,0))/-montooper --caso especial de convenio de papel a descuento
	else evt.prEfectivo end
	,EVP_AJUSTE_VALOR_EFECTIVO
	,[tiv_tipo_base]
	,[saldo]
	,[tiv_interes_irregular]
	,[tfl_interes]
     ,evt.itrans
	 ,evp.evp_referencia
	 ,UFO_USO_FONDOS=coalesce(evp.evp_uso_fondos,evt.UFO_USO_FONDOS)
	 ,UFO_RENDIMIENTO=coalesce(evp.evp_rendimiento,evt.UFO_RENDIMIENTO)
	 ,TPO_BOLETIN
	,TPO_FECHA_COMPRA_ANTERIOR
	,TPO_PRECIO_COMPRA_ANTERIOR
	,TPO_FECHA_VENCIMIENTO_ANTERIOR
	,TPO_TABLA_AMORTIZACION
	,originalProvision			=
						case when evt.es_vencimiento_interes=0 and (tasa_cupon<>0 or tasa_cupon is null) or ipr_es_cxc=1 and fecha>='20240825' then 0 else
							case when coalesce(evp.evp_rendimiento,evt.UFO_RENDIMIENTO) is not null then
								case when evt.tiv_subtipo=3 and tasa_cupon=0 and 1=0 then 0 else coalesce(evp.evp_rendimiento,evt.UFO_RENDIMIENTO) end
							when saldo is not null and tfl_fecha_inicio_orig is not null then
								dbo.CalculateProvision(
									 saldo
									,tfl_fecha_inicio_orig
									,fecha
									,tasa_cupon
									,354
									,tpo_fecha_ingreso
									,0
									,case when tasa_cupon=0 then dbo.fnDias(tpo_fecha_ingreso,tiv_fecha_vencimiento,tiv_tipo_base) else 0 end
									,evt.prEfectivo
									,0
								)
							end
							/*dbo.fnDiasEu(case when tpo_fecha_ingreso>TFL_FECHA_INICIO then tpo_fecha_ingreso else tfl_fecha_inicio end,dateadd(d,-day(fecha),fecha),355)/dias_cupon * iamortizacion*/
							--+isnull(evp_ajuste_provision,0)
						end
	,TFL_PERIODO
	,evp.evp_abono
	,evt.FON_ID
	,evt.TIV_SUBTIPO
	,evt.HTP_TIENE_VALNOM
	,evt.specialValnom
	,evt.TIV_TIPO_RENTA
	,evp.EVP_COSTAS_JUDICIALES
	,evp.EVP_COSTAS_JUDICIALES_REFERENCIA
	,movsCupon.movs_evp_valor_efectivo

	--EMN:2-mar-2026 intereses de abono
	,movsCuponInt.movs_evp_interes_efectivo
	,movsCuponInt.movs_evp_interes_nominal--movs_evp_interes_efectivo+valEfeAbono-capMonto
	,movs_evp_interes_nominal_formula=
		  case when isnull(movsCupon.movs_evp_valor_efectivo_formula,'')<>'' then ' Capital:'+isnull(movsCupon.movs_evp_valor_efectivo_formula,'') else '' end
		+ case when isnull(movsCuponInt.movs_evp_interes_nominal_formula,'')<>'' then ' Interés:'+isnull(movsCuponInt.movs_evp_interes_nominal_formula,'') else '' end
	--,evt.liq_rendimiento
	--into _temp.test0
	from bvq_backoffice.liquidez_cache evt
	left join bvq_backoffice.evento_portafolio evp
	on
		(
			evp.evt_id=evt.htp_id  --evt.htp_id cache key!
			or 1=1 and evp.evp_tpo_id=evt.htp_tpo_id
			and evp.evp_fecha_original=evt.htp_fecha_operacion
		)
		and
		(
			evp.oper_id=evt.oper and
			(
				evp.es_vencimiento_interes=evt.es_vencimiento_interes
				or evp.evp_abono=1 and iamortizacion=0 and evp.es_vencimiento_interes=1
			)
			or
			evt.tvl_codigo in ('ACC','CDP','ENC','VTP')
			and evp.evp_abono=1
		)
	--evp_change_4
	left join bvq_backoffice.CuentaContableYBancaria cta	--ObtenerDetallePortafolioConLiquidezView						ctb_descripcion_grid,ctl_id
		--on vep_cta_id=cta.cta_id
		on evp.ctl_id=cta.ctl_id

	left join
		bvq_backoffice.liquidez_portafolio vep

		left join bvq_backoffice.tipo_transaccion_liquidez ttl on ttl.ttl_id=vep.ttl_id
		left join bvq_backoffice.comprobante_gestion_negocio com on com.com_id=vep.com_id
	on
		vep.evp_id=evp.evp_id

	--movimientos de cupón
	left join (
			select movs_evp_valor_efectivo=sum(evp_valor_efectivo)
			, movs_evp_valor_efectivo_formula=dbo.stringagg(isnull('ve:'+rtrim(evp_valor_efectivo)+' f:'+convert(varchar(8), evt_fecha, 112),''),' ; ')
			, evp_tpo_id, evp_fecha_original
			from bvq_backoffice.evento_portafolio e
			where evt_fecha<'29991231' and es_vencimiento_interes=0 and EVP_ABONO=1
			group by evp_tpo_id,evp_fecha_original
			--having evp_tpo_id=2193
		) movsCupon
		--on evt_fecha='29991231'
		--EMN: 10-jun-2026 Aplicar esta funcionalidad de 20260703 en adelante pero exceptuando 29991230
		on (evt_fecha='29991231' or 1=1 and evt_fecha>=0 and  evt_fecha<'29991230')
		and movsCupon.evp_tpo_id=evp.evp_tpo_id and movsCupon.evp_fecha_original=evp.evp_fecha_original

	--movsCuponInt
	left join (
			select
			 movs_evp_interes_efectivo=sum(
				isnull(evp_valor_efectivo,0)
			)
			,movs_evp_interes_nominal=sum(
				isnull(evp_valor_efectivo,0) + isnull(valEfeAbono,0) - isnull(capMonto,0) + isnull(evp_ajuste_provision,0)
			)
			, movs_evp_interes_nominal_formula = dbo.StringAgg(
					'ie:'+rtrim(isnull(round(evp_valor_efectivo,4),0))
					+ isnull(' + ive:'+ rtrim(valEfeAbono),'')
					+ isnull(' - vn:'+ rtrim(capMonto),'')
					+ ' + prov:' + rtrim(isnull(evp_ajuste_provision,0))
					+ ' f:' + convert(varchar(8), evt_fecha, 112)
				, ' ; '
			)

			, evp_tpo_id, evp_fecha_original
			--, valEfeAbono
			--, capMonto
			--select e.evt_fecha,isnull(evp_valor_efectivo,0),+valEfeAbono,-isnull(capMonto,0)
			from (
				--bloque testeable en línea
				select evp_tpo_id, evp_valor_efectivo, evp_fecha_original, evt_fecha, es_vencimiento_interes, evp_abono, capMonto, evp_observaciones
				,prEfectivo, valEfeAbono=isnull(capMonto,0)*isnull(eCap.prEfectivo,0)
				--EMN: 14-jun-2026 sumar provisión para calcular saldos
				,evp_ajuste_provision=isnull(case when 1=1 and e.evp_tpo_id not in (215,222,2488) then e.evp_ajuste_provision end,0)
				from bvq_backoffice.evento_portafolio e
				left join (
					select --capMonto=1000
					 capMonto=nullif(evp_valor_efectivo,0)
					,capHtpId=evt_id--9043840001801,--htp_id,
					,capFecha=evt_fecha--convert(datetime,'2026-03-02T14:23:27')--fecha
					,prEfectivo--=0.9--472.614223333333/500.0
					from bvq_backoffice.liquidez_cache evt
					join bvq_backoffice.evento_portafolio evp on evp.evt_id=evt.htp_id
					and
					(
						evp.oper_id=evt.oper and
						(
							evp.es_vencimiento_interes=evt.es_vencimiento_interes
							or evp.evp_abono=1 and iamortizacion=0 and evp.es_vencimiento_interes=1
						)
					)
					--from bvq_backoffice.evtTemp
					where evp.es_vencimiento_interes=0 and htp_tiene_valnom=1
				) eCap
				on ecap.capHtpId=e.evt_id and capFecha=e.evt_fecha
				where evt_fecha<'29991231' and es_vencimiento_interes=1 and EVP_ABONO=1
				--fin bloque testeable en línea
			) e
			group by evp_tpo_id,evp_fecha_original
			--having evp_tpo_id=2193
		) movsCuponInt
		on (
			evt_fecha='29991231'
			or 1=1 and evt_fecha>=0 and evt_fecha<'29991230'
		)		
		and movsCuponInt.evp_tpo_id=evp.evp_tpo_id and movsCuponInt.evp_fecha_original=evp.evp_fecha_original
		--fin movsCuponInt
	/*	vep.evt_id=evt.htp_id and --evt.htp_id cache key!
		vep.oper_id=evt.oper and
		vep.es_vencimiento_interes=isnull(evt.es_vencimiento_interes,0)*/
	where abs(isnull(evt.montoOper,0)+isnull(evt.iAmortizacion,0))>5e-9
	or evp.evp_abono=1
	union all

	select
	per.nombre,
	por.por_codigo,
	liquidez_descripcion=null,
	ems_nombre=null,
	grc_codigo=null,
	tvl_codigo=null,
	tiv_fecha_vencimiento=null,
	tiv_tipo_valor=null,
	tpo_numeracion=null,
	2,
	htp_id=null,
	htp_fecha_operacion=null,
	tasa_cupon=null,
	porv_retencion=null,

	vep.es_vencimiento_interes,
	evp.evt_fecha,

	cliente_nombre=null,
	por_tipo,
	tpo_categoria=null,
	htp_tpo_id=null,
	fecha_compra=null,
	htp_numeracion_clean=null,
	compra_htp_id=null,
	liq_compra=null,

	iAmortizacion=null,
	montoOper=null,

	por.por_id,
	saldo_liquidez=null,

	amount=null,

	evp.evt_fecha,

	evp.evp_valor_efectivo,
	1,

	vep.vep_id,
	cta.cta_id,

	vep_other_account=null,

	vep.com_id,
	case when vep.com_id is not null then 1 else 0 end,
	lip_documento,
	lip_cliente_id,

	vep.ttl_id,
	vep.vep_observaciones,

	ttl.ttl_nombre,

	account=isnull(ctb_descripcion_grid,''),
	lip_retencion=0,
	vep_renovacion=null,
	com_numero_comprobante,

	en_espera=1
	,evp.evp_id
	
	,tvl_nombre=null
	,liq_numero_bolsa=null
	,valefeoper=vep.vep_valor_efectivo
	
	--POR_PUBLIC_2
	,por.por_public
	
	,TIV_ID=null
	,dias_cupon=null
	,TIV_FECHA_EMISION=null
	,TFL_FECHA_INICIO=null
	,TFL_FECHA_INICIO_ORIG=null
	,EVP_AJUSTE_PROVISION
	--cliente.nombre
	,TPO_FECHA_INGRESO=null
	,TPO_RECURSOS=null
	,tiv_serie=null
	,tiv_numero_emision_seb=null
	,TIV_FRECUENCIA=null
	,IPR_ES_CXC=null
	,fecha_original=null
	,evp_pago_efectivo
	,htp_comision_bolsa=null
	,prEfectivo=null
	,EVP_AJUSTE_VALOR_EFECTIVO
	,[tiv_tipo_base]=null
	,[saldo]=null
	,[tiv_interes_irregular]=null
	,[tfl_interes]=null
	--,provision=null
	,itrans = null
	,evp_referencia = null
	,UFO_USO_FONDOS = null
	,UFO_RENDIMIENTO = null
	,TPO_BOLETIN = null
	,TPO_FECHA_COMPRA_ANTERIOR=null
	,TPO_PRECIO_COMPRA_ANTERIOR=null
	,TPO_FECHA_VENCIMIENTO_ANTERIOR=null
	,TPO_TABLA_AMORTIZACION = null
	,originalProvision = null
	,TFL_PERIODO = null
	,evp_abono = null
	,FON_ID = null
	,TIV_SUBTIPO = null
	,HTP_TIENE_VALNOM=null
	,specialValnom=null
	,TIV_TIPO_RENTA=null
	,EVP_COSTAS_JUDICIALES=null
	,EVP_COSTAS_JUDICIALES_REFERENCIA=null
	,movs_evp_valor_efectivo=null
	,movs_evp_interes_efectivo=null
	,movs_evp_interes_nominal=null--movs_evp_interes_efectivo+valEfeAbono-capMonto
	,movs_evp_interes_nominal_formula=null
	--,liq_rendimiento=null
	from
	bvq_backoffice.evento_portafolio evp

	--evp_change_4
	left join bvq_backoffice.CuentaContableYBancaria cta	--ObtenerDetallePortafolioConLiquidezView								ctb_descripcion_grid,ctl_id
		--on vep_cta_id=cta.cta_id
		on evp.ctl_id=cta.ctl_id

	left join
		bvq_backoffice.liquidez_portafolio vep

		left join bvq_backoffice.tipo_transaccion_liquidez ttl on ttl.ttl_id=vep.ttl_id
		left join bvq_backoffice.comprobante_gestion_negocio com on com.com_id=vep.com_id
	on
		vep.evp_id=evp.evp_id
		/*vep.evt_id=evp.evt_id and --transitive
		vep.oper_id=evp.oper_id and
		vep.es_vencimiento_interes=isnull(evp.es_vencimiento_interes,0)*/

	join bvq_backoffice.portafolio por on vep.por_id=por.por_id
	join bvq_prevencion.personacomitente per on per.ctc_id=por.ctc_id

	--left join bvq_prevencion.personacomitente cliente on cliente.ctc_id=lip_cliente_id
	where evp.oper_id=2
	--order by por.por_id,vep_fecha,vep_id;
