create view bvq_administracion.TituloFlujoComun as
	select tfl.*,tiv_tipo_base,tiv_tasa_interes,tiv_tasa_margen,tiv_tipo_tasa,tiv_tipo_renta,
	iTasa_interes=coalesce(tiv_tasa_margen+ts.tva_valor_tasa,tiv_tasa_interes),
	dias_cupon=
		case when tiv_tipo_base=354 then
			datediff(m,tfl_fecha_inicio,tfl_fecha_vencimiento)*30+isnull(nullif(day(tfl_fecha_vencimiento),31),30) - isnull(nullif(day(tfl_fecha_inicio),31),30)
			--solo en dias_cupon se emplea método NASD
			- case when day(tfl_fecha_inicio) in (28,29) and month(tfl_fecha_inicio)=2 and day(tfl_fecha_vencimiento)>29 then
				30-day(tfl_fecha_inicio) else 0 end
			+ case when day(tfl_fecha_vencimiento) in (28,29) and month(tfl_fecha_vencimiento)=2 and day(tfl_fecha_inicio)>29 then
				30-day(tfl_fecha_vencimiento) else 0 end
		when tiv_tipo_base in (355,356) THEN
			datediff(d,tfl_fecha_inicio,tfl_fecha_vencimiento)
		end,
	base_denominador=case when base.itc_valor in ('360','365') then base.itc_valor end,
	tva_valor_tasa
	--tivchange
	,tiv_tipo_valor
	,tiv_fecha_vencimiento
	,tiv_subtipo
	,tiv_frecuencia
	,tiv_calculo_frecuencia
	,tiv_interes_irregular
	from
	bvq_administracion.titulo_flujo_comun tfl join
	bvq_administracion.titulo_valor tiv on
		tfl.tiv_id=tiv.tiv_id left join
	bvq_administracion.TasaValorCompact ts on ts.tfl_id=tfl.tfl_id join
	bvq_administracion.item_catalogo base on tiv.tiv_tipo_base=base.itc_id
