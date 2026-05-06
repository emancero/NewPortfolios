create view	[BVQ_BACKOFFICE].[RendimientoPorPlazoPrivativasMora] as
	with a as(
		select saldo=crc_saldo_prestamo,plazo=datediff(d,crc_fecha_otorgamiento,crc_fecha_vencimiento),crc_tasa,crc_fecha_cierre,crc_segmento
		from bvq_backoffice.creditos_cartera
		where CRC_ESTADO = 'Mora'
	), b as(
		select saldo=sum(saldo),saldoPorTasa=sum(sum(saldo)) over (partition by crc_fecha_cierre,crc_segmento,crc_tasa),crc_segmento,plazo,crc_tasa,crc_fecha_cierre
		from a
		group by crc_fecha_cierre,crc_segmento,crc_tasa,plazo
	)
	select saldoPorTasa
	,participacion=saldo/saldoPorTasa
	,promedio=saldo/saldoPorTasa*plazo
	,crc_segmento,plazo,saldo,crc_tasa,crc_fecha_cierre
	,peso=saldoPorTasa/saldo
	,PxRPP=crc_tasa * saldoPorTasa/saldo
	from b