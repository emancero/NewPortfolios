CREATE procedure bvq_administracion.GenerarVectores as
begin
	
	--EMN: 3-oct-2026 transmitir vectores de tablas variables de un mismo títulos
	declare @vprid int =(select max(vpr_id) from bvq_administracion.vector_precio)
	insert into bvq_administracion.vector_precio
	(VPR_ID,TIV_ID,VPR_PRECIO,VPR_FECHA,VPR_FECHA_ACTUALIZACION,vpr_duracion_efectiva_anual,vpr_duracion_modificada_anual,vpr_tasa_descuento,vpr_tasa_referencia,vpr_codigo,vpr_rendimiento_equivalente,vpr_margen)
	select @vprId+(row_number() over (order by vpr.vpr_fecha))
	,vpr.TIV_ID,VPR_PRECIO,vpr.VPR_FECHA,VPR_FECHA_ACTUALIZACION,vpr_duracion_efectiva_anual,vpr_duracion_modificada_anual,vpr_tasa_descuento,vpr_tasa_referencia,vpr_codigo,vpr_rendimiento_equivalente,vpr_margen
	from bvq_administracion.vector_precio vpr
	---left join bvq_administracion.
	where not exists (select * from bvq_administracion.vector_precio v where vpr.tiv_id=v.tiv_id and vpr.vpr_fecha=v.vpr_fecha)
	and exists (select * from bvq_administracion.valoracion_tabla_variable vtv where vpr.tiv_id=vtv.tiv_id and vpr.vpr_fecha=vtv.vpr_fecha)


	truncate table bvq_administracion.VprPortafolio

	insert into bvq_administracion.VprPortafolio
	select distinct vpr_fecha,vpr.tiv_id,vpr_id,null--,vpr_ord
	FROM
	BVQ_ADMINISTRACION.VECTOR_PRECIO vpr
	inner join bvq_backoffice.titulos_portafolio tpo on tpo.tiv_id=vpr.tiv_id
	union
	select vpr_fecha,vpr.tiv_id,vpr_id,null 
	from bvq_administracion.VECTOR_PRECIO vpr
	join bvq_administracion.titulo_valor tiv on tiv.tiv_split_de=vpr.tiv_id
	join bvq_backoffice.titulos_portafolio tpo on tiv.tiv_id=tpo.tiv_id
	join corteslist on c between tpo_fecha_ingreso and tiv_fecha_vencimiento

	exec dropifexists 'bvq_backoffice.htpcortes'
	select *
	into bvq_backoffice.htpcortes
	from(
		SELECT row_number() over (
			partition by tpo_id_c,c.c ORDER BY CASE WHEN PAR.PAR_VALOR='SI' THEN 1 ELSE -1 END * datediff(d,0,HTP_FECHA_OPERACION) asc, CASE WHEN PAR.PAR_VALOR='SI' THEN 1 ELSE -1 END * htp_id asc
		) r, htp_precio_compra,h.tiv_id,tpo_id_c,c cc
		,htp_compra,liq_rendimiento--,liq_numero_bolsa,liq_comision_bolsa,liq_comision_operador,liq_total_interes
		FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO h
		JOIN BVQ_BACKOFFICE.TITULOS_PORTAFOLIO TPO ON h.HTP_TPO_ID=TPO.TPO_ID
		left join bvq_backoffice.liquidacion liq on h.liq_id=liq.liq_id
		join corteslist c on HTP_FECHA_OPERACION <= c
		JOIN BVQ_ADMINISTRACION.PARAMETRO PAR on PAR_CODIGO='VALORACION_ASC'
		WHERE htp_precio_compra<>0
	) s where r=1
--0
end
