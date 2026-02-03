create table bvq_administracion.CALIFICADORA_SB_MAP(
	 CSM_ID int primary key not null identity
	,CSM_CAL_ID int not null unique foreign key references bvq_administracion.tipo_valor(tvl_id)
	,CSM_CODIGO smallint not null
	,CSM_NOMBRE varchar(200) not null
)
insert into bvq_administracion.CALIFICADORA_SB_MAP(
	CSM_CAL_ID, CSM_CODIGO, CSM_NOMBRE
)
select CAL_ID, codigo, nombre
from bvq_administracion.CalificadoraSbMap csm
join bvq_administracion.calificadoras cal on rtrim(cal.cal_nombre)=csm.cal_nombre
