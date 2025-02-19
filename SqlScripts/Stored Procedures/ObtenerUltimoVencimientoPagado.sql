CREATE procedure [BVQ_BACKOFFICE].[ObtenerUltimoVencimientoPagado]
	@i_numeracion varchar(250), 
	@i_tiv_id int, 
	@i_fecha datetime, 
	@i_lga_id int
as
begin
	if exists(
		select * from bvq_backoffice.titulos_portafolio tpo
		join bvq_administracion.titulo_valor tiv on tpo.tiv_id=tiv.tiv_id
		where tiv_tipo_renta=154 and tpo_numeracion=@i_numeracion
	)
	begin
		select * from bvq_backoffice.ObtenerDetallePortafolioConLiquidezView v
		where --oper=0
		fecha=htp_fecha_operacion
		--and fecha=@i_fecha
		and tpo_numeracion=@i_numeracion
	return
	end

	--borrar temporalmente el default que hace que un título vencido
	--aparezca en cuentas por cobrar
	update d set fecha='29991231'
	from bvq_backoffice.EventoPortafolioDefaults d
	where datediff(hh,htp_fecha_operacion,@i_fecha)=0 and tpo_numeracion=@i_numeracion
	if @@ROWCOUNT>0
	begin
		exec bvq_backoffice.GenerarCompraVentaFlujo
		exec bvq_backoffice.prepararliquidezcache null
	end

	select * from bvq_backoffice.ObtenerDetallePortafolioConLiquidezView v
	where fecha_original=@i_fecha
	and tpo_numeracion=@i_numeracion
end
