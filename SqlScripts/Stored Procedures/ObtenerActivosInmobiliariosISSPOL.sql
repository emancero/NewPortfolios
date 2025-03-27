create procedure BVQ_BACKOFFICE.InsertarAvaluoActivosInmobiliarios
	@i_imb_id int, @i_aai_fecha datetime, @i_aai_valor float, @i_lga_id int
as
begin
	insert into BVQ_BACKOFFICE.AVALUO_ACTIVOS_INMOBILIARIOS(
		IMB_ID, AAI_FECHA, AAI_VALOR
	) values (@i_imb_id, @i_aai_fecha, @i_aai_valor)

	EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
	@i_lga_id = @i_lga_id,
	@i_tabla = 'AVALUO_ACTIVOS_INMOBILIARIOS',
	@i_esquema = N'BVQ_BACKOFFICE',
	@i_operacion = N'I',
	@i_subTipo = N'N',
	@i_columIdName = 'AAI_ID',
	@i_idAfectado = @@IDENTITY;
end