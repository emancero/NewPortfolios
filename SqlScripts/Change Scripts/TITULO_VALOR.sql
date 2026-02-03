if not exists(
	select * from INFORMATION_SCHEMA.columns c where
	column_name like 'TIV_CODIGO_ISIN'--='tiv_codigo_isin'
	and table_name='titulo_valor'
	and table_schema='bvq_administracion'
)
	alter table BVQ_ADMINISTRACION.TITULO_VALOR ADD TIV_CODIGO_ISIN varchar(20)