create procedure BVQ_ADMINISTRACION.PrepararValoracionLinealCache as
begin
	truncate table BVQ_ADMINISTRACION.VALORACION_LINEAL_CACHE
	insert into BVQ_ADMINISTRACION.VALORACION_LINEAL_CACHE(
		cc,tiv_id,f,lastValDate,arranqueValLineal,tiv_tipo_valor,tiv_fecha_vencimiento
		,tiv_split_de)
	select c cc,tiv.tiv_id
		,f=max(convert(int,vpr_fecha)*1e8+vpr_id)
		,lastValDate=max(lastValDate),arranqueValLineal,tiv_tipo_valor=max(tiv_tipo_valor),tiv_fecha_vencimiento=max(tiv_fecha_vencimiento)
		,tiv_split_de=max(tiv_split_de)
	from (
			select tiv.*,c,
			lastValDate=
				case when
					tiv.tiv_tipo_renta=153 and datediff(d,c,tiv_fecha_vencimiento)<=365 and c>=(select tpor_tiempo from bvq_backoffice.tiempos_portafolio where tpor_codigo='ARRANQUE_VAL_LINEAL2')
					--and tiv_tipo_valor not in (10,13)
					and tiv_subtipo not in (3) and isnull(ipr.ipr_es_cxc,0)=0
					--or tiv_tipo_valor in (10,32)
					or tiv_subtipo in (3)
					and c>=arranqueValLineal
				then
					case when c>=(select tpor_tiempo from bvq_backoffice.tiempos_portafolio where tpor_codigo='ULT_VALORACION_CORREGIDA') then -- ANTES_DE_VARIABLE: '2016-06-01T00:00:00'
						ult_valoracion
					else
						dateadd(d,-365,tiv_fecha_vencimiento)
					end
				end,
			arranqueValLineal
			from bvq_administracion.TituloValorUltVal2 tiv
			left join bvq_backoffice.titulos_portafolio tpo on tpo.tiv_id=tiv.tiv_id
			left join bvq_backoffice.isspol_progs ipr on ipr.IPR_NOMBRE_PROG=tpo.tpo_prog
			join
			corteslist cl on 1=1
			join (select arranqueValLineal=tpor_tiempo from bvq_backoffice.tiempos_portafolio where tpor_codigo='ARRANQUE_VAL_LINEAL') aux on 1=1 -- ANTES_DE_VARIABLE '2015-12-31T23:57:59', FECHA_CAMBIO '2016-04-30T23:57:59'
	) tiv

	--union con todos los precios (optimizar!)
	join bvq_administracion.VprPortafolio vpr
	on vpr.tiv_id=coalesce(nullif(tiv.tiv_split_de,0),tiv.tiv_id)
	and vpr_fecha<=coalesce(lastValDate,dateadd(d,0,c)) --ojo con este coalesce!

	group by tiv.tiv_id,c,arranqueValLineal
end
