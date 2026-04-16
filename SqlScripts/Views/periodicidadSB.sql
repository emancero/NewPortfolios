CREATE view [BVQ_ADMINISTRACION].[periodicidadSB] as
	select frec,codigo,nombre,textoCondicion from
	(values
		 (12,'ME','Mensual (30 DIAS)','mensuales')
		,(6,'BM','Bimensual (60 DIAS)','bimensuales')
		,(4,'TR','Trimestral (90 DIAS)','trimestrales')
		,(3,'CT','Trimestral (120 DIAS)','cuatrimestrales')
		,(2,'SE','Trimestral (180 DIAS)','semianuales')
		,(1,'AN','Anual (360 DIAS)','anuales')
		,(null,'VC','Capital y rendimiento al vencimiento',NULL)
		,(null,'RV','Renta variable',NULL)
		,(null,'OT','Indefinido',NULL)
	) per(frec,codigo,nombre,textoCondicion)

