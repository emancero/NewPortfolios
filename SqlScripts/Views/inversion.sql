alter view bvq_backoffice.inversion as
		SELECT
			fon_procedencia_null = NULLIF(fixProcedencia, ''),
			fixNumeroLiquidacion,
			fixNumLiqTemp,
			fixNumeracion,
			errValnom,
			FON_ID,FON_NUMERACION,FON_TIV_ID,FON_ID_INT_INVERSION,FON_NUMERO_LIQUIDACION,FON_PROCEDENCIA,FON_NUMLIQ_TEMP,FON_ACCIONES_REALIZADAS,FON_NUMERO_RESOLUCION,FON_CVA_ID,FON_ID_INVERSION,FON_VECTOR_REPORTADO,FON_FECHA_RESOLUCION
		FROM bvq_backoffice.fondo AS f
		LEFT JOIN bvq_backoffice.erroresInversion AS errorInvs
			ON errorInvs.errFonId = f.fon_id          -- adjust if your PK is different
		CROSS APPLY (VALUES
			( COALESCE(errorInvs.errProcedencia, f.fon_procedencia),
			  COALESCE(errorInvs.errNumLiq,      f.FON_NUMERO_LIQUIDACION),
			  COALESCE(errorInvs.errNumLiqTmp,   f.FON_NUMLIQ_TEMP),
			  COALESCE(errorInvs.errNumeracion,   f.FON_NUMERACION)
			)
		) AS fixInvs(fixProcedencia, fixNumeroLiquidacion, fixNumLiqTemp)