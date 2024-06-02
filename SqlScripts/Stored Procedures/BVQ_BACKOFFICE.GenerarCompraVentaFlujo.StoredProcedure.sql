create procedure bvq_backoffice.GenerarCompraVentaFlujo as
begin

	truncate table bvq_backoffice.compra_venta_flujo
	
	insert into bvq_backoffice.compra_venta_flujo with (tablock) (cvf_id,htp_id,tiv_id,por_id,htp_tpo_id,compra_htp_id,htp_fecha_operacion,montoOper,valEfeOper,itrans,orig,htp_numeracion,tiv_tipo_base,tfl_fecha_inicio,tfl_fecha_vencimiento,tfl_fecha_vencimiento2
	,tfl_id,tfl_capital,tfl_amortizacion,def_cobrado,def_int_cobrado,def_cobrado_2,itasa_interes,dias_cupon,base_denominador/*,vencimiento_esperado*/,cupoper_tfl_id,htp_cobra_primer_cupon,htp_libre,tfl_capital_1,tpo_redondear_amortizacion,htp_reportado
	,tiv_frecuencia,cupoper_tfl_capital,htp_rendimiento_retorno,htp_tir,TFL_PERIODO,tfl_fecha_inicio_orig
	--ADD: Columnas importantes
	,tiv_fecha_vencimiento,tiv_tipo_valor,tiv_subtipo,htp_precio_compra,cupoper_tfl_fecha_inicio
	--ADD: Columnas menores
	,liq_rendimiento,liq_interes_total,liq_comision_bolsa,liq_comision_casa,liq_id,liq_market,liq_numero_bolsa,tpo_tipo_valoracion
	--ADD: Columnas que estaban en view CompraVentaFlujo
	,vencimiento
	,amortizacion
	,iamortizacion
	,htp_comision_bolsa
	,prEfectivo
	,saldo
	,tiv_interes_irregular
	,TFL_INTERES
	,FON_ID
	,HTP_TIENE_VALNOM
	,ufo_uso_fondos
	,ufo_rendimiento
	,tiv_tipo_renta
	)
	select
	null cvf_id,--/*no se utiliza*/row_number() over (order by op.htp_id,op.tiv_id,tiv.tfl_id) cvf_id,
	op.htp_id,
	op.tiv_id,
	op.por_id,
	htp_tpo_id,
	compra_htp_id,
	htp_fecha_operacion,
	montoOper,
	valEfeOper=round(coalesce(err_htp_precio_compra,(op.htp_precio_compra+htp_precio_venta))/case when tiv.tiv_tipo_renta=153 then 100 else 1 end,14)*montoOper,
	itrans=round(
		montoOper*cupOper_itasa_interes
		*case when tiv.tiv_tipo_base=354 then
			datediff(m,cupOper_tfl_fecha_inicio,htp_fecha_operacion)*30+isnull(nullif(day(htp_fecha_operacion),31),30) - isnull(nullif(day(cupOper_tfl_fecha_inicio),31),30)
		when tiv.tiv_tipo_base in (355,356) then
			datediff(d,cupOper_tfl_fecha_inicio,htp_fecha_operacion)
		end
		/(cupOper_base_denominador*100)
	,2),
	orig=
		montoOper
		--tpo_monto_total
		/isnull(nullif(cupOper_tfl_capital,0),1e),
	htp_numeracion,
	tiv.tiv_tipo_base,

	tfl_fecha_inicio=coalesce(retr1.retr_fecha_cobro,tiv.tfl_fecha_inicio),
	tfl_fecha_vencimiento=coalesce(
		CASE WHEN RETR2.RETR_CAPITAL=1 THEN RETR2.RETR_FECHA_COBRO END
		,tiv.tfl_fecha_vencimiento),
	tfl_fecha_vencimiento2=tiv.tfl_fecha_vencimiento,
	--tfl_fecha_vencimiento3=case when def.def_exacto=1 then null else tiv.tfl_fecha_vencimiento end,

	tiv.tfl_id,
	tiv.tfl_capital,
	tiv.tfl_amortizacion,
	def_cobrado,
	def_int_cobrado,
	def_cobrado_2=
		case when isnull(def_cobrado,1)=1 then
			case when def_exacto=1 then 0 else 1 end
		else
			ISNULL(def_cobrado,1)
		end
	,
	itasa_interes=isnull(htp_cobra_primer_cupon,1)*itasa_interes*isnull(case when cupoper_tfl_id=tiv.tfl_id then htp_libre end,1),
	tiv.dias_cupon,
	tiv.base_denominador,
	cupoper_tfl_id,
	htp_cobra_primer_cupon,
	htp_libre,
	tfl_capital_1=tiv.tfl_capital-tiv.tfl_amortizacion,
	tpo_redondear_amortizacion,
	op.htp_reportado,
	tiv.tiv_frecuencia,
	cupoper_tfl_capital,
	htp_rendimiento_retorno,
	htp_tir,
	TFL_PERIODO,
	tfl_fecha_inicio_orig=tiv.tfl_fecha_inicio

	--ADD: Columnas importantes
	,
	op.tiv_fecha_vencimiento, --notar op.
	op.tiv_tipo_valor,
	op.tiv_subtipo,
	htp_precio_compra, --notar htp_
	--htp_compra,
	cupoper_tfl_fecha_inicio -- notar tfl_ ... inicio
	
	--ADD: Columnas menores ordenadas por tipo de dato
	,
	liq_rendimiento,
	liq_total_interes,
	round(liq_comision_bolsa*proporcional_htp_liq,2),
	round(liq_comision_casa*proporcional_htp_liq,2),
	op.liq_id,
	liq_market,
	liq_numero_bolsa,
	tpo_tipo_valoracion

	--ADD: Columnas que estaban en la vista compraventaflujo
	,vencimiento=case when def_int_cobrado is null then coalesce(
		 CASE WHEN RETR2.RETR_INTERES=1 THEN RETR2.RETR_FECHA_COBRO END
		,tfl_fecha_vencimiento) else null end
	--Columna amortizacion: (crítica)
	,amortizacion=case when isnull(tpo_redondear_amortizacion,1)=1 then
		round(( montoOper/isnull(nullif(cupOper_tfl_capital,0),1e) )*tfl_amortizacion,5)
	else
		round(( montoOper/isnull(nullif(cupOper_tfl_capital,0),1e) )*tfl_capital,5)
		-round(( montoOper/isnull(nullif(cupOper_tfl_capital,0),1e) )*(tfl_capital-tfl_amortizacion),5)
	end
	*isnull(def_cobrado,1)
	,iAmortizacion=   round(
		case when op.tiv_subtipo=3 then
			case when tpo_id_anterior is null then 0/*valefeoper*/ else
				--especial convenio a descuento
				( montoOper/isnull(nullif(cupOper_tfl_capital,0),1e) )*
				tfl_capital
				-(8-(tfl_periodo-1))*ufo_rendimiento
			end
		else
			( montoOper/isnull(nullif(cupOper_tfl_capital,0),1e) )*
			tfl_capital
		end
		*
		case when op.tiv_interes_irregular=1 and tfl_interes>0 then
			tfl_interes
		else
			case when op.tiv_subtipo=3 then liq_rendimiento else iTasa_interes end
			*dias_cupon/(base_denominador*100)
		end
		,3)
		*isnull(def_cobrado,1)
	,op.htp_comision_bolsa
	,prEfectivo=isnull(tpo.tpo_precio_efectivo/100.0,
		(op.valefeoper
		+isnull(case when op.htp_fecha_operacion>='20220601' then op.htp_comision_bolsa end,0)
		)/op.montooper
	)
	,saldo = round(( montoOper/isnull(nullif(cupOper_tfl_capital,0),1e) )*tfl_capital,3)
	,op.tiv_interes_irregular
	,TFL_INTERES
	,tpo.FON_ID
	,op.HTP_TIENE_VALNOM
	,ufo.ufo_uso_fondos
	,ufo.ufo_rendimiento
	,op.tiv_tipo_renta
	from	
	bvq_backoffice.HtpCupon op
	join bvq_backoffice.titulos_portafolio tpo on htp_tpo_id=tpo.tpo_id
	join bvq_administracion.TituloFlujoComun tiv
	on op.tiv_id=tiv.tiv_id
	--Quitar filtro de cupones posteriores a fecha de operación
	--and htp_fecha_operacion<tiv.tfl_fecha_vencimiento

	left join bvq_backoffice.defaults def on op.por_id=def.por_id and op.tiv_id=def.tiv_id
	and (datediff(m,def.fecha,tiv.tfl_fecha_vencimiento)>=0
		--and def.def_exacto is null or def.def_exacto is not null and def.fecha=tiv.tfl_fecha_vencimiento
	)  -- defaults: discriminación de vencimientos
	left join bvq_backoffice.retraso retr1 on retr1.retr_tpo_id=htp_tpo_id and retr1.retr_fecha_esperada=tiv.tfl_fecha_inicio
	left join bvq_backoffice.retraso retr2 on retr2.retr_tpo_id=htp_tpo_id and retr2.retr_fecha_esperada=tiv.tfl_fecha_vencimiento
	left join bvq_backoffice.uso_fondos ufo on ufo.tpo_id=tpo.tpo_id and ufo.tfl_id=tiv.tfl_id
end
