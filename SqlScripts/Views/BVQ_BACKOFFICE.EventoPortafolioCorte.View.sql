﻿exec dropifexists 'bvq_backoffice.EventoPortafolioCorte'
go
create view bvq_backoffice.EventoPortafolioCorte as
	select
	c.c,
	cortenum,
	amortizacion=	-sum(amortizacion-isnull(remaining,0)),
	sal=	sum(montooper-isnull(remaining,0)),
	salSinCupon=	sum(montoOperSinCupon-isnull(remaining,0)),
	iamortizacion=	sum(iamortizacion),

	alliamortizacion=	sum(alliamortizacion),
	acc=	sum(acc),

	valefeoper=	sum(valefeoper),
	itrans=	sum(itrans),
	cupoper_tfl_fecha_inicio=	max(cupoper_tfl_fecha_inicio),

	htp_tpo_id ,
	rnd=	max(rnd),
	am=	sum(tfl_capital-tfl_amortizacion),
	rem=	sum(remaining),
	fecha_compra=	min(case when oper=0 then htp_fecha_operacion end),
	max_fecha_compra=	max(case when oper=0 and montooper>0 then htp_fecha_operacion end),
	max_precio_compra=	max(case when oper=0 and montooper>0 then htp_precio_compra end),
	max_compra=	max(case when oper=0 and montooper>0 then montooper end),
	max_rendimiento=	max(case when oper=0 and montooper>0 then liq_rendimiento end),
	pond_rendimiento=	(SUM( case when oper=0 then ABS(montooper)*liq_rendimiento else 0 end)/SUM(case when oper=0 then abs(montooper) else 0 end)),
	max_interes=	max(case when oper=0 and montooper>0 then liq_interes_total end),
	max_comision_bolsa=	max(case when oper=0 and montooper>0 then liq_comision_bolsa end),
	max_comision_casa=	max(case when oper=0 and montooper>0 then liq_comision_casa end),
	max_bolsa=	max(case when oper=0 and montooper>0 then liq_market end),
	max_numero_bolsa=	max(case when oper=0 and montooper>0 then liq_numero_bolsa end),
	max_liq_id=	null,--				max(case when oper=0 and montooper>0 then liq_id end),
	pond_precio_compra=			(SUM( case when oper=0 and montooper>0 then abs(montooper)*htp_precio_compra else 0 end)/SUM(case when oper=0 and montooper>0 then abs(montooper) else 1e-5 end)),
	

	tiv_fecha_vencimiento=	max(tiv_fecha_vencimiento),
	tiv_tipo_valor=	max(tiv_tipo_valor),
	tiv_subtipo=	max(tiv_subtipo),
	--tiv_calculo_frecuencia=	max(tiv_calculo_frecuencia),

	cupoper_base_denominador=	min(cupoper_base_denominador),
	latest_vencimiento=	max(tfl_fecha_vencimiento2)

	,prox_capital=(
		select min(tfl_fecha_vencimiento)
		from bvq_backoffice.compra_venta_flujo where
		tfl_fecha_vencimiento>=c
		and htp_tpo_id=e.htp_tpo_id
		and
		case when isnull(tpo_redondear_amortizacion,1)=1 then round(orig*tfl_amortizacion,2) else round(orig*tfl_capital,2)-round(orig*tfl_capital_1,2) end
		*isnull(def_cobrado,1)
		<0
	)
	,prox_interes=(
		select min(tfl_fecha_vencimiento)
		from bvq_backoffice.compra_venta_flujo where
		tfl_fecha_vencimiento>=c
		and htp_tpo_id=e.htp_tpo_id
		and round(orig*tfl_capital*iTasa_interes*dias_cupon/(base_denominador*100),2)*isnull(def_cobrado,1)>0
		and tfl_fecha_vencimiento<>'9999-12-31T23:59:59'
	),

	
	valpre= case 	when (select isnull(tpo_tipo_valoracion,0) from bvq_backoffice.titulos_portafolio where tpo_id=e.htp_tpo_id)=1
					then (select sum(valPre-intTrans) from [BVQ_ADMINISTRACION].[valoracionCostoAmortizado] val where val.htp_tpo_id=e.htp_tpo_id and val.fechaVal=c.c and val.htp_fecha_operacion<=c.c) --valoraba títulos que todavía no estaban comprados
					else (
						select sum
						(
							(amortizacion+iamortizacion)/
							power
							(
								1+cvf.itasa_interes/100.0/case when tfl_capital=0 then 1 else tiv_frecuencia end
								,tiv_frecuencia
								*
								dbo.fndias(c,cvf.tfl_fecha_vencimiento,tiv_tipo_base)/360.0
							)
							-case when c between cvf.tfl_fecha_inicio and dateadd(d,-1,cvf.tfl_fecha_vencimiento) then dbo.fnDias(cvf.tfl_fecha_inicio,c,cvf.tiv_tipo_base)/dbo.fnDias(tfl_fecha_inicio,cvf.tfl_fecha_vencimiento,cvf.tiv_tipo_base)*iamortizacion else 0 end
						)from bvq_backoffice.compraventaflujo cvf join corteslist c on tfl_fecha_vencimiento>=c where tfl_capital>0-- where tfl_fecha_vencimiento>=c
						and htp_tpo_id=e.htp_tpo_id and c=c.c
					)
				end
	,(
		select top 1 htp_precio_compra from bvq_backoffice.historico_titulos_portafolio
		where htp_tpo_id=e.htp_tpo_id and htp_fecha_operacion<=c and htp_precio_compra<>0 order by htp_fecha_operacion desc,htp_id desc
	) htp_precio_compra
	,(
		select top 1 htp_compra from bvq_backoffice.historico_titulos_portafolio
		where htp_tpo_id=e.htp_tpo_id and htp_fecha_operacion<=c and htp_precio_compra<>0 order by htp_fecha_operacion desc,htp_id desc
	) htp_compra
	,hiperb=(select sum(hiperb) from [BVQ_ADMINISTRACION].[valoracionCostoAmortizado] val where val.htp_tpo_id=e.htp_tpo_id and val.fechaVal=c.c and val.htp_fecha_operacion<=c.c)
	from bvq_backoffice.EventoPortafolio e
	join corteslist c on htp_fecha_operacion<=c
	--where  isnull(htp_reportado,0)=0-- or c>='2016-09-30T23:57:59'
	group by htp_tpo_id,c,cortenum

go-- Add your test scenario here --

