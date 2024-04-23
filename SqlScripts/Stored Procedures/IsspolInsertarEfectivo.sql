CREATE procedure BVQ_BACKOFFICE.IsspolInsertarEfectivo @i_fecha datetime, @i_creacion_usuario varchar(20), @cola int, @o_id_efectivo int out, @o_msj varchar(200) out as
begin
	declare @log varchar(max)
	set @o_id_efectivo=(select id_efectivo from flujocaja.r_efectivo e where datediff(d,e.fecha,@i_fecha)=0)
	set @log='InsertarEfectivo oidefectivo0 '+rtrim(@o_id_efectivo)
	exec bvq_administracion.isspolenviolog @log

	if @o_id_efectivo is not null
		return 1
	/*else
	begin
		set @o_msj = 'MSJ-INFO: No existe el flujo de caja para el '+convert(varchar,@i_fecha,105)
		raiserror(@o_msj,16,0)
		return -1
	end*/

	insert into flujocaja.r_efectivo(
		fecha,usuario,total_banco,total_financiero,total_inversion,total_operativo,total_flujo,estado,creacion_usuario,creacion_fecha,creacion_equipo,modifica_usuario,modifica_fecha,modifica_equipo
	)
	select
	 fecha=@i_fecha--fc.fecha
	,usuario=@i_creacion_usuario
	,total_banco=0
	,total_financiero=0
	,total_inversion=0
	,total_operativo=0
	,total_flujo=0
	,estado=1
	,creacion_usuario=@i_creacion_usuario
	,creacion_fecha=getdate()
	,creacion_equipo='192.168.2.225'
	,modifica_usuario=@i_creacion_usuario
	,modifica_fecha=getdate()
	,modifica_equipo='192.168.2.225'
	--model.fecha,model.usuario,model.total_banco,model.total_financiero,model.total_inversion,model.total_operativo,model.total_flujo
	--,model.estado,model.creacion_usuario,model.creacion_fecha,model.creacion_equipo,model.modifica_usuario,model.modifica_fecha,model.modifica_equipo
	--from bvq_backoffice.IsspolFlujoCajaAInsertar fc

	--get identity, asigna null si no hay un registro con esa fecha, es decir si falló la inserción
	set @o_id_efectivo=(select id_efectivo from flujocaja.r_efectivo e where datediff(s,e.fecha,@i_fecha)=0)
	print 'oidefectivo '+rtrim(@o_id_efectivo)
	if @o_id_efectivo is null
	begin
		set @o_msj = 'MSJ-INFO: No se pudo insertar el flujo de caja para la fecha '+convert(varchar,@i_fecha,13)
		return -1
	end
	else
	begin
		exec bvq_administracion.EnviarMsj @cola,'InsertarEfectivo',@o_id_efectivo,2,'flujocaja.efectivo'
	end
	--select top 10 * from siisspolweb.siisspolweb.flujocaja.efectivo order by id_efectivo desc
	if not exists(select * from inversion.r_fondo_inversion)
		raiserror ('MSJ-ERROR: No existen registros en la tabla fondo_inversion o servidor remoto incorrecto',16,0)

	--saldos iniciales
	insert into flujocaja.r_caja(
		secuencial,id_efectivo,id_cuenta_banco,id_categoria_rubro,operacion,valor,valor_acumulado,acumula,referencia,creacion_usuario,creacion_fecha,creacion_equipo,modifica_usuario,modifica_fecha,modifica_equipo
	)
	select
		 secuencial=0--row_number() over (partition by e_id_efectivo,fi.id_cuenta order by ifi.montoInversion)
		,id_efectivo=@o_id_efectivo
		,id_cuenta_banco=fi.id_cuenta
		,id_categoria_rubro=120 --id_categoria_rubro:120 es id_rubro:64:'Saldo inicial'
		,operacion='+'
		,valor=0--sum(ifi.montoInversion)
		,valor_acumulado=null
		,acumula=0
		,referencia='Saldo inicial'
		,creacion_usuario=@i_creacion_usuario
		,creacion_fecha=getdate()
		,creacion_equipo='192.168.2.225'
		,modifica_usuario=@i_creacion_usuario
		,modifica_fecha=getdate()
		,modifica_equipo='192.168.2.225'
	from inversion.r_fondo_inversion fi
end
