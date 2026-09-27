create procedure bvq_administracion.GenerarTasaValorCompact as
begin
	truncate table bvq_administracion.tasavalorcompact
	insert into bvq_administracion.TasaValorCompact with (tablock)(tfl_id,tva_valor_tasa)
	select distinct tfl_id,
	(
		select top 1 tva_valor_tasa
		from bvq_administracion.tasa_valor
		where tta_id=tiv_tipo_tasa and tva_fecha_tasa_valor<=tfl_fecha_inicio
		order by tva_fecha_tasa_valor desc
	)
	from bvq_backoffice.historico_titulos_portafolio htp
	join bvq_administracion.titulo_valor tiv on htp.tiv_id=tiv.tiv_id
	join bvq_administracion.titulo_flujo_comun tfl on tfl.tiv_id=tiv.tiv_id and htp_fecha_operacion<tfl.tfl_fecha_vencimiento
	where tiv_tipo_tasa not in (365,602,58)
end
