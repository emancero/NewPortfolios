CREATE procedure BVQ_BACKOFFICE.IsspolInsertarCaja @i_numeracion varchar(200), @i_fecha datetime,@i_creacion_usuario varchar(20),@i_lga_id int = null  as
begin
	declare @log varchar(max)

	declare @maxSeq int=0
	select @maxSeq=isnull(max(secuencial),0) from flujocaja.r_efectivo e
	join flujocaja.r_caja c on e.id_efectivo=c.id_efectivo
	where datediff(d,e.fecha,@i_fecha)=0
	set @log=formatmessage('maxseq: %d ',@maxSeq)+convert(varchar,@i_fecha,13)
	exec bvq_administracion.isspolenviolog @log


	if not exists(select * from inversion.r_fondo_inversion)
		raiserror ('MSJ-ERROR: No existen registros en la tabla fondo_inversion o servidor remoto incorrecto',16,0)


	insert into flujocaja.r_caja(
		secuencial,id_efectivo,id_cuenta_banco,id_categoria_rubro,operacion,valor,valor_acumulado,acumula,referencia,creacion_usuario,creacion_fecha,creacion_equipo,modifica_usuario,modifica_fecha,modifica_equipo
	)
	select
		 secuencial=@maxSeq+1--row_number() over (partition by e_id_efectivo,fi.id_cuenta order by ifi.montoInversion)
		,id_efectivo=e_id_efectivo
		,id_cuenta_banco=fi.id_cuenta
		,id_categoria_rubro=99
		,operacion='-'
		,valor=round(sum(ifi.montoInversion),2)
		,valor_acumulado=null
		,acumula=0
		,referencia='Inversiones '+convert(varchar,fc.fecha,105)
		,creacion_usuario=@i_creacion_usuario
		,creacion_fecha=fc.creacion_fecha
		,creacion_equipo='192.168.2.225'
		,modifica_usuario=@i_creacion_usuario
		,modifica_fecha=fc.creacion_fecha
		,modifica_equipo='192.168.2.225'
		--,ifi.id_int_inversion,ifi.id_int_inversion_fondo
	--select *
	from inversion.r_int_inversion fc
	left join (select e_id_efectivo=id_efectivo,e_fecha=fecha from flujocaja.r_efectivo) e on datediff(d,e.e_fecha,fc.fecha)=0
	join inversion.r_int_inversion_fondo_inversion ifi on fc.id_int_inversion=ifi.id_int_inversion
	join inversion.fondo_inversion fi on ifi.id_seguro_tipo=fi.id_seguro_tipo
	where fc.nombre=@i_numeracion
	group by fc.fecha,fi.id_cuenta,e.e_id_efectivo,fc.creacion_fecha
	having datediff(s,fc.fecha,@i_fecha)=0
end
