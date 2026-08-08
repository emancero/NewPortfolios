create view	BVQ_BACKOFFICE.ReporteRendimientoPrivativas as
	select ppp=sum(saldo/saldoPorTasa*plazo),crc_segmento,saldo=sum(saldo),rpp=crc_tasa/100.0,crc_fecha_cierre
	from BVQ_BACKOFFICE.RendimientoPrivativas
	group by crc_segmento,crc_tasa,crc_fecha_cierre