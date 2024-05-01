create procedure bvq_backoffice.ObtenerNotasPorArchivo
	@i_archivo varchar(50), @i_fecha datetime, @i_lga_id int=null
as
begin
	select
	INC_ID,INC_DESCRIPCION,INC_ORDEN,INC_FECHA_DESDE,INC_FECHA_HASTA,INC_ARCHIVO
	from BVQ_BACKOFFICE.ISSPOL_NOTAS_CXC
	where
	@i_fecha BETWEEN ISNULL(INC_FECHA_DESDE, 0) AND ISNULL(INC_FECHA_HASTA, '9999-12-31T00:00:00')
	AND INC_ARCHIVO=@i_archivo
end
