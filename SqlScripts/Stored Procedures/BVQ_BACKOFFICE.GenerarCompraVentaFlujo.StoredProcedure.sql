exec dropifexists 'bvq_backoffice.GenerarCompraVentaFlujo'
go
create procedure bvq_backoffice.GenerarCompraVentaFlujo as
begin
	truncate table bvq_backoffice.compra_venta_flujo
	insert into bvq_backoffice.compra_venta_flujo with (tablock) (cvf_id,htp_id,tiv_id,por_id,htp_tpo_id,compra_htp_id,htp_fecha_operacion,montoOper,valEfeOper,itrans,orig,htp_numeracion,tiv_tipo_base,tfl_fecha_inicio,tfl_fecha_vencimiento,tfl_fecha_vencimiento2
	,tfl_id,tfl_capital,tfl_amortizacion,def_cobrado,def_int_cobrado,def_cobrado_2,itasa_interes,dias_cupon,base_denominador/*,vencimiento_esperado*/,cupoper_tfl_id,htp_cobra_primer_cupon,htp_libre,tfl_capital_1,tpo_redondear_amortizacion,htp_reportado
	,tiv_frecuencia,cupoper_tfl_capital,htp_rendimiento_retorno,htp_tir,TFL_PERIODO,tfl_fecha_inicio_orig)
	select
	row_number() over (order by op.htp_id,op.tiv_id,tiv.tfl_id) cvf_id,
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
	tfl_fecha_vencimiento=coalesce(retr2.retr_fecha_cobro,tiv.tfl_fecha_vencimiento),
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
	from
	bvq_backoffice.HtpCupon op
	join bvq_backoffice.titulos_portafolio tpo on htp_tpo_id=tpo.tpo_id
	join bvq_administracion.TituloFlujoComun tiv
	on op.tiv_id=tiv.tiv_id
	and htp_fecha_operacion<tiv.tfl_fecha_vencimiento
	left join bvq_backoffice.defaults def on op.por_id=def.por_id and op.tiv_id=def.tiv_id
	and (datediff(m,def.fecha,tiv.tfl_fecha_vencimiento)>=0
		and def.def_exacto is null or def.def_exacto is not null and def.fecha=tiv.tfl_fecha_vencimiento
	)  -- defaults: discriminación de vencimientos
	left join bvq_backoffice.retraso retr1 on retr1.retr_tpo_id=htp_tpo_id and retr1.retr_fecha_esperada=tiv.tfl_fecha_inicio
	left join bvq_backoffice.retraso retr2 on retr2.retr_tpo_id=htp_tpo_id and retr2.retr_fecha_esperada=tiv.tfl_fecha_vencimiento
end
