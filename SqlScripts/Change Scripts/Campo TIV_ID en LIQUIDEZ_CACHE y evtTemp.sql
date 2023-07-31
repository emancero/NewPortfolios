-- Campo TIV_ID en BVQ_BACKOFFICE.LIQUIDEZ_CACHE
IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TIV_ID'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TIV_ID INT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TIV_ID'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TIV_ID INT
