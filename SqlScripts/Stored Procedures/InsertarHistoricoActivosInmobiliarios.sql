CREATE PROCEDURE BVQ_BACKOFFICE.InsertarHistoricoActivosInmobiliarios
	@i_imb_id int, @i_hai_fecha date, @i_hai_valor float,@i_lga_id int=null
as
BEGIN
	insert into [BVQ_BACKOFFICE].[HISTORICO_ACTIVOS_INMOBILIARIOS](
	IMB_ID, HAI_FECHA, HAI_VALOR)
	values (@i_imb_id, @i_hai_fecha, @i_hai_valor)
END
