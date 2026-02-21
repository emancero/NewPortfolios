create view bvq_administracion.periodicidadSB as
	select frec,codigo,nombre from
	(values
		 (12,'ME','Mensual (30 DIAS)')
		,(6,'BM','Bimensual (60 DIAS)')
		,(4,'TR','Trimestral (90 DIAS)')
		,(3,'CT','Trimestral (120 DIAS)')
		,(2,'SE','Trimestral (180 DIAS)')
		,(1,'AN','Anual (360 DIAS)')
		,(null,'VC','Al vencimiento')
		,(null,'RV','Renta variable')
		,(null,'OT','Indefinido')
	) per(frec,codigo,nombre)
