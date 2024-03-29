﻿IF NOT EXISTS(
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

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TPO_FECHA_COMPRA_ANTERIOR'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TPO_FECHA_COMPRA_ANTERIOR DATETIME

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TPO_PRECIO_COMPRA_ANTERIOR'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TPO_PRECIO_COMPRA_ANTERIOR float

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TPO_FECHA_VENCIMIENTO_ANTERIOR'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TPO_FECHA_VENCIMIENTO_ANTERIOR DATETIME

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TPO_TABLA_AMORTIZACION'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TPO_TABLA_AMORTIZACION VARCHAR(8000)

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='originalProvision'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD originalProvision float

IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='TFL_PERIODO'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD TFL_PERIODO int

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'evp_abono'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.evtTemp')
)
BEGIN
    alter table BVQ_BACKOFFICE.evtTemp
   add evp_abono bit
END 
