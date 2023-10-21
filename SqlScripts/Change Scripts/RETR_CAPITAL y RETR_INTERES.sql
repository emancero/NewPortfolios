if not exists(
	select * from information_schema.columns where column_name='retr_capital' and table_name='retraso' and table_schema='bvq_backoffice'
)
	alter table BVQ_BACKOFFICE.RETRASO ADD RETR_CAPITAL BIT NOT NULL

if not exists(
	select * from information_schema.columns where column_name='retr_interes' and table_name='retraso' and table_schema='bvq_backoffice'
)
	alter table BVQ_BACKOFFICE.RETRASO ADD RETR_INTERES BIT NOT NULL

