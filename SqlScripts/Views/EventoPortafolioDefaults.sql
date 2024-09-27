CREATE VIEW bvq_backoffice.EventoPortafolioDefaults as
	select d.fecha,e.htp_id,tpo.tpo_numeracion,e.htp_fecha_operacion
	from bvq_backoffice.EventoPortafolioAprox e
	join bvq_backoffice.TITULOS_PORTAFOLIO tpo on e.htp_tpo_id=tpo.TPO_ID
	join BVQ_BACKOFFICE.defaults d on d.por_id=tpo.POR_ID and d.tiv_id=tpo.tiv_id
