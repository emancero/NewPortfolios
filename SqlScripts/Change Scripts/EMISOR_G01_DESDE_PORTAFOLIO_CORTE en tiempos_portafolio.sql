if not exists(
	select *
	from bvq_backoffice.tiempos_portafolio
	where tpor_codigo='EMISOR_G01_DESDE_PORTAFOLIO_CORTE'
)
	insert into bvq_backoffice.tiempos_portafolio values
	('EMISOR_G01_DESDE_PORTAFOLIO_CORTE','Obtiene los emisores de portafoliocorte y no desde isspolrentafijaview','20250801')
	