CREATE TABLE bvq_administracion.TIPO_VALOR_SB(
	 TVS_ID int primary key not null identity
	,TVS_TVL_ID int unique not null foreign key references BVQ_ADMINISTRACION.TIPO_VALOR(TVL_ID)
	,TVS_CODIGO smallint not null
	,TVS_DESCRIPCION varchar(100) not null
)
insert into 
--select * from
bvq_administracion.tipo_valor_sb
(TVS_TVL_ID,TVS_CODIGO,TVS_DESCRIPCION)
select tvl_id,m.codigo,m.descr from BVQ_ADMINISTRACION.TipoValorSBMap m
join bvq_administracion.tipo_valor tvl on m.tvl_nombre = replace(tvl.tvl_nombre,char(160),'') collate modern_spanish_ci_ai
order by tvl_id

