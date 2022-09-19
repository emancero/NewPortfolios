-- Columnnas importantes
IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'TIV_FECHA_VENCIMIENTO'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD TIV_FECHA_VENCIMIENTO datetime

IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'TIV_TIPO_VALOR'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD TIV_TIPO_VALOR int

IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'TIV_SUBTIPO'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD TIV_SUBTIPO int

IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'HTP_PRECIO_COMPRA'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD HTP_PRECIO_COMPRA float

IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'HTP_COMPRA'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD HTP_COMPRA float
	
IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'cupoper_tfl_fecha_inicio'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD cupoper_tfl_fecha_inicio datetime


-- Columnas menos importantes (se pueden calcular luego)
IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'liq_rendimiento'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD liq_rendimiento float

IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'liq_total_interes'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD liq_total_interes float

IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'liq_interes_total'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD liq_interes_total float

IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'liq_comision_bolsa'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD liq_comision_bolsa float
	
IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'liq_comision_casa'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD liq_comision_casa float

IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'liq_id'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD liq_id int

IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'liq_market'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD liq_market varchar(50)

IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'liq_numero_bolsa'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD liq_numero_bolsa varchar(50)

IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'TPO_TIPO_VALORACION'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD TPO_TIPO_VALORACION bit


-- Columnas que estaban antes en vista CompraVentaFlujo
IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'vencimiento'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD vencimiento datetime
	
IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'amortizacion'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD amortizacion float

IF NOT EXISTS(select * from sys.columns where object_id=object_id('BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO') and name=
	'iamortizacion'
)
	alter table BVQ_BACKOFFICE.COMPRA_VENTA_FLUJO ADD iamortizacion float
