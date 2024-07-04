if not exists(
	select * from sicav.information_schema.columns where column_name='TPO_F1' and table_name='TITULOS_PORTAFOLIO' and table_schema='BVQ_BACKOFFICE'
)
	ALTER TABLE sicav.BVQ_BACKOFFICE.TITULOS_PORTAFOLIO ADD TPO_F1 int

if not exists(
	select * from sicav.information_schema.columns where column_name='TPO_AJUSTE_DIAS_DE_INTERES_GANADO' and table_name='TITULOS_PORTAFOLIO' and table_schema='BVQ_BACKOFFICE'
)
	ALTER TABLE BVQ_BACKOFFICE.TITULOS_PORTAFOLIO ADD TPO_AJUSTE_DIAS_DE_INTERES_GANADO float

if not exists(
	select * from sicav.information_schema.columns where column_name='TPO_FECHA_CORTE_OBLIGACION' and table_name='TITULOS_PORTAFOLIO' and table_schema='BVQ_BACKOFFICE'
)
	ALTER TABLE BVQ_BACKOFFICE.TITULOS_PORTAFOLIO ADD TPO_FECHA_CORTE_OBLIGACION datetime

if not exists(
	select * from sicav.information_schema.columns where column_name='TPO_FECHA_LIQUIDACION_OBLIGACION' and table_name='TITULOS_PORTAFOLIO' and table_schema='BVQ_BACKOFFICE'
)
	ALTER TABLE BVQ_BACKOFFICE.TITULOS_PORTAFOLIO ADD TPO_FECHA_LIQUIDACION_OBLIGACION datetime
