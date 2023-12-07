create view bvq_backoffice.HtpCupon as
	select op.tiv_id,
		op.htp_fecha_operacion,
		op.por_id,
		op.htp_tpo_id,
		op.compra_htp_id,
		op.htp_estado,
		op.htp_reportado,
		op.htp_id,
		op.montooper,
		op.htp_precio_compra,
		op.htp_precio_venta,
		--op.htp_numeracion,
		htp_numeracion=case when charindex(' id:',op.htp_numeracion)>0 then left(op.htp_numeracion,charindex(' id:',op.htp_numeracion)-1) else op.htp_numeracion end,
		op.htp_en_transito,
		err.htp_precio_compra err_htp_precio_compra,
		valEfeOper=
			round(coalesce(err.htp_precio_compra,(op.htp_precio_compra+op.htp_precio_venta))/case when cupoper.tiv_tipo_renta=153 then 100 else 1 end,14)
			*op.montoOper,
		itrans=round(
			montoOper*cupOper.itasa_interes
			*case when cupoper.tiv_tipo_base=354 then
				datediff(m,cupOper.tfl_fecha_inicio,htp_fecha_operacion)*30+isnull(nullif(day(htp_fecha_operacion),31),30) - isnull(nullif(day(cupOper.tfl_fecha_inicio),31),30)
			when cupoper.tiv_tipo_base in (355,356) then
				datediff(d,cupOper.tfl_fecha_inicio,htp_fecha_operacion)
			end
			/(cupOper.base_denominador*100)
		,2)*isnull(htp_cobra_primer_cupon,1)*isnull(htp_libre,1),
		itasa_interes cupoper_itasa_interes,
		cupoper.tfl_id cupoper_tfl_id,
		cupoper.tfl_fecha_inicio cupoper_tfl_fecha_inicio,
		cupoper.base_denominador cupoper_base_denominador,
		cupoper.tfl_capital cupoper_tfl_capital,
		liq.liq_numero_bolsa,
		liq.liq_comision_bolsa,
		liq.liq_comision_casa,
		liq.liq_total_interes,
		liq.liq_tot_operacion,
		isnull(htp_cobra_primer_cupon,1) htp_cobra_primer_cupon,
		isnull(htp_libre,1) htp_libre,
		liq_rendimiento=coalesce(liq.liq_rendimiento,op.htp_rendimiento),
		liq.liq_retencion,
		liq_retencion_casa=
			isnull(
				liq_aplica_retencion * convert(float,replace(retencionpct.par_valor,',','.')) * liq_comision_casa, 0
			),
		LIQ_VALOR_NOMINAL,
		liq_market

		--tivchange
		,cupoper.tiv_tipo_valor
		,cupoper.tiv_fecha_vencimiento
		,cupoper.tiv_subtipo
		--,cupoper.tiv_calculo_frecuencia
		--Si es reporto utilizar TPR_SALDO como base del proporcional
		,proporcional_htp_liq=abs(montooper)/coalesce(TPR_SALDO,liq_valor_nominal)*case when tpr.TPR_TIPO_REPORTO=892 then 0 else 1 end
		,op.htp_rendimiento_retorno
		,op.htp_tir
		,liq.liq_id
		,RETR.RETR_FECHA_COBRO
		,RETR.RETR_CAPITAL
		,RETR.RETR_INTERES
		,tiv_interes_irregular
	from bvq_backoffice.historico_titulos_portafolio op
		--Averiguar si es reporto para utilizar TPR_SALDO como base del proporcional
		left join BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO tpr
		on TPR_TIPO_REPORTO=854 and tpr.HTP_ID=op.htp_id+1 or tpr.tpr_tipo_reporto=892 and tpr.htp_id=op.htp_id-1

	left join bvq_backoffice.error_compra err on op.htp_id=err.htp_id
	left join bvq_backoffice.liquidacion liq on liq.liq_id=op.liq_id
	left join bvq_administracion.TituloFlujoComun
	cupOper
	on op.tiv_id=cupOper.tiv_id
	--and htp_fecha_operacion<cupOper.tfl_fecha_vencimiento and htp_fecha_operacion>=cupOper.tfl_fecha_inicio
	--PV: error con registros con flujos que presentan hora
	and datediff(dd,cupOper.tfl_fecha_vencimiento,htp_fecha_operacion)<0 and datediff(dd,cupOper.tfl_fecha_inicio,htp_fecha_operacion)>=0
	left join BVQ_BACKOFFICE.RETRASO RETR ON OP.HTP_TPO_ID=RETR.RETR_TPO_ID AND RETR.RETR_FECHA_ESPERADA=cupOper.TFL_FECHA_INICIO
	join bvq_administracion.parametro retencionpct on retencionpct.par_codigo='PAR_RET_LIQ_CV'
	where htp_estado=352
	and isnull(htp_reportado,0)=0
