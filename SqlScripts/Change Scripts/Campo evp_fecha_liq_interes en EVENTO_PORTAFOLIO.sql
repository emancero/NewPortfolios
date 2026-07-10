IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.EVENTO_PORTAFOLIO')
	and name='evp_fecha_liq_interes'
)
	alter table BVQ_BACKOFFICE.EVENTO_PORTAFOLIO ADD evp_fecha_liq_interes DATE NULL