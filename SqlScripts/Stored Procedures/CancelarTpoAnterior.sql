create procedure bvq_backoffice.CancelarTpoAnterior
	 @v_tpoId_org int
	,@i_fecha_ingreso datetime
as
begin
	if @v_tpoId_org is null return
	--declare @i_fecha_ingreso datetime=getdate()
	merge bvq_backoffice.retraso retr
	using 
	(
		select tpo.tpo_id,tfl_fecha_vencimiento
		from bvq_backoffice.defaults d
		join bvq_backoffice.titulos_portafolio tpo on d.tiv_id=tpo.tiv_id and d.por_id=tpo.por_id and tpo.tpo_id=@v_tpoId_org
		join BVQ_ADMINISTRACION.titulo_flujo_comun tfl on tfl.tiv_id=tpo.tiv_id and datediff(d,fecha,tfl_fecha_vencimiento)>=0
		where datediff(d,tpo_fecha_ingreso,fecha)>=0 and tfl_fecha_vencimiento<='99991231'
	) 	
	tfl(tpo_id,tfl_fecha_vencimiento)
	on (retr.retr_tpo_id=tfl.tpo_id and datediff(d,retr_fecha_esperada,tfl_fecha_vencimiento)=0)
	when matched then
		update set retr.retr_fecha_cobro=@i_fecha_ingreso
	when not matched then
		insert (retr_tpo_id,retr_fecha_esperada,retr_fecha_cobro,retr_capital,retr_interes)
		values(tfl.tpo_id,tfl.tfl_fecha_vencimiento,@i_fecha_ingreso,1,1)
	;
	
	update d set def_int_cobrado=null
	from bvq_backoffice.defaults d
	join bvq_backoffice.titulos_portafolio tpo on d.tiv_id=tpo.tiv_id and d.por_id=tpo.por_id and tpo.tpo_id=@v_tpoId_org
	--join BVQ_ADMINISTRACION.titulo_flujo_comun tfl on tfl.tiv_id=tpo.tiv_id and datediff(d,fecha,tfl_fecha_vencimiento)>=0
	where datediff(d,tpo_fecha_ingreso,fecha)>=0-- and tfl_fecha_vencimiento<='99991231'
end
