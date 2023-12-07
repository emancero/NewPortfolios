IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TPO_FECHA_INGRESO'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TPO_FECHA_INGRESO DATETIME

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TPO_FECHA_INGRESO'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TPO_FECHA_INGRESO DATETIME

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TPO_RECURSOS'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TPO_RECURSOS VARCHAR(30)

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TPO_RECURSOS'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TPO_RECURSOS VARCHAR(30)

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TIV_SERIE'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TIV_SERIE VARCHAR(100)

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TIV_SERIE'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TIV_SERIE VARCHAR(100)

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TIV_NUMERO_EMISION_SEB'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TIV_NUMERO_EMISION_SEB NCHAR(6)

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TIV_NUMERO_EMISION_SEB'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TIV_NUMERO_EMISION_SEB NCHAR(6)



IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TIV_FRECUENCIA'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TIV_FRECUENCIA float

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TIV_FRECUENCIA'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TIV_FRECUENCIA float
go

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='IPR_ES_CXC'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD IPR_ES_CXC bit

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='IPR_ES_CXC'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD IPR_ES_CXC bit
go

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='fecha_original'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD fecha_original DATETIME
go
