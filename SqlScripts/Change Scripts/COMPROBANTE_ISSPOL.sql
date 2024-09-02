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

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.COMPROBANTE_ISSPOL')
	and name='FON_ID'
)
	alter table BVQ_BACKOFFICE.COMPROBANTE_ISSPOL ADD FON_ID INT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.COMPROBANTE_ISSPOL')
	and name='EVP_COSTAS_JUDICIALES_REFERENCIA'
)
	alter table BVQ_BACKOFFICE.COMPROBANTE_ISSPOL ADD EVP_COSTAS_JUDICIALES_REFERENCIA VARCHAR(200)
