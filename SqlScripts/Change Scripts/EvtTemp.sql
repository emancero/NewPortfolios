IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='UFO_USO_FONDOS'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD UFO_USO_FONDOS FLOAT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='UFO_RENDIMIENTO'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD UFO_RENDIMIENTO FLOAT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TPO_BOLETIN'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TPO_BOLETIN VARCHAR(60)
