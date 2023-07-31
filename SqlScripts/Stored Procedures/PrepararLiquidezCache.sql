create procedure bvq_backoffice.PrepararLiquidezCache(@i_lga_id int) as
	exec bvq_administracion.generarcompraventacorte
	
	declare @tbPersonaComitente table
	(
		ctc_id		int,
		identificacion	varchar(25),
		nombre 			varchar(max)
	)
	insert into @tbPersonaComitente (ctc_id,identificacion,nombre)
	select distinct ctc.ctc_id,identificacion,nombre
	from BVQ_PREVENCION.personacomitente ctc
		inner join BVQ_BACKOFFICE.PORTAFOLIO por on ctc.ctc_id=por.CTC_ID
	
	truncate table bvq_backoffice.liquidez_cache
	insert into bvq_backoffice.liquidez_cache(
		nombre,
		por_codigo,
		liquidez_descripcion,
		ems_nombre,
		grc_codigo,
		tvl_codigo,
		tiv_fecha_vencimiento,
		tiv_tipo_valor,
		tpo_numeracion,
		oper,
		htp_id,
		htp_fecha_operacion,
		tasa_cupon,
		porv_retencion,
		es_vencimiento_interes,
		fecha,
		iAmortizacion,
		montoOper,
		por_id,
		saldo_liquidez,
		amount,
		cliente_nombre,
		por_tipo,
		tpo_categoria,
		htp_tpo_id,
		fecha_compra,
		htp_numeracion_clean,
		compra_htp_id,
		liq_compra,
		es_ven_interes,
		
		tvl_nombre,
		liq_numero_bolsa,
		valefeoper,
		tfl_id_2
		
		--POR_PUBLIC_2
		,POR_PUBLIC

		--,
		--vep.vep_fecha,

		--vep_valor_efectivo=isnull(vep_valor_efectivo,0),
		--en_liquidez=case when vep_id is not null then 1 else 0 end,


		--vep.vep_id,
		--vep_cta_id,
		--vep_other_account,

		--account=case when vep.vep_id is not null then isnull(ctb_descripcion_grid,'') else evp_otra_cuenta end,
		--vep_renovacion=case when evp_renovacion=1 then 'Renovación' else '' end,
		--vep.ttl_id,
		--vep.vep_observaciones,
		--ttl.ttl_nombre,
		--evp_retencion=isnull(evp.evp_retencion,0),
		--vep.com_id,
		--voucher_exists=case when vep.com_id is not null then 1 else 0 end,
		--lip_documento,
		--lip_cliente_id

	)
	--create view _temp.test01 as
		select
		per.nombre,
		por.por_codigo,
		liquidez_descripcion='',
		ems.ems_nombre,
		grc.grc_codigo,
		tvl.tvl_codigo,
		tiv.tiv_fecha_vencimiento,
		tiv.tiv_tipo_valor,
		tpo.tpo_numeracion,
		evt.oper,
		evt.htp_id,
		evt.htp_fecha_operacion,
		evt.tasa_cupon,
		evt.porv_retencion,
		es_vencimiento_interes=isnull(divven.es_vencimiento_interes,0),
		fecha=case when oper=1 then cupoper_tfl_fecha_inicio else htp_fecha_operacion end,

		iAmortizacion,
		montoOper,
		tpo.por_id,
		saldo_liquidez=convert(float,0.0),
		amount=
			case when divven.es_vencimiento_interes=1 then iAmortizacion else
				case when oper=0 then
					-sign(montooper)*
					(
						abs(valefeoper)+isnull(liq_total_interes,0)+sign(montooper)*
						(
							isnull(liq_comision_bolsa,0)+isnull(liq_comision_casa,0)
							- isnull(liq_retencion,0)
							- isnull(liq_retencion_casa,0)
						)
					)
				else
					-montoOper --Importante!
				end
			end,
		cliente_nombre=convert(varchar(255),''),
		por_tipo,
		tpo_categoria,
		htp_tpo_id,
		fecha_compra,
		htp_numeracion_clean,
		evt.compra_htp_id,
		liq_compra=compra.liq_numero_bolsa,
		divven.es_vencimiento_interes es_ven_interes,
		
		tvl.tvl_nombre,
		evt.liq_numero_bolsa,
		evt.valefeoper,
		tfl_id_2=evt.tfl_id
		
		--POR_PUBLIC_2
		,por.por_public
	
		--select *
		from
		bvq_backoffice.eventoPortafolio evt
		left join bvq_backoffice.titulos_portafolio tpo on evt.htp_tpo_id=tpo.tpo_id
		left join (
			select htp_fecha_operacion fecha_compra, htp_id compra_htp_id,liq_numero_bolsa from bvq_backoffice.historico_titulos_portafolio htp
			left join bvq_backoffice.liquidacion liq on liq.liq_id=htp.liq_id
		) compra on compra.compra_htp_id=evt.compra_htp_id
		left join bvq_administracion.titulo_valor tiv
			join bvq_administracion.tipo_valor tvl on tiv.tiv_tipo_valor=tvl.tvl_id
			left join bvq_administracion.grupo_concentracion grc on tvl_grupo_concentracion=grc_id
			join bvq_administracion.emisor ems on tiv_emisor=ems_id
		on tiv.tiv_id=tpo.tiv_id
		join bvq_backoffice.portafolio por on tpo.por_id=por.por_id
		join @tbPersonaComitente per on per.ctc_id=por.ctc_id
		--separador vencimientos
		left join(
			select 0 es_vencimiento_interes union 
			select 1 es_vencimiento_interes
		) divven on oper=1 and NOT (iAmortizacion=0 and es_vencimiento_interes=1 or montoOper=0 and es_vencimiento_interes=0)
		--join bvq_administracion.parametro retencionpct on retencionpct.par_codigo='PAR_RETENCION_LIQ'
		--where datediff(d,htp_fecha_operacion,'2017-04-28')=0
		--fin separador vencimientos
