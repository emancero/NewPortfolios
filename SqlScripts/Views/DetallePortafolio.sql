create view bvq_backoffice.DetallePortafolio as
	select
	--ord,
	evt_id=e.htp_id,
	saldo_anterior=
		(
			select sum(montoOper) from bvq_backoffice.EventoPortafolio
			where htp_tpo_id=e.htp_tpo_id and htp_fecha_operacion<=e.htp_fecha_operacion
		)
		-e.montoOper,
	e.htp_fecha_operacion,

	e.cupoper_tfl_fecha_inicio,
	htp_compra=case when montoOper>0 then montoOper else 0 end,
	htp_precio_compra=isnull(htp.htp_precio_compra,100e),
	htp_venta=case when montoOper<0 then -montoOper else 0 end,
	htp_precio_venta=isnull(htp.htp_precio_venta,100e),
	htp_saldo=(select sum(montooper-isnull(remaining,0)) from bvq_backoffice.EventoPortafolio where htp_tpo_id=e.htp_tpo_id and htp_fecha_operacion<=e.htp_fecha_operacion),
	tiv_codigo,
	tiv_fecha_emision,
	tiv.tiv_fecha_vencimiento,
	valor_efectivo_compra=(case when montoOper>0 then montoOper else 0 end)*isnull(htp.htp_precio_compra,100e)/case when tiv.tiv_tipo_renta=153 then 100 else 1 end,
	valor_efectivo_venta=(case when montoOper<0 then -montoOper else 0 end)*isnull(htp.htp_precio_venta,100e)/case when tiv.tiv_tipo_renta=153 then 100 else 1 end,
	iAmortizacion iDiff,
	htp_tpo_id mov_tpo_id,
	tpo_numeracion htp_numeracion,
	tpo.por_id,
	tpo.tiv_id,
	case when montoOper<0 then -montoOper else 0 end+iAmortizacion total,
	oper,
	tiv_emisor,
	tasa_cupon,
	ctb.ctb_numero_cuenta,
	ctb_nombre_banco=itcinf.itc_valor
	,e.porv_retencion
	--,ali.asi_ctb_id
	--,ali.rub_ctb_id
	,compra_venta=case when htp_compra>0 then 'Compra' else 'Venta' end
	,e.liq_numero_bolsa
	,liq_comision_bolsa
	,liq_comision_casa
	,liq_total_interes
	,liq_tot_operacion
	,e.liq_retencion
	,liquidez_credito=case when montoOper<0 then -montoOper else 0 end
	,liquidez_debito=case when montoOper>0 then montoOper else 0 end
	,htp_en_transito
	,tiv_tipo_renta
	,cxp.cxp_id
	,cxp.cxp_fecha_registro
	,cxp.cxp_total
	,com_id=null--ali.com_id
	,documento
	,tipo_movimiento
	,en_liquidez=
	
		--case when ali.asi_ctb_id=ali.rub_ctb_id then 1 else 0 end
		--case when ali.asi_ctb_id is not null then 1 else 0 end --si es cta. bancaria se asume que es de liquidez
		case when vep_id is not null then 1 else 0 end
	,monto_en_liquidez=vep_valor_efectivo
	,dias_cupon
	,evp.evp_retencion
	,divven.es_vencimiento_interes
	,e.liq_valor_nominal_total
	,e.liq_retencion_casa_total
	
	,e.liq_interes_total
	,e.liq_comision_bolsa_total
	,e.liq_comision_casa_total
	,e.liq_retencion_bolsa_total
	,e.TFL_FECHA_INICIO
	,e.TFL_PERIODO
	--,fecha_inicio
	--,fecha_fin
	from bvq_backoffice.eventoportafolio e
	join bvq_backoffice.titulos_portafolio tpo on tpo.tpo_id=e.htp_tpo_id
	--left join bvq_backoffice.valor_efectivo_portafolio vep on vep.evt_id=e.htp_id and vep.oper_id=e.oper

	--separador vencimientos
	left join(
		select 0 es_vencimiento_interes union 
		select 1 es_vencimiento_interes
	) divven on oper=1 and NOT (iAmortizacion=0 and es_vencimiento_interes=1 or montoOper=0 and es_vencimiento_interes=0)
	left join bvq_backoffice.evento_portafolio evp
	on
		evp.evt_id=e.htp_id and
		evp.oper_id=e.oper and
		evp.es_vencimiento_interes=divven.es_vencimiento_interes
	--fin separador vencimientos
	left join
		bvq_backoffice.liquidez_portafolio vep
		left join bvq_backoffice.tipo_transaccion_liquidez ttl on ttl.ttl_id=vep.ttl_id
	on
		vep.evt_id=e.htp_id and
		vep.oper_id=e.oper and
		vep.es_vencimiento_interes=isnull(divven.es_vencimiento_interes,0)


	left join (
		select por_id,ing_fecha fecha,ctb_id,tipo_movimiento='INGRESO',coalesce(ing_comp_nota_credito,ing_comp_cheque) documento
		from bvq_backoffice.ingreso_bancos ing
		union
		select por_id,egr_fecha,ctb_id,'EGRESO',coalesce(egr_doc_nota_credito,egr_doc_cheque)
		from bvq_backoffice.egreso_bancos
	) ingegr on vep.por_id=ingegr.por_id and vep_fecha=fecha
	left join bvq_backoffice.cuenta_bancaria ctb
		join bvq_backoffice.institucion_financiera inf
			join bvq_administracion.item_catalogo itcinf
			on itcinf.itc_id=inf_nombre
		on inf.inf_id=ctb.inf_id
	on ingegr.ctb_id=ctb.ctb_id
	join bvq_administracion.titulo_valor tiv on tiv.tiv_id=tpo.tiv_id
	left join (select htp_id,htp_precio_compra,htp_precio_venta,htp_compra,htp_venta from bvq_backoffice.historico_titulos_portafolio) htp on oper=0 and htp.htp_id=e.htp_id

	join bvq_backoffice.portafolio por on tpo.por_id=por.por_id
	left join bvq_backoffice.cuenta_por_pagar cxp on cxp.por_id=por.por_id and cxp_modulo_origen=430
