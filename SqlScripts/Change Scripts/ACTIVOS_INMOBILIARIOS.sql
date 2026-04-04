if not exists(
	select * from information_schema.columns where column_name='IMB_CUENTA_CONTABLE' and table_name='ACTIVOS_INMOBILIARIOS'
)
	alter table BVQ_BACKOFFICE.ACTIVOS_INMOBILIARIOS add IMB_CUENTA_CONTABLE varchar(100)
if not exists(
	select * from information_schema.columns where column_name='IMB_FORMA_ADQUISICION' and table_name='ACTIVOS_INMOBILIARIOS'
)
	alter table BVQ_BACKOFFICE.ACTIVOS_INMOBILIARIOS add IMB_FORMA_ADQUISICION varchar(1500)
