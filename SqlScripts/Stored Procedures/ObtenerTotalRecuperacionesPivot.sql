CREATE procedure BVQ_BACKOFFICE.ObtenerTotalRecuperacionesPivot
	 @i_fecha_ini datetime
	,@i_fecha_fin datetime
	,@i_lga_id int
as
begin
	select * from BVQ_BACKOFFICE.TotalRecuperacionesView t
	where fecha between @i_fecha_ini and @i_fecha_fin
end