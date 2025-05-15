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
		select distinct
		 v.htp_id
		,v.fecha_original
		,v.es_vencimiento_interes
		,v.amount
		,v.htp_tpo_id
		from bvq_backoffice.ObtenerDetallePortafolioConLiquidezView v
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


	;with a as(
		select htp_tpo_id,fecha_original,ipr_es_cxc,count(*) c
		from bvq_backoffice.ObtenerDetallePortafolioConLiquidezView v
		where TIV_TIPO_RENTA=153
		and oper=1 and isnull(evp_abono,0)=0
		group by htp_tpo_id,tpo_numeracion,fecha_original,ipr_es_cxc
	), b as(
		select r=row_number() over (partition by htp_tpo_id order by c, fecha_original desc),fecha_original,htp_tpo_id,c--fecha_original)
		from a --where isnull(ipr_es_cxc,0)=0
	), d as (
		select distinct htp_tpo_id,fecha_original,c from b
		where r=1
	)
	select distinct
		 v.htp_id
		,v.fecha_original
		,v.es_vencimiento_interes
		,v.amount
		,v.htp_tpo_id
	from bvq_backoffice.ObtenerDetallePortafolioConLiquidezView v
	join d on v.htp_tpo_id=d.htp_tpo_id
	where 1=1--fecha_original=@i_fecha
	and v.tpo_numeracion=@i_numeracion
end
