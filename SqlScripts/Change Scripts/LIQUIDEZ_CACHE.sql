IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='UFO_USO_FONDOS'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD UFO_USO_FONDOS FLOAT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='UFO_RENDIMIENTO'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD UFO_RENDIMIENTO FLOAT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TPO_BOLETIN'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TPO_BOLETIN VARCHAR(60)

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TPO_FECHA_COMPRA_ANTERIOR'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TPO_FECHA_COMPRA_ANTERIOR DATETIME

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TPO_PRECIO_COMPRA_ANTERIOR'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TPO_PRECIO_COMPRA_ANTERIOR float

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TPO_FECHA_VENCIMIENTO_ANTERIOR'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TPO_FECHA_VENCIMIENTO_ANTERIOR DATETIME

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TPO_TABLA_AMORTIZACION'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TPO_TABLA_AMORTIZACION VARCHAR(8000)

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TFL_PERIODO'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TFL_PERIODO INT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='EVP_ABONO'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD EVP_ABONO BIT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='FON_ID'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD FON_ID INT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TIV_SUBTIPO'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TIV_SUBTIPO INT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='HTP_TIENE_VALNOM'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD HTP_TIENE_VALNOM BIT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='specialValnom'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD specialValnom float

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='TIV_TIPO_RENTA'
)
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD TIV_TIPO_RENTA INT

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='liq_rendimiento'
)
begin
	print 'liq_rendimiento'
	alter table BVQ_BACKOFFICE.LIQUIDEZ_CACHE ADD liq_rendimiento float
end
