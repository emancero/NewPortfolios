IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.COMPROBANTE_ISSPOL')
	and name='TFL_PERIODO'
)
	alter table BVQ_BACKOFFICE.COMPROBANTE_ISSPOL ADD TFL_PERIODO INT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.COMPROBANTE_ISSPOL')
	and name='HTP_FECHA_OPERACION'
)
	alter table BVQ_BACKOFFICE.COMPROBANTE_ISSPOL ADD HTP_FECHA_OPERACION DATETIME

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.COMPROBANTE_ISSPOL')
	and name='deterioro'
)
	alter table BVQ_BACKOFFICE.COMPROBANTE_ISSPOL ADD deterioro BIT
