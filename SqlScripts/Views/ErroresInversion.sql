alter view bvq_backoffice.erroresInversion as
	select errFonId, errProcedencia, errNumLiq, errNumLiqTmp, errValNom
	from
	(VALUES
		(340,'Q','4213',NULL,5e6),
		(340,'G',NULL,'12243',5e6)
	) AS errorInvs(errFonId, errProcedencia, errNumLiq, errNumLiqTmp, errValNom)