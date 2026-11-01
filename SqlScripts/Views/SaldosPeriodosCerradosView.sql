create VIEW [BVQ_BACKOFFICE].[SaldosPeriodosCerradosView]
AS
WITH cerrados AS (
	--Periodos cerrados en Sicav (meses 1-12; "Cierre" no tiene par en SIISSPOL)
	--orden = 1 es el ultimo periodo cerrado
	SELECT
		anio  = CAST(ec.EJERCICIO_ANIO AS int),
		mes   = TRY_CAST(m.ITC_VALOR AS int),
		orden = ROW_NUMBER() OVER (ORDER BY CAST(ec.EJERCICIO_ANIO AS int) DESC, TRY_CAST(m.ITC_VALOR AS int) DESC)
	FROM BVQ_BACKOFFICE.PERIODO_CONTABLE pc
		INNER JOIN BVQ_BACKOFFICE.EJERCICIO_CONTABLE ec
			ON ec.EJERCICIO_ID = pc.EJERCICIO_ID
		INNER JOIN BVQ_ADMINISTRACION.CatalogoItemCatalogo m
			ON  m.ITC_ID     = pc.PERIODO_MES
			AND m.cat_codigo = 'MES'
		INNER JOIN BVQ_ADMINISTRACION.CatalogoItemCatalogo est
			ON  est.ITC_ID     = pc.PERIODO_ESTADO
			AND est.cat_codigo = 'BCK_ES_PERIODO_CONT'
	WHERE est.ITC_CODIGO = 'C'
	  AND TRY_CAST(m.ITC_VALOR AS int) BETWEEN 1 AND 12
)
SELECT
	cta.id_cuenta,
	cta.cuenta_formato,
	cta.descripcion AS cuenta_descripcion,
	sal.saldo,
	per.mes,
	per.esactual,
	per.estado AS estado_siisspol, -- A/C/G
	per.descripcion AS periodo_siisspol,
	eje.descripcion AS ejercicio_siisspol,
	pc.PERIODO_ID,
	pc.PERIODO_MES_CODIGO AS periodo_sicav,
	ec.EJERCICIO_ANIO,
	est.ITC_CODIGO AS estado_sicav, -- A/C
	est.ITC_DESCRIPCION AS estado_sicav_desc,
	c.orden
FROM
	siisspolweb.siisspolweb.contabilidad.cuenta cta
	INNER JOIN siisspolweb.siisspolweb.contabilidad.saldo sal
		ON sal.id_cuenta = cta.id_cuenta
	INNER JOIN siisspolweb.siisspolweb.contabilidad.periodo per
		ON sal.id_periodo = per.id_periodo
	INNER JOIN siisspolweb.siisspolweb.contabilidad.ejercicio eje
		ON eje.id_ejercicio = per.id_ejercicio
	INNER JOIN cerrados c
		ON  per.mes = c.mes
		AND per.fecha_desde >= DATEFROMPARTS(c.anio, 1, 1)
		AND per.fecha_desde <  DATEFROMPARTS(c.anio + 1, 1, 1)
	LEFT JOIN BVQ_BACKOFFICE.EJERCICIO_CONTABLE ec
		ON ec.EJERCICIO_ANIO = CAST(YEAR(per.fecha_desde) AS varchar(4))
	LEFT JOIN BVQ_ADMINISTRACION.CatalogoItemCatalogo m
		ON  m.cat_codigo = 'MES'
		AND TRY_CAST(m.ITC_VALOR AS int) = per.mes
	LEFT JOIN BVQ_BACKOFFICE.PERIODO_CONTABLE pc
		ON  pc.EJERCICIO_ID = ec.EJERCICIO_ID
		AND pc.PERIODO_MES  = m.ITC_ID
	LEFT JOIN BVQ_ADMINISTRACION.CatalogoItemCatalogo est
		ON  est.ITC_ID     = pc.PERIODO_ESTADO
		AND est.cat_codigo = 'BCK_ES_PERIODO_CONT'
WHERE
	pc.PERIODO_ID IS NOT NULL
	AND cta.cuenta_formato IN ( '7.1.2.01', '7.1.2.02', '7.1.3.01', '7.1.3.02')
