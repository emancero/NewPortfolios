if not exists(
	select * from information_schema.columns
	where column_name='FON_CVA_ID' and table_name='FONDO' and table_schema='BVQ_BACKOFFICE'
)
BEGIN
	ALTER TABLE BVQ_BACKOFFICE.fondo
	ADD FON_CVA_ID INT NULL;


	ALTER TABLE BVQ_BACKOFFICE.fondo
	ADD CONSTRAINT FK_fondo_casa_valores
	FOREIGN KEY (FON_CVA_ID)
	REFERENCES bvq_administracion.casa_valores (cva_id);
END