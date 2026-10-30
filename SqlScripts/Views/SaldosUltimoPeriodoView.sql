create VIEW [BVQ_BACKOFFICE].[SaldosUltimoPeriodoView]
AS
--Saldos del ultimo periodo cerrado (ver SaldosPeriodosCerradosView)
SELECT
	id_cuenta,
	cuenta_formato,
	cuenta_descripcion,
	saldo,
	mes,
	esactual,
	estado_siisspol,
	periodo_siisspol,
	ejercicio_siisspol,
	PERIODO_ID,
	periodo_sicav,
	EJERCICIO_ANIO,
	estado_sicav,
	estado_sicav_desc
FROM BVQ_BACKOFFICE.SaldosPeriodosCerradosView
WHERE orden = 1
