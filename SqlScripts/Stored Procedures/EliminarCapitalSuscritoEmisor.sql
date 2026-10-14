CREATE procedure [BVQ_ADMINISTRACION].[EliminarCapitalSuscritoEmisor]
	@i_ccaId int,
	@i_lga_id int=null
as
begin
	DELETE FROM BVQ_ADMINISTRACION.COMPOSICION_CAPITAL
	WHERE
		CCA_ID = @i_ccaId

end