create PROCEDURE BVQ_BACKOFFICE.InsertarHistoricoActivosInmobiliarios
	@i_imb_id int, @i_hai_fecha date, @i_hai_valor float, @i_lga_id int=null
as
BEGIN
	insert into [BVQ_BACKOFFICE].[HISTORICO_ACTIVOS_INMOBILIARIOS](
	IMB_ID, HAI_FECHA, HAI_VALOR)--, HAI_FECHA_AVALUO, HAI_VALOR_AVALUO)
	values (@i_imb_id, @i_hai_fecha, @i_hai_valor)--, @i_hai_fecha_avaluo, @i_hai_valor_avaluo)

	EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
	@i_lga_id = @i_lga_id,
	@i_tabla = 'HISTORICO_ACTIVOS_INMOBILIARIOS',
	@i_esquema = N'BVQ_BACKOFFICE',
	@i_operacion = N'I',
	@i_subTipo = N'N',
	@i_columIdName = 'HAI_ID',
	@i_idAfectado = @@IDENTITY;

END