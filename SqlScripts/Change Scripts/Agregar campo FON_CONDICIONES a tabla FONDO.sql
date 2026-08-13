if not exists(
	select * from INFORMATION_SCHEMA.columns where column_name='FON_CONDICIONES'
)
	alter table BVQ_BACKOFFICE.FONDO ADD FON_CONDICIONES varchar(max)