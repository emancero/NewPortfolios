create view bvq_backoffice.SecuenciaCompra as
	select sec=row_number() over (partition by htp_tpo_id order by htp_fecha_operacion, htp_id), htp_id, htp_tpo_id
	from bvq_backoffice.historico_titulos_portafolio htp
	where htp_estado=352 and htp_compra>0