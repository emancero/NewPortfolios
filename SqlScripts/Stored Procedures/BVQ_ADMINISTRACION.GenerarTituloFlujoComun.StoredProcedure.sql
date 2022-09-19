create procedure bvq_administracion.GenerarTituloFlujoComun as
/*
begin

	delete from bvq_administracion.titulo_flujo_comun
	insert into bvq_administracion.titulo_flujo_comun
	select
	TFL_ID,
	tfl.TIV_ID,
	TFL_CODIGO,
	TFL_PERIODO,
	TFL_CAPITAL,
	TFL_FECHA_INICIO,
	TFL_INTERES,
	TFL_AMORTIZACION,
	TFL_RECUPERACION,
	TFL_FECHA_VENCIMIENTO,
	TFL_VALOR_PRESENTE,

	TFL_FECHA_INICIO_VIGENCIA,
	TFL_FECHA_FIN_VIGENCIA,
	TFL_FECHA_REGISTRO,
	TFL_FECHA_ACTUALIZACION
	from bvq_administracion.titulo_flujo tfl
	where tfl_fecha_inicio_vigencia is null
	and
	(select top 1 ifprt_fecha from bvq_administracion.inicio_flujo_portafolio)
	<=tfl_fecha_vencimiento
	
	union all

	select
	max_tfl_id+row_number() over (order by tiv_id),
	tiv_id,	
	tiv_codigo,
	tfl_periodo=null,
	tfl_capital=0e,
	tfl_fecha_inicio=isnull(tiv_fecha_vencimiento,0),
	tfl_interes=null,
	tfl_amortizacion=0e,
	tfl_recuperacion=null,
	tfl_fecha_vencimiento='9999-12-31T23:59:59',
	tfl_valor_presente=null,
	tfl_fecha_inicio_vigencia=null,
	tfl_fecha_fin_vigencia=null,
	tfl_fecha_registro=null,
	tfl_fecha_actualizacion=null
	from bvq_administracion.titulo_valor tiv,(select max(tfl_id) max_tfl_id from bvq_administracion.titulo_flujo) f
end
*/