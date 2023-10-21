IF NOT EXISTS(
	select * from sys.columns
	where object_id=object_id('BVQ_BACKOFFICE.evtTemp')
	and name='compra_htp_id'
)
	alter table BVQ_BACKOFFICE.evtTemp ADD compra_htp_id int