exec dropifexists 'BVQ_BACKOFFICE.UsoFondos'
go
create view BVQ_BACKOFFICE.UsoFondos as
	with a as(
		select ems_codigo,diasVen=datediff(d,x_ing,tpo_fecha_vencimiento_anterior),tpo_fecha_vencimiento_anterior,usoIni=case when x_ult>tpo_fecha_vencimiento_anterior then x_ult else tpo_fecha_vencimiento_anterior end
		,susc,TPO_FECHA_SUSC_CONVENIO,rendimiento=coalesce(htp_rendimiento,tiv_tasa_interes)/100.0,tiv_tasa_interes,htp_rendimiento
		,cant=tpo_cantidad--sum(tpo_cantidad) over (partition by tpo_numeracion)
		,tieneIntVen=isnull(tieneIntVen,1)
		,htp_precio_compra,tvl_codigo
		,tpo_numeracion
		,tiv_id
		,tpo_id
		--case when
		/*,tpo_fecha_vencimiento_anterior*/,valNomAnt=case when ems_codigo<>'beloro' then tpo_valnom_anterior end
		--,sumEmi=round(sum(tpo_cantidad),0)
		from tpoEms t
		left join (
			select 'INB' x_ems_codigo,'20200910' x_tiv_fecha_vencimiento,'20220623' x_ult,0 tieneIntVen union
			select 'INB','20201127','20201218',0 union
			select 'INM_TESLA','20190923','20190924',0 union
			select 'INM_TESLA','20200903','20200904',1 union--
			select 'INTEROCEANICA','20191002','20200707',0
		) S on t.ems_codigo=x_ems_codigo and tpo_fecha_vencimiento_anterior=x_tiv_fecha_vencimiento
		--join (select distinct uso_fondosFloat,rendimientoFloat,emisor from _temp.convenios) c on t.ems_codigo=c.emisor
		join (select tpo_fecha_susc_convenio susc, tpo_id xtpo_id, tpo_fecha_ingreso x_ing from bvq_backoffice.titulos_portafolio) tpo on xtpo_id=tpo_id_anterior
		where TPO_FECHA_VENCIMIENTO_ANTERIOR is not null

	)
	,b as(
		select ems_codigo,diasVen,diasSusc=datediff(d,usoIni,susc),usoini,susc,rendimiento,tiv_tasa_interes,htp_rendimiento,tpo_fecha_vencimiento_anterior
		,cant,tieneIntVen
		,htp_precio_compra
		,valefe=round(a.cant*case when tieneIntVen=1 then htp_precio_compra else 1 end,2)
		,tvl_codigo
		,tpo_numeracion
		,tiv_id
		,tpo_id
		from a
		--order by ems_codigo,tpo_fecha_vencimiento_anterior
	)
	--insert into BVQ_BACKOFFICE.USO_FONDOS(TFL_ID,UFO_USO_FONDOS,UFO_RENDIMIENTO,TPO_NUMERACION)
	select tfl.tfl_id,intVen=case when tvl_codigo='FAC' then cant-valEfe else tieneIntVen*rendimiento*diasven/360.0*b.cant end,intSusc=rendimiento*diasSusc/360.0*b.valefe
	,tpo_numeracion
	,cant,htp_precio_compra,valefe
	,totalCantidad=sum(cant) over (partition by tpo_numeracion)
	,n=count(*) over (partition by tpo_id)
	--,tvl_codigo,* 
	from b
	join bvq_administracion.titulo_flujo tfl on tfl.tiv_id=b.tiv_id
	--join bvq_backoffice.fondo fon on fon.FON_NUMERACION=b.TPO_NUMERACION
