IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.LIQUIDEZ_CACHE')
	and name='evp_valor_efectivo'
)
	alter table BVQ_BACKOFFICE.EVP_VALOR_EFECTIVO ADD evp_valor_efectivo float
