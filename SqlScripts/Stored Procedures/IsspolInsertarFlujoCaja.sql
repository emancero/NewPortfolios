CREATE procedure BVQ_BACKOFFICE.IsspolInsertarFlujoCaja @i_numeracion varchar(200), @i_fecha datetime, @i_creacion_usuario varchar(20), @i_cola_id int, @i_lga_id int  as
begin
	exec BVQ_BACKOFFICE.IsspolInsertarCaja @i_numeracion, @i_fecha, @i_creacion_usuario

	--log
	insert into BVQ_BACKOFFICE.ISSPOL_LOG_FLUJO_EFECTIVO(
		ILFE_ID_EFECTIVO,
		ILFE_FECHA,
		ILFE_TOTAL_INVERSION,
		ILFE_TOTAL_FLUJO,
		ILFE_TOTAL_FINANCIERO,
		ILFE_TOTAL_BANCO,
		ILFE_COLA_ID
	)
	select id_efectivo,getdate(),total_inversion,total_flujo,total_financiero,total_banco,@i_cola_id
	from flujocaja.r_efectivo e
	where datediff(d,e.fecha,@i_fecha)=0

	--actualiza los totales en la tabla efectivo
	update e set 
	 total_inversion=-total
	,total_flujo=-total
	,total_financiero=total
	,total_banco=total
	from
	flujocaja.efectivo e
	join (
		select e.id_efectivo,total=sum(valor)
		from flujocaja.r_efectivo e--bvq_backoffice.FlujoCajaManualAActualizar e
		join flujocaja.r_caja c on c.id_efectivo=e.id_efectivo
		where referencia<>'Saldo inicial'
		group by e.id_efectivo
	) s on e.id_efectivo=s.id_efectivo
	and datediff(d,e.fecha,@i_fecha)=0
	
	--log
	insert into BVQ_BACKOFFICE.ISSPOL_LOG_FLUJO_CAJA(
		ILFC_ID_EFECTIVO,
		ILFC_ID_CAJA,
		ILFC_FECHA,
		ILFC_VALOR,
		ILFC_USUARIO,
		ILFC_OPERACION,
		ILFC_REFERENCIA,
		ILFC_COLA_ID
	)
	select
	 c.id_efectivo
	,id_caja
	,c.creacion_fecha
	,c.valor
	,c.creacion_usuario
	,c.operacion
	,c.referencia
	,@i_cola_id
	from flujocaja.r_efectivo a
	join flujocaja.r_caja c
	on c.referencia='Saldo inicial' --solo actualiza los saldos iniciales
	and c.id_efectivo=a.id_efectivo-- and c.id_cuenta_banco=a.id_cuenta_banco
	where datediff(d,a.fecha,@i_fecha)=0
	

	--actualiza los totales en los registros iniciales de la tabla de caja
	update s set
	--select a.id_efectivo,a.id_cuenta_banco,
	valor=totalInicial
	from(
		select c.valor,totalInicial=sum(valor) over (partition by e.id_efectivo,c.id_cuenta_banco)
		from flujocaja.r_efectivo e
		join flujocaja.r_caja c
		on c.referencia='Saldo inicial' --solo actualiza los saldos iniciales
		and c.id_efectivo=e.id_efectivo-- and c.id_cuenta_banco=e.id_cuenta_banco
		where datediff(d,e.fecha,@i_fecha)=0
	) s
end
