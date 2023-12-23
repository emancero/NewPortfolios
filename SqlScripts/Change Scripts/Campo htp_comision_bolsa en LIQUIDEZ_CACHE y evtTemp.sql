IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO')
	and name='htp_comision_bolsa'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD htp_comision_bolsa float

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='htp_comision_bolsa'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD htp_comision_bolsa float

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='htp_comision_bolsa'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD htp_comision_bolsa float
