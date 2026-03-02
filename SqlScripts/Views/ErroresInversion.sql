alter view bvq_backoffice.erroresInversion as
	select errFonId, errProcedencia, errNumLiq, errNumLiqTmp, errValNom, errNumeracion
	from
	(VALUES
		(340,'Q','4213',NULL,5e6,'MDF-2014-07-17-2'),
		(340,'G',NULL,'12243',5e6,NULL)
	) AS errorInvs(errFonId, errProcedencia, errNumLiq, errNumLiqTmp, errValNom, errNumeracion)