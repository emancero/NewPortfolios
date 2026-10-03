if not exists(
	select * from bvq_administracion.parametro par where par_codigo like 'calc_struct'
)
	insert into bvq_administracion.parametro(par_nombre,par_codigo,par_tipo_dato,par_descripcion,par_fecha,par_deusuario)
	values('Calcula la estructura SBS, no la trae de caché','CALC_STRUCT',11,'SI',21,'Calcula la estructura SBS, no la trae de caché',getdate(),1)
