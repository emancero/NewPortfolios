CREATE VIEW [BVQ_BACKOFFICE].[DetalleRecuperacionesIsspol]
AS
	select
		tipo_renta,
		MAX(sector) AS sector,
		tvl_nombre,
		max(fecha_compra) as fecha_compra,
		max(fecha_vencimiento) as fecha_vencimiento,
		max(nombre) as nombre,
		saldo_valor_nominal=sum(saldo_valor_nominal),
		rendimiento=null,
		plazo_cupon=max(plazo_cupon),
		capital=sum(capital),
		iamortizacion = sum(iAmortizacion),
		pago_total=sum(pago_total),
		fecha_pago,
		fecha_de_vencimiento_flujo=max(fecha_de_vencimiento_flujo),
		acciones_judiciales=null,
		max(primer_nivel) as primer_nivel,
		max(tipo_flujo) as tipo_flujo,
		EMS_NOMBRE, tpo_numeracion,oper,fecha=fecha_pago,tiv_id--,htp_fecha_operacion
	from bvq_backoffice.DetalleRecuperacionesIsspolFondos
	group by tipo_renta,tvl_nombre, EMS_NOMBRE, tpo_numeracion,oper,fecha_pago,tiv_id--,htp_fecha_operacion