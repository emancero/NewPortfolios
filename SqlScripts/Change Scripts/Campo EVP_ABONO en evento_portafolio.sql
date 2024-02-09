IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.EVENTO_PORTAFOLIO')
	and name='EVP_ABONO'
)
	alter table BVQ_BACKOFFICE.EVENTO_PORTAFOLIO ADD EVP_ABONO bit