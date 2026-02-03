create view bvq_administracion.CalificadoraSbMap as
	select codigo,nombre,cal_nombre
	from(
	VALUES
	(0,'No Disponible',NULL),
	(1,'Standard & Poor''s (S & P)',NULL),
	(2,'Moody''s',NULL),
	(3,'Fitch',NULL),
	(4,'Bank Watch Ratings','BANKWATCH RATINGS'),
	(5,'Ecuability','ECUABILITY'),
	(6,'Humphreys',NULL),
	(7,'PCR Pacific','PACIFIC CREDIT RATING'),
	(8,'Otras',NULL),
	(9,'Soc. Cal. Riesgo Latinoamericana SCR LA','SCR CALIFICADORA DE RIESGOS'),
	(10,'Class International Rating','CLASS INTERNATIONAL'),
	(11,'Microfinanza Rating','MICROFINANZA CALIFICADORA DE RIESGOS S.A. MICRORIESG'),
	(12,'SummaRating S.A.','SUMMARATINGS S.A.'),
	(13,'GlobalRatings','GLOBALRATINGS CALIFICADORA DE RIESGOS S.A.'),
	(14,'UnionRatings','UNIONRATINGS CALIFICADORA DE RIESGOS S.A.')
	)
	v(codigo,nombre,cal_nombre)