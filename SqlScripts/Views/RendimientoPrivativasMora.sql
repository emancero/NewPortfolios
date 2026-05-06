create view	[BVQ_BACKOFFICE].[RendimientoPrivativasMora] as
	select saldoPorTasa/*,participacion,promedio*/,crc_segmento,plazo,saldo,crc_tasa,crc_fecha_cierre
	from BVQ_BACKOFFICE.RendimientoPorPlazoPrivativasMora