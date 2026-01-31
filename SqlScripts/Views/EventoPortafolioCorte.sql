CREATE view bvq_backoffice.EventoPortafolioCorte as
	select
	--Cambio: Aumentar campo remaining para detectar inconsistencias con las siguientes versiones
	remaining=sum(isnull(remaining,0)),

	c.c,
	cortenum,
	amortizacion=	-sum(amortizacion-isnull(remaining,0)),
	sal=	sum(
		--montooper
		coalesce(
			-evp_valor_efectivo,
			--case when HTP_TIENE_VALNOM=1 then montooper end
			montooperOld
		)
		--+isnull(-evp_valor_efectivo,0)
		-isnull(remaining,0)
	),
	salNewValNom=	sum(
		--montooper
		coalesce(
			-evp_valor_efectivo,
			montooper--case when HTP_TIENE_VALNOM=1 then montooper end
		)
		--+isnull(-evp_valor_efectivo,0)
		-isnull(remaining,0)
	),
	salSinCupon=	sum(montoOperSinCupon-isnull(remaining,0)),
	iamortizacion=	sum(iamortizacion),

	alliamortizacion=	sum(alliamortizacion),
	acc=	sum(acc),

	valefeoper=	sum(valefeoper),
	itrans=	sum(itrans),
	cupoper_tfl_fecha_inicio=	min(case when oper=0 then cupoper_tfl_fecha_inicio end),

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
	max_liq_id=	null,--					max(case when oper=0 and montooper>0 then liq_id end),
	pond_precio_compra=			(SUM( case when oper=0 and montooper>0 then abs(montooper)*htp_precio_compra else 0 end)/SUM(case when oper=0 and montooper>0 then abs(montooper) else 1e-5 end)),
	

	tiv_fecha_vencimiento=	max(tiv_fecha_vencimiento),
	tiv_tipo_valor=	max(tiv_tipo_valor),
	tiv_subtipo=	max(tiv_subtipo),
	--tiv_calculo_frecuencia=	max(tiv_calculo_frecuencia),

	cupoper_base_denominador=	min(cupoper_base_denominador),
	latest_vencimiento=	max(case when tfl_fecha_vencimiento2<=c or tfl_fecha_vencimiento2 is null then tfl_fecha_vencimiento2 end)

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
		--CAMBIO: De 2 a 3 (2 decimales causa pérdida de precisión en la comparación con 0)
		and round(orig*tfl_capital*iTasa_interes*dias_cupon/(base_denominador*100),3)*isnull(def_cobrado,1)>0
		and tfl_fecha_vencimiento<>'9999-12-31T23:59:59'
	),

	
	valpre= case 	when 1=1--(select isnull(tpo_tipo_valoracion,0) from bvq_backoffice.titulos_portafolio where tpo_id=e.htp_tpo_id)=1
					then (select sum(valPre-intTrans) from [BVQ_ADMINISTRACION].[valoracionCostoAmortizado] val where val.htp_tpo_id=e.htp_tpo_id and val.fechaVal=c.c and val.htp_fecha_operacion<=c.c) --valoraba títulos que todavía no estaban comprados
					/*else (
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
					)*/
				end
	--Cambio: Solo incluir htp no reportados y activos. En ciertas bases causan valores negativos.
	,(
		select top 1 htp_precio_compra from bvq_backoffice.historico_titulos_portafolio
		where htp_tpo_id=e.htp_tpo_id and htp_fecha_operacion<=c and htp_precio_compra<>0 
		and isnull(htp_reportado,0)=0 and htp_estado=352
		order by htp_fecha_operacion asc,htp_id asc
	) htp_precio_compra
	,(
		select top 1 htp_compra=sum(htp_compra) from bvq_backoffice.historico_titulos_portafolio
		where htp_tpo_id=e.htp_tpo_id and htp_fecha_operacion<=c and htp_precio_compra<>0 
		and isnull(htp_reportado,0)=0 and htp_estado=352
		group by htp_tpo_id,htp_fecha_operacion
		order by htp_fecha_operacion asc--,htp_id asc
	) htp_compra
	,(
		select top 1 htp_rendimiento from bvq_backoffice.historico_titulos_portafolio
		where htp_tpo_id=e.htp_tpo_id and htp_fecha_operacion<=c and htp_precio_compra<>0 
		and isnull(htp_reportado,0)=0 and htp_estado=352
		order by htp_fecha_operacion asc,htp_id asc
	) htp_rendimiento
	,hiperb=(select sum(hiperb) from [BVQ_ADMINISTRACION].[valoracionCostoAmortizado] val where val.htp_tpo_id=e.htp_tpo_id and val.fechaVal=c.c and val.htp_fecha_operacion<=c.c)
	,ufo_uso_fondos=sum(case when htp_tpo_id in (1688,1689,1691,1692) and evt_fecha is not null and datediff(d,evt_fecha,'20241212')<>0 and datediff(d,evt_fecha,'20250214')<>0 then 0 else ufo_uso_fondos end)
	,ufo_rendimiento=sum(case when htp_tpo_id in (1688,1689,1691,1692) and evt_fecha is not null and datediff(d,evt_fecha,'20241212')<>0 and datediff(d,evt_fecha,'20250214')<>0 then 0 else ufo_rendimiento end)
	,MIN_TIENE_VALNOM=min(HTP_TIENE_VALNOM)
	,prEfectivo=min(prEfectivo)
	,fechaInicioOriginal=max(case when coalesce(evt_fecha,cupoper_tfl_fecha_inicio)<=c then coalesce(evt_fecha,cupoper_tfl_fecha_inicio) end)
	,totalUfoUsoFondos=max(totalUfoUsoFondos)
	,totalUfoRendimiento=max(totalUfoRendimiento)
	,interesCoactivo=(
		select sum(evp_valor_efectivo)
		from bvq_backoffice.evento_portafolio evp
		where
		es_vencimiento_interes=1
		and evp_abono=1
		and oper_id=1
		and evt_fecha<=c
		and evp.evp_tpo_id=e.htp_tpo_id
	)
	,FON_ID=MAX(FON_ID)
	,fecha_ultimo_pago=(
		select max(evp_fecha_original)
		from bvq_backoffice.evento_portafolio e
		join bvq_backoffice.retraso retr on 
		evp_tpo_id=retr_tpo_id
		and evt_fecha>=retr_fecha_esperada
		and evt_fecha<c
		and es_vencimiento_interes=1
		join (select xtpo_id=1516) x on x.xtpo_id in (max(tpo.tpo_id_anterior),htp_tpo_id)
		where evp_tpo_id in (max(tpo.tpo_id_anterior),htp_tpo_id)
		and c>='20251031'
	)
	from bvq_backoffice.EventoPortafolio e
	join (select tpo_id_anterior, tpo_id from bvq_backoffice.titulos_portafolio) tpo on e.htp_tpo_id=tpo.tpo_id
	join corteslist c on
	coalesce(
	evt_fecha,
	htp_fecha_operacion
	)
	<=c
	--where  isnull(htp_reportado,0)=0-- or c>='2016-09-30T23:57:59'
	--where HTP_TIENE_VALNOM=1
	group by htp_tpo_id,c,cortenum
