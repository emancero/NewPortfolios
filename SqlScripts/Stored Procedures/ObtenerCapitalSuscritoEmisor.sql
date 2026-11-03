CREATE procedure BVQ_ADMINISTRACION.ObtenerCapitalSuscritoEmisor
	@i_ems_id int,
	@i_lga_id INT = NULL
as
begin

	select CCA_ID, 
		EMI_ID, 
		CCA_SUSCRITO, 
		CCA_FECHA_ACTUALIZACION 
		from BVQ_ADMINISTRACION.COMPOSICION_CAPITAL 
		where EMI_ID = @i_ems_id

end
