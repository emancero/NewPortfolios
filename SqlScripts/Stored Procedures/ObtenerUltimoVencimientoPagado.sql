CREATE procedure [BVQ_BACKOFFICE].[ObtenerUltimoVencimientoPagado]
	@i_numeracion varchar(250), 
	@i_tiv_id int, 
	@i_fecha datetime, 
	@i_fecha_gen datetime,
	@i_lga_id int
as
begin
	if exists(
		select * from bvq_backoffice.titulos_portafolio tpo
		join bvq_administracion.titulo_valor tiv on tpo.tiv_id=tiv.tiv_id
		where tiv_tipo_renta=154 and tpo_numeracion=@i_numeracion
	)
	begin
		select --distinct
		 v.htp_id
		,v.fecha_original
		,v.es_vencimiento_interes
		,v.amount
		,v.htp_tpo_id
		from (
			select r=row_number() over (partition by htp_tpo_id,convert(date,fecha_original),es_vencimiento_interes order by amount),*
			from bvq_backoffice.ObtenerDetallePortafolioConLiquidezView
		) v
		where r=1 and--oper=0
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
	--EMN: 5-jun-2026 se cambió htp_fecha_operacion->fecha pues cuando hay default
	--no hay una fecha de operación con la fecha de vencimiento
	update d set fecha='29991231'
	from bvq_backoffice.titulos_portafolio tpo
	join bvq_backoffice.retraso retr on retr_tpo_id=tpo.tpo_id
		and retr_fecha_cobro='29991231'
		and retr_capital=1
		and datediff(hh,retr_fecha_esperada,@i_fecha)=0
	join bvq_backoffice.defaults d on d.tiv_id=tpo.tiv_id and d.por_id=tpo.por_id
	where tpo_numeracion=@i_numeracion
	if @@ROWCOUNT>0
	begin
		exec bvq_backoffice.GenerarCompraVentaFlujo
		exec bvq_backoffice.prepararliquidezcache null
	end
 
 
	declare @anyTpoId int=(select top 1 tpo_id from bvq_backoffice.titulos_portafolio where tpo_numeracion=@i_numeracion)
	declare @v_fechaOriginal datetime
	;with a as(
		select htp_tpo_id,tpo_numeracion,fecha_original,ipr_es_cxc,oper,count(*) c
		from bvq_backoffice.ObtenerDetallePortafolioConLiquidezView v
		where TIV_TIPO_RENTA=153
		--and oper=1 
		and isnull(evp_abono,0)=0
		group by htp_tpo_id,tpo_numeracion,fecha_original,ipr_es_cxc,oper
	), b as(
		select r=row_number() over (partition by htp_tpo_id order by c desc, fecha_original desc, oper desc),fecha_original,htp_tpo_id,tpo_numeracion,c--fecha_original)
		from a --where isnull(ipr_es_cxc,0)=0
	)
	select @v_fechaOriginal=fecha_original from b where r=1
	and htp_tpo_id=@anyTpoId
 
	select distinct
		 htp_id=case when v.oper=0 and tiv_tipo_renta=153 then (
			--select top 1 htp_id from bvq_backoffice.liquidez_cache where htp_tpo_id=v.htp_tpo_id and oper=1)
		 --else (
			select top 1 htp_id from bvq_backoffice.liquidez_cache where htp_tpo_id=v.htp_tpo_id and oper=1
			and fecha<'99991231'
			order by fecha desc)
			--v.htp_id
		 end
		,v.fecha_original
		,v.es_vencimiento_interes
		,v.amount
		,v.htp_tpo_id
	from bvq_backoffice.ObtenerDetallePortafolioConLiquidezView v
	where --v.htp_tpo_id=@anyTpoId
	v.tpo_numeracion = @i_numeracion
	and fecha_original=@v_fechaOriginal
	and isnull(evp_abono,0)=0
end
 