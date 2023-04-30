create view bvq_backoffice.PortafolioCorteProg as
	select IPR_NOMBRE_PROG,IPR_ES_CXC,pc.*
	from sicav.BVQ_BACKOFFICE.PortafolioCorte pc
	join (select distinct htp_tpo_id,prog from sicav.bvq_backoffice.HISTORICO_TITULOS_PORTAFOLIO) htp on htp.htp_tpo_id=pc.httpo_id
	join BVQ_BACKOFFICE.ISSPOL_PROGS progs
	on htp.prog=progs.IPR_NOMBRE_PROG