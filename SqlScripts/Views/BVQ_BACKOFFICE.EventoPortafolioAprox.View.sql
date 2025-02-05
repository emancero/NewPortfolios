create view bvq_backoffice.EventoPortafolioAprox as
	select
	0 amortizacion,
	0 amortizacion2,
	montooper,
	amortizacionOld=0,
	montooperOld=montooper*htp_tiene_valnom,
	montoOperSinCupon=(
	isnull(htp_cobra_primer_cupon,1)*isnull(htp_libre,1)
	--+ case when htp_tpo_id-266000 in (745,746,747) and htp_cobra_primer_cupon=0 then 1 else 0 end
	)*montoOper,
	--montoOperSinCupon=isnull(htp_cobra_primer_cupon,1)*isnull(htp_libre,1)*montoOper,-- + case when htp_id in (234365,234362,234361,234482,234483,234484,234485,234486,234487),
	htp_cobra_primer_cupon,
	htp_libre,
	0 iamortizacion,
	0 iamortizacion2,
	0 alliamortizacion,
	0 acc,
	valefeoper,
	itrans,--------
	cupoper_tfl_fecha_inicio,
	htp_id=convert(bigint,htp_id),
	htp_tpo_id,
	htp_fecha_operacion,
	0 oper,
	null tfl_capital,
	null tfl_amortizacion,
	null def_cobrado,
	cupoper_base_denominador,
	cupoper_itasa_interes tasa_cupon,
	tfl_fecha_vencimiento2=case when def_int_cobrado is null then coalesce(
		 CASE WHEN RETR_INTERES=1 THEN RETR_FECHA_COBRO END
		,cupoper_tfl_fecha_inicio) else null end,
	liq_numero_bolsa,
	liq_comision_bolsa=round(proporcional_htp_liq*htpcupon.liq_comision_bolsa,2),
	liq_comision_casa=round(proporcional_htp_liq*htpcupon.liq_comision_casa,2),
	liq_total_interes=round(proporcional_htp_liq*htpcupon.liq_total_interes,2),
	liq_tot_operacion,
	htp_en_transito,
	dias_cupon=null,
	tfl_id=null,
	htp_reportado,
	liq_rendimiento,
	liq_retencion=round(proporcional_htp_liq*htpcupon.liq_retencion,2),
	liq_retencion_casa=round(proporcional_htp_liq*htpcupon.liq_retencion_casa,2),
	
	htp_precio_compra
	/*,
	cupoper_tfl_id=null,
	htp_cobra_primer_cupon=null*/
	--tivchange
	,tiv_tipo_valor
	,tiv_fecha_vencimiento
	,tiv_subtipo
	,compra_htp_id
	,htp_numeracion_clean=htp_numeracion
	--,tiv_calculo_frecuencia
	,liq_valor_nominal_total=htpcupon.liq_valor_nominal
	,liq_retencion_casa_total=htpcupon.liq_retencion_casa
	
	,liq_interes_total=htpcupon.liq_total_interes
	,liq_comision_bolsa_total=htpcupon.liq_comision_bolsa
	,liq_comision_casa_total=htpcupon.liq_comision_casa
	,liq_retencion_bolsa_total=htpcupon.liq_retencion
	,liq_market=htpcupon.liq_market
	,tfl_fecha_inicio=null
	,tfl_periodo=null
	,liq_id=htpcupon.liq_id
	,tfl_fecha_inicio_orig=null
	,htp_comision_bolsa
	,prEfectivo=
	case when htp_numeracion like 'cfr-%'
		or htp_numeracion like 'RZK-2024-08-05%'
	then
		tpo_precio_efectivo/100.0
	when htpcupon.tiv_tipo_renta=154 then
		(htpcupon.valefeoper
		+isnull(case when htpcupon.htp_fecha_operacion>='20220601' then htpcupon.htp_comision_bolsa end,0)
		)/htpcupon.montooper
	end
	,tiv_tipo_base=null
	,saldo=null
	,tiv_interes_irregular=null
	,tfl_interes=null
	,FON_ID=null
	,HTP_TIENE_VALNOM
	,specialValnom=montooper
	,ufo_uso_fondos=null
	,ufo_rendimiento=null
	,htpcupon.tiv_tipo_renta
	,totalUfoUsoFondos=null
	,totalUfoRendimiento=null
	,fecha_vencimiento_original=null
	from bvq_backoffice.htpcupon
	left join bvq_backoffice.defaults def on htpcupon.por_id=def.por_id and htpcupon.tiv_id=def.tiv_id
	and datediff(m,def.fecha,htpcupon.cupoper_tfl_fecha_inicio)>=0
	--where htp_tiene_valnom=1
	union
	
	select
	amortizacion=	-sum(isnull(htp_cobra_primer_cupon,1)*amortizacion),
	amortizacion2=	-sum(isnull(htp_cobra_primer_cupon,1)*amortizacion2),
	montoOper=	-sum(isnull(htp_cobra_primer_cupon,1)*amortizacion),
	amortizacionOld=	-sum(isnull(htp_cobra_primer_cupon,1)*amortizacion*htp_tiene_valnom),
	montoOperOld=	-sum(isnull(htp_cobra_primer_cupon,1)*amortizacion*htp_tiene_valnom),
	montoOperSinCupon=-sum(isnull(htp_cobra_primer_cupon,1)*isnull(case when cupoper_tfl_id=tfl_id then htp_libre end,1)*amortizacion),
	htp_cobra_primer_cupon=avg(htp_cobra_primer_cupon),
	htp_libre=avg(htp_libre),
	iAmortizacion=sum(iamortizacion),
	iAmortizacion2=sum(iamortizacion2),
	sum(alliamortizacion),
	acc=	sum(isnull(alliamortizacion,0)-isnull(iamortizacion,0)),
	valefeoper=	null,
	--itrans=	null,--------
	itrans = sum(itrans),
	cupoper_tfl_fecha_inicio=	tfl_fecha_vencimiento2,	--coalesce(retr_fecha_esperada,tfl_fecha_vencimiento),
	htp_id=	convert(bigint,tfl_id)*10000000+convert(bigint,htp_tpo_id),--convert(bigint,tfl_id*1e7+htp_tpo_id),
	htp_tpo_id,
	tfl_fecha_vencimiento,
	oper=1,
	tfl_capital,
	tfl_amortizacion,
	def_cobrado,
	base_denominador,
	itasa_interes=max(itasa_interes),
	tfl_fecha_vencimiento2=case when htp_tpo_id=1533 and vencimiento='20241030' then '20250125' else vencimiento end,
	liq_numero_bolsa=null,
	liq_comision_bolsa=null,
	liq_comision_casa=null,
	liq_total_interes=null,
	liq_tot_operacion=null,
	htp_en_transito=null,
	dias_cupon,
	tfl_id,
	htp_reportado=null,
	liq_rendimiento=null,
	liq_retencion=null,
	liq_retencion_casa=null,
	htp_precio_compra=null
	/*,
	cupoper_tfl_id,
	htp_cobra_primer_cupon*/
	--tivchange
	,tiv_tipo_valor=null
	,tiv_fecha_vencimiento=null
	,tiv_subtipo--=null
	,compra_htp_id
	,htp_numeracion_clean=isnull(htp_numeracion,'')
	--,tiv_calculo_frecuencia=null
	,liq_valor_nominal_total=null
	,liq_retencion_casa_total=null
	
	,liq_interes_total=null
	,liq_comision_bolsa_total=null
	,liq_comision_casa_total=null
	,liq_retencion_bolsa_total=null
	,liq_market=null
	,tfl_fecha_inicio
	,tfl_periodo
	,liq_id=null
	,tfl_fecha_inicio_orig
	,htp_comision_bolsa=sum(htp_comision_bolsa)
	,prEfectivo=max(prEfectivo)
	,tiv_tipo_base
	,saldo=sum(saldo)
	,tiv_interes_irregular
	,tfl_interes
	,FON_ID
	,HTP_TIENE_VALNOM=min(convert(int,HTP_TIENE_VALNOM))
	,specialValnom=	-sum(isnull(htp_cobra_primer_cupon,1)*case when htp_tiene_valnom=1 then amortizacion else 0 end)
	,ufo_uso_fondos=sum(ufo_uso_fondos)
	,ufo_rendimiento=sum(ufo_rendimiento)
	,tiv_tipo_renta=max(tiv_tipo_renta)
	,totalUfoUsoFondos=max(totalUfoUsoFondos)
	,totalUfoRendimiento=max(totalUfoRendimiento)
	,fecha_vencimiento_original=tfl_fecha_vencimiento2
	from bvq_backoffice.compraventaflujo
	--where htp_tiene_valnom=1
	--left join bvq_backoffice.retraso retr on htp_tpo_id=retr_tpo_id and retr_fecha_cobro=tfl_fecha_vencimiento
	group by htp_tpo_id,tfl_id,tfl_fecha_vencimiento,vencimiento,tfl_capital,tfl_amortizacion,def_cobrado,tfl_fecha_inicio,/*retr_fecha_esperada,*/base_denominador,/*itasa_interes,*/tfl_fecha_vencimiento2,dias_cupon,compra_htp_id,isnull(htp_numeracion,''),TFL_PERIODO,tfl_fecha_inicio_orig
	--,htp_comision_bolsa
	,	tiv_tipo_base,tiv_interes_irregular,tfl_interes,FON_ID,tiv_subtipo--,HTP_TIENE_VALNOM
