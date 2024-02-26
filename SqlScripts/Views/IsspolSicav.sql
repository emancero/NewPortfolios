create view bvq_backoffice.IsspolSicav as
	select r=row_number() over (partition by tiv_tipo_valor order by tiv_fecha_emision desc)
	,tpo.tpo_objeto
	,pju.pju_identificacion
	,tiv.tiv_tipo_valor
	,tiv.tiv_fecha_emision
	,tiv.tiv_fecha_vencimiento
	,adm.adm_nombre
	,tiv_clase,tiv_tasa_interes
	,tiv_tipo_renta
	,tfl_fecha_inicio
	,htp.*
	,precioCompra=htp_precio_compra/case when tiv_tipo_renta=153 then 100.0 else 1.0 end
	,ems.*
	,tvl.tvl_codigo
	,tvl.tvl_nombre
	,tpo_numeracion
	--comisiones
	,comisionBolsa=htp_comision_bolsa--compra*0.0009
	,comisionOperador=tpo_comisiones--compra*0.002
	,tipo_papel=coalesce(imtp_sis,tvl.tvl_codigo)
	,e.idEmisor
	,tp.id_tipo_papel
	,id_seguro_tipo=imf.imf_sis
	,por_codigo
	,tpo_interes_transcurrido
	,itrans=round(
		montoOper*cupoper.itasa_interes--case when tpo_id in (168,197) then cupOper.itasa_interes else tiv_tasa_interes end
		*case when cupoper.tiv_tipo_base=354 then
			datediff(m,cupOper.tfl_fecha_inicio,htp_fecha_operacion)*30+isnull(nullif(day(htp_fecha_operacion),31),30) - isnull(nullif(day(cupOper.tfl_fecha_inicio),31),30)
		when cupoper.tiv_tipo_base in (355,356) then
			datediff(d,cupOper.tfl_fecha_inicio,htp_fecha_operacion)
		end
		/(case when base.itc_valor in ('360','365') then base.itc_valor end*100)
	,2)*isnull(htp_cobra_primer_cupon,1)*isnull(htp_libre,1)
	,retencionBolsa=htp_comision_bolsa*isnull(hfr.hfr_factor,0.0275)
	,retencionOperador=tpo_comisiones*isnull(hfr.hfr_factor,0.0275)
	from bvq_backoffice.titulos_portafolio tpo
	join bvq_administracion.titulo_valor tiv on tpo.tiv_id=tiv.tiv_id	
	join bvq_administracion.tipo_valor tvl on tiv.tiv_tipo_valor=tvl.tvl_id
	left join bvq_administracion.isspol_mapa_tipo_papel imtp on imtp.imtp_sicav=tvl.tvl_codigo
	left join siisspolweb.siisspolweb.inversion.tipo_papel tp on tp.codigo=coalesce(
		case when tvl_codigo='PCO' and tiv_subtipo=4 then 'PCI'
		when tvl_codigo='ACC' and tiv_subtipo=2 then 'APR'
		when tvl_codigo='BE' and tpo_acta like '2[0-9][0-9][0-9]' then 'BG' end,
		imtp_sis,tvl.tvl_codigo) and tp.estado='A'
	join bvq_backoffice.historico_titulos_portafolio htp on htp.htp_tpo_id=tpo.tpo_id
	join bvq_administracion.emisor ems on tiv_emisor=ems_id
	join bvq_backoffice.portafolio por on por.por_id=tpo.por_id
	left join bvq_administracion.administradora_de_fondos adm on adm.adm_id=ems.adm_id
	left join bvq_administracion.persona_juridica pju on pju.pju_id=ems.pju_id
	left join (
		select tiv_id,itasa_interes,tfl_fecha_inicio,tfl_fecha_vencimiento,tiv_tipo_base
		from bvq_administracion.tituloflujocomun
	) cupoper on cupoper.tiv_id=tiv.tiv_id
		and htp_fecha_operacion between tfl_fecha_inicio and dateadd(s,-1,tfl_fecha_vencimiento)

	left join siisspolweb.siisspolweb.inversion.vis_emisor_calificacion e on e.identificacion=pju_identificacion
	--mapa de fondos
	left join bvq_administracion.isspol_mapa_fondos imf on imf.imf_sicav=tpo.por_id
	join bvq_administracion.item_catalogo base on tiv.tiv_tipo_base=base.itc_id
	left join bvq_backoffice.historico_factor_retencion hfr on htp.htp_fecha_operacion between hfr.hfr_fecha_desde and hfr.hfr_fecha_hasta
	where htp_compra>0
	and tpo.tpo_estado=352 and htp.htp_estado=352
