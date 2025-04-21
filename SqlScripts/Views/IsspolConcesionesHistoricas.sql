CREATE view BVQ_BACKOFFICE.IsspolConcesionesHistoricas as
	with a as(
		SELECT
			monto = ISNULL(F4, 0)
			,fecha = (CASE
				WHEN ISNUMERIC(F2) = 1 AND
					F2 IS NOT NULL THEN CASE
						WHEN TRY_CAST(F2 AS INT) >= 2 THEN DATEADD(DAY, TRY_CAST(F2 AS INT) - 2, '19000101')
					END
			END)
			--,saldo = SUM(TRY_CAST(pc.F4 AS FLOAT)) OVER (PARTITION BY codigo ORDER BY pc.F1)
			,codigo
			,numero
			,producto
			,primerSaldo
			,pc.F1
		FROM (
			select F1,F2,F4,numero=F3,codigo='PQ',producto='QUIROGRAFARIO',primerSaldo=convert(datetime,'20100315') from PQ_CONCESION
			union all
			select F1,F2,F4,numero=F3,codigo='PH',producto='HIPOTECARIO',primerSaldo=convert(datetime,'20100122') from PH_CONSECION
		) pc
	) select monto,fecha
			,saldo = SUM(TRY_CAST(monto AS FLOAT)) OVER (PARTITION BY codigo ORDER BY F1)
	,codigo,numero,producto, f1 from a where fecha>=primerSaldo 
	--and codigo='pq'
