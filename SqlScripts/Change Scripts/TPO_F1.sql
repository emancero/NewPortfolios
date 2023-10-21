if not exists(
	select * from sicav.information_schema.columns where column_name='TPO_F1' and table_name='TITULOS_PORTAFOLIO' and table_schema='BVQ_BACKOFFICE'
)
	ALTER TABLE sicav.BVQ_BACKOFFICE.TITULOS_PORTAFOLIO ADD TPO_F1 int
