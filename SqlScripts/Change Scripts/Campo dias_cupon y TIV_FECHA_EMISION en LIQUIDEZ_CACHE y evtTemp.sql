-- Campo TIV_ID en BVQ_BACKOFFICE.LIQUIDEZ_CACHE
IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='dias_cupon'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD dias_cupon INT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='dias_cupon'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD dias_cupon INT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TIV_FECHA_EMISION'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TIV_FECHA_EMISION DATETIME

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TIV_FECHA_EMISION'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TIV_FECHA_EMISION DATETIME

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TFL_FECHA_INICIO'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TFL_FECHA_INICIO DATETIME

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TFL_FECHA_INICIO'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TFL_FECHA_INICIO DATETIME

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TFL_FECHA_INICIO_ORIG'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TFL_FECHA_INICIO_ORIG DATETIME

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TFL_FECHA_INICIO_ORIG'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TFL_FECHA_INICIO_ORIG DATETIME
