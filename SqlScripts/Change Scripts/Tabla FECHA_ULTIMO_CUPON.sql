create table BVQ_BACKOFFICE.FECHA_ULTIMO_CUPON(
	  FCUP_ID int primary key not null identity
	, FCUP_TPO_ID int foreign key references BVQ_BACKOFFICE.TITULOS_PORTAFOLIO(TPO_ID)
	, FCUP_FECHA_ORIGINAL date
	, FCUP_DESDE date
)
