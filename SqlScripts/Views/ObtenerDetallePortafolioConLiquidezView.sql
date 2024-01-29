create view bvq_backoffice.ObtenerDetallePortafolioConLiquidezView as

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
	evt.oper,
	evt.htp_id,
	evt.htp_fecha_operacion,
	evt.tasa_cupon,
	evt.porv_retencion,
	es_vencimiento_interes=isnull(evt.es_ven_interes,0),
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
	,evt.prEfectivo
	,EVP_AJUSTE_VALOR_EFECTIVO
	,[tiv_tipo_base]
	,[saldo]
	,[tiv_interes_irregular]
	,[tfl_interes]
	,provision			=
						case when evt.es_vencimiento_interes=0 then 0 else
							case when saldo is not null and tfl_fecha_inicio_orig is not null then dbo.CalculateProvision(saldo,tfl_fecha_inicio_orig,fecha,tasa_cupon,354,tpo_fecha_ingreso,0,0) end
							/*dbo.fnDiasEu(case when tpo_fecha_ingreso>TFL_FECHA_INICIO then tpo_fecha_ingreso else tfl_fecha_inicio end,dateadd(d,-day(fecha),fecha),355)/dias_cupon * iamortizacion
							+isnull(evp_ajuste_provision,0)*/
						end
	--into _temp.test0
	from bvq_backoffice.liquidez_cache evt
	left join bvq_backoffice.evento_portafolio evp
	on
		(
			evp.evt_id=evt.htp_id  --evt.htp_id cache key!
			or evp.evp_tpo_id=evt.htp_tpo_id
			and evp.evp_fecha_original=evt.htp_fecha_operacion
		)
		and
		evp.oper_id=evt.oper and
		evp.es_vencimiento_interes=evt.es_vencimiento_interes
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
	/*	vep.evt_id=evt.htp_id and --evt.htp_id cache key!
		vep.oper_id=evt.oper and
		vep.es_vencimiento_interes=isnull(evt.es_vencimiento_interes,0)*/
	where abs(isnull(evt.montoOper,0)+isnull(evt.iAmortizacion,0))>5e-9
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
	,provision=null
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