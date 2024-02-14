IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.EVENTO_PORTAFOLIO')
	and name='evp_valor_efectivo'
)
	alter table BVQ_BACKOFFICE.EVENTO_PORTAFOLIO ADD evp_valor_efectivo float

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.EVENTO_PORTAFOLIO')
	and name='evp_uso_fondos'
)
	alter table BVQ_BACKOFFICE.EVENTO_PORTAFOLIO ADD evp_uso_fondos float

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.EVENTO_PORTAFOLIO')
	and name='evp_rendimiento'
)
	alter table BVQ_BACKOFFICE.EVENTO_PORTAFOLIO ADD evp_rendimiento float
