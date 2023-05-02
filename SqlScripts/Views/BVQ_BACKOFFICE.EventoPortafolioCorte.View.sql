create view bvq_backoffice.EventoPortafolioCorte as


	select
	 s.htp_tpo_id,c,cortenum
	,sal=salRaw-case when abs(remaining) between 5e-3 and 1e5 and fin=1 and cap>0 and cobrado=1 then remaining else 0 end
	,salSinCupon=salSinCupon0-case when abs(remaining) between 5e-3 and 1e5 and fin=1 and cap>0 and cobrado=1 then remaining else 0 end
	,iamortizacion
	,acc
	,prox_interes
	--fecha_compra,pond_rendimiento, pond_precio_compra
	
	,
	amortizacion=-(amortizacion-case when abs(remaining) between 5e-3 and 1e5 and fin=1 and cap>0 and cobrado=1 then remaining else 0 end),
	valefeoper,
	itrans,
	cupoper_tfl_fecha_inicio,

	fecha_compra,

	max_fecha_compra,
	max_precio_compra,

	max_compra,
	max_rendimiento,
	max_interes,
	max_comision_bolsa,
	max_comision_casa,
	max_bolsa,
	max_numero_bolsa,
	max_liq_id,

	pond_rendimiento,
	pond_precio_compra,

	valpre,--=case when por_id=140 then valpre end,


	--htp_precio_compra0=s.htp_precio_compra,
	--htp_compra0=s.htp_compra,

	--htp.htp_precio_compra,
	--htp.htp_compra,
	htp_compra=convert(bigint,convert(varbinary,substring(htp_idx,21,8)))/1e3,
	htp_precio_compra=convert(bigint,convert(varbinary,substring(htp_idx,13,8)))/1e7,

	hiperb=0,

	tiv_fecha_vencimiento,
	tiv_tipo_valor,
	tiv_subtipo,
	cupoper_base_denominador,
	latest_vencimiento,
	prox_capital,
	remaining=case when abs(remaining) between 5e-3 and 1e5 and fin=1 and cap>0 and cobrado=1 then remaining else 0 end,
	por_id_2=por_id
	from
	(
		select 'new' tip,c,cortenum--=max(cortenum)
		,tpo_tipo_valoracion
		,por_id
		,--isnull(AGG_SALDO,0)+
		amortizacion=sum(
			-case when cvf.tfl_fecha_vencimiento<=c then isnull(htp_cobra_primer_cupon,-1)*isnull(amortizacion,0) else 0 end
		),
		
		salRaw=sum(
			case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id then isnull(montooper,0) else 0 end
		
		--sum(
			-case when cvf.tfl_fecha_vencimiento<=c then isnull(htp_cobra_primer_cupon,-1)*isnull(amortizacion,0) else 0 end
		)
		,
		sum(
			case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id then isnull(montooper,0) else 0 end
			-case when cvf.tfl_fecha_vencimiento<=c then isnull(htp_cobra_primer_cupon,-1)*isnull(amortizacion,0) else 0 end
		) sal0
		,

		sum(
			case when
			cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id then
				isnull(htp_cobra_primer_cupon,1)*isnull(htp_libre,1)*isnull(montooper,0)
			else 0 end
			-case when cvf.tfl_fecha_vencimiento<=c then isnull(htp_cobra_primer_cupon,1)*isnull(case when cupoper_tfl_id=tfl_id then htp_libre end,1)*isnull(amortizacion,0) else 0 end
		) salSinCupon0

		,iAmortizacion=sum(case when cvf.tfl_fecha_vencimiento<=c then iamortizacion end)
		,acc=sum(case when cvf.tfl_fecha_vencimiento<=c then isnull(alliamortizacion,0)-isnull(iamortizacion,0) end)

		,sum(
			case when cupoper_tfl_id=tfl_id then isnull(montooper,0) else 0 end-isnull(htp_cobra_primer_cupon,-1)*isnull(amortizacion,0)
		) remaining
		,max(tfl_capital) cap
		,min(isnull(def_cobrado,1)) cobrado
		,max(case when cvf.tfl_fecha_vencimiento<=c and abs(tfl_capital-tfl_amortizacion) < 5e-6 then 1 else 0 end) fin

		,prox_interes=min(case when cvf.tfl_fecha_vencimiento>=c and tfl_fecha_vencimiento<>'9999-12-31T23:59:59' and iamortizacion>0 then
			tfl_fecha_vencimiento end)
		,prox_capital=min(case when cvf.tfl_fecha_vencimiento>=c and 		case when isnull(tpo_redondear_amortizacion,1)=1 then round(orig*tfl_amortizacion,2) else round(orig*tfl_capital,2)-round(orig*tfl_capital_1,2) end
		*isnull(def_cobrado,1)
		<0 then
			tfl_fecha_vencimiento end)
		
/*		select min(tfl_fecha_vencimiento)
		from bvq_backoffice.compra_venta_flujo where
		tfl_fecha_vencimiento>=c
		and htp_tpo_id=e.htp_tpo_id
		and round(orig*tfl_capital*iTasa_interes*dias_cupon/(base_denominador*100),2)*isnull(def_cobrado,1)>0
		and tfl_fecha_vencimiento<>'9999-12-31T23:59:59'*/
		--,min(case when cvf.tfl_fecha_vencimiento>c and tfl_fecha_vencimiento<>'9999-12-31T23:59:59' then tfl_fecha_vencimiento end) prox_interes

		,htp_tpo_id
		--agregados en una sola labor
		,
		valefeoper=	sum(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id then valefeoper end),
		itrans=	sum(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id then itrans*isnull(htp_cobra_primer_cupon,1)*isnull(htp_libre,1) end),

		tiv_fecha_vencimiento=	max(tiv_fecha_vencimiento),
		tiv_tipo_valor=	max(tiv_tipo_valor),
		tiv_subtipo=	max(tiv_subtipo),
		cupoper_base_denominador=	min(base_denominador),--cupoper_base_denominador,base_denominador

		cupoper_tfl_fecha_inicio= max(
			case when cvf.tfl_fecha_vencimiento<=c then
				tfl_fecha_vencimiento2
			when cvf.htp_fecha_operacion<=c then
				cvf.cupoper_tfl_fecha_inicio
			end
		),

		latest_vencimiento= max(
			case when cvf.tfl_fecha_vencimiento<=c then
				vencimiento
			when cvf.htp_fecha_operacion<=c and def_int_cobrado is null then
				cupoper_tfl_fecha_inicio
			end
		)
,
fecha_compra=min(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id then htp_fecha_operacion end),
max_fecha_compra=max(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id and montooper>0 then htp_fecha_operacion end),
max_precio_compra=max(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id and montooper>0 then htp_precio_compra end)
,

	max_compra=	max(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  and montooper>0 then montooper end),
	max_rendimiento=	max(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  and montooper>0 then liq_rendimiento end),
	pond_rendimiento=	SUM( case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  then ABS(montooper)*liq_rendimiento else 0 end)/
						nullif(SUM(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  then abs(montooper) else 0 end),0),
	max_interes=	max(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  and montooper>0 then liq_interes_total end),
	max_comision_bolsa=	max(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  and montooper>0 then liq_comision_bolsa end),
	max_comision_casa=	max(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  and montooper>0 then liq_comision_casa end),
	max_bolsa=	max(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  and montooper>0 then liq_market end),
	max_numero_bolsa=	max(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  and montooper>0 then liq_numero_bolsa end),
	max_liq_id=					max(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  and montooper>0 then liq_id end),
	pond_precio_compra=	SUM( case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  and montooper>0 then abs(montooper)*htp_precio_compra else 0 end)
						--/SUM(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  and montooper>0 then abs(montooper) else 1e-5 end),
							/nullif(SUM(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id  and montooper>0 then abs(montooper) else 0 end),0)
						,

--select case when 0xFFFFFFFFFFFFFFFFE>=0XFFFFFFFFFFFFFFFFF then 1 else 0 end
/*
select a,convert(varbinary,right(a,9)) from(
	select
	convert(varbinary,
		convert(varchar,convert(varbinary,convert(float,convert(datetime,'2022-06-09T23:22:14'))))
		+convert(varchar,convert(varbinary,convert(decimal(18,6),20000.123456)))
	)
	a
) s
*/

htp_idx=max(case when cvf.htp_fecha_operacion<=c and cupoper_tfl_id=tfl_id and htp_precio_compra<>0 then
	--(convert(bigint,convert(float,htp_fecha_operacion)*24)*1000000+htp_id)--*10000000+convert(int,htp_precio_compra*1000000)
	convert(varbinary,
		convert(varchar,convert(varbinary,convert(float,htp_fecha_operacion)))
		+convert(varchar,convert(varbinary,htp_id))
		+convert(varchar,convert(varbinary,convert(bigint,htp_precio_compra*1e7)))
		+convert(varchar,convert(varbinary,convert(bigint,montooper*1e3)))
	)

	--(convert(bigint,convert(float,htp_fecha_operacion)*24)*1000000+htp_id)--*10000000+convert(int,htp_precio_compra*1000000)
end)
	/*,(
		select top 1 htp_precio_compra from bvq_backoffice.historico_titulos_portafolio
		where htp_tpo_id=cvf.htp_tpo_id and htp_fecha_operacion<=c and htp_precio_compra<>0 order by htp_fecha_operacion desc,htp_id desc
	) htp_precio_compra
	,(
		select top 1 htp_compra from bvq_backoffice.historico_titulos_portafolio
		where htp_tpo_id=cvf.htp_tpo_id and htp_fecha_operacion<=c and htp_precio_compra<>0 order by htp_fecha_operacion desc,htp_id desc
	) htp_compra*/
,



valpre=sum(
	case when tfl_capital>0 and htp_fecha_operacion<=c and datediff(d,c,tfl_fecha_vencimiento)>0 then
		(amortizacion+iamortizacion)/
		power
		(
				1
				+
				case when tiv_tipo_base<>354 then
					htp_tir
				else
					isnull(cvf.htp_rendimiento_retorno,cvf.itasa_interes)
				end
				/100.0
				/case when tfl_capital=0 then 1 else case when tiv_tipo_base<>354 then 1 else tiv_frecuencia end end
			,
				case when tiv_tipo_base<>354 then 1 else tiv_frecuencia end
				*
				((
					fnDias 
					--dbo.fndias(c,cvf.tfl_fecha_vencimiento,tiv_tipo_base)-
					-case when month(c)=2 and day(c) in (28,29) then 30-day(c) else 0 end --ajuste NASD
				)/360.0)
		)
		-
		case when
			--c between cvf.tfl_fecha_inicio and dateadd(d,-1,cvf.tfl_fecha_vencimiento)
			c>=cvf.tfl_fecha_inicio and fnDias--dbo.fnDias(c,cvf.tfl_fecha_vencimiento,cvf.tiv_tipo_base)
			>=0
		then
		(
			dias_cupon2
			--dbo.fnDias(tfl_fecha_inicio,cvf.tfl_fecha_vencimiento,cvf.tiv_tipo_base)
			-(
				fnDias
				--dbo.fnDias(c,cvf.tfl_fecha_vencimiento,cvf.tiv_tipo_base)
				-case when month(c)=2 and day(c) in (28,29) then 30-day(c) else 0 end --ajuste NASD
				+case when month(cvf.tfl_fecha_vencimiento)=2 and day(cvf.tfl_fecha_vencimiento) in (28,29)
				then 30-day(cvf.tfl_fecha_vencimiento) else 0 end --ajuste NASD
			)
		)
		/
		dias_cupon2
		--dbo.fnDias(tfl_fecha_inicio,cvf.tfl_fecha_vencimiento,cvf.tiv_tipo_base)
		*iamortizacion
		else 0 end
	end
)


from(select
		fnDias=1e0*case
		when tiv_tipo_base=354 then
			datediff(m,c,cvf.tfl_fecha_vencimiento)*30
			+ case when day(cvf.tfl_fecha_vencimiento)=31 then 30 else day(cvf.tfl_fecha_vencimiento) end
			- case when day(c)=31 then 30 else day(c) end
		when tiv_tipo_base in (355,356) THEN
			datediff(d,c,cvf.tfl_fecha_vencimiento)
		end
		,
		dias_cupon2=1e0*case
		when tiv_tipo_base=354 then
			datediff(m,cvf.tfl_fecha_inicio,cvf.tfl_fecha_vencimiento)*30
			+ case when day(cvf.tfl_fecha_vencimiento)=31 then 30 else day(cvf.tfl_fecha_vencimiento) end
			- case when day(cvf.tfl_fecha_inicio)=31 then 30 else day(cvf.tfl_fecha_inicio) end
		when tiv_tipo_base in (355,356) THEN
			datediff(d,cvf.tfl_fecha_inicio,cvf.tfl_fecha_vencimiento)
		end
		,*


		from corteslist c
		join
		(

		
			select c1='2022-05-16',c0='2022-05-01',* from bvq_backoffice.compraventaflujo
			--where tiv_fecha_vencimiento>=convert(datetime,'2022-05-01')-- or tiv_fecha_vencimiento is null
		) cvf
		on 1=1--cvf.htp_tpo_id=AGG_TPO_ID
		 
) cvf		

		group by c,htp_tpo_id,cortenum,tpo_tipo_valoracion,por_id
		having min(htp_fecha_operacion)<=c
) s
