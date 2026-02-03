create view BVQ_ADMINISTRACION.TituloFlujoCapital as
	select --tfl_fecha_vencimiento=isnull(lag(tfl_fecha_vencimiento) over (partition by tfl.tiv_id order by tfl_fecha_vencimiento),tiv_fecha_emision),*
	tfl.TFL_ID,TFL.TIV_ID,TFL_CODIGO,TFL_PERIODO,TFL_CAPITAL
	,TFL_FECHA_INICIO
	=isnull(lag(tfl_fecha_vencimiento) over (partition by tfl.tiv_id order by tfl_fecha_vencimiento),tiv_fecha_emision)--,*
	,TFL_INTERES,TFL_AMORTIZACION,TFL_RECUPERACION
	,TFL_FECHA_VENCIMIENTO
	,TFL_VALOR_PRESENTE,TFL_FECHA_INICIO_VIGENCIA,TFL_FECHA_FIN_VIGENCIA,TFL_FECHA_REGISTRO,TFL_FECHA_ACTUALIZACION,dias_cupon_360
	from bvq_administracion.titulo_flujo tfl
	join bvq_administracion.titulo_valor tiv on tfl.tiv_id=tiv.tiv_id where tfl_amortizacion>0
