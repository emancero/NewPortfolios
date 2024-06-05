CREATE procedure [BVQ_BACKOFFICE].[ObtenerUltimoVencimientoPagado]
	@i_numeracion varchar(250), 
	@i_tiv_id int, 
	@i_fecha datetime, 
	@i_lga_id int
as
begin
	--borrar temporalmente el default que hace que un título vencido
	--aparezca en cuentas por cobrar
	update d set fecha='29991231'
	from bvq_backoffice.EventoPortafolioDefaults d
	where fecha=@i_fecha and tpo_numeracion=@i_numeracion

	if @@ROWCOUNT>0
	begin
		exec bvq_backoffice.prepararliquidezcache null
	end

	select * from bvq_backoffice.ObtenerDetallePortafolioConLiquidezView v
	where oper=1
	and fecha=@i_fecha
	and tpo_numeracion=@i_numeracion
end
