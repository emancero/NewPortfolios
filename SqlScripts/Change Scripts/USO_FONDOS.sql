create table BVQ_BACKOFFICE.USO_FONDOS(
	UFO_ID int primary key not null identity,
	TFL_ID int not null
		foreign key references bvq_administracion.titulo_flujo(tfl_id),
	UFO_USO_FONDOS float not null,
	UFO_RENDIMIENTO float not null,
	TPO_NUMERACION varchar(200)
)
