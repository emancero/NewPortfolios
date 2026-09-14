CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerSaldosPAI]
    @i_fecha DATETIME,
    @i_lga_id  INT
AS
BEGIN
	DECLARE @fecha DATETIME;
	SET @fecha = (
		SELECT MAX(per.fecha_hasta)
		FROM siisspolweb.siisspolweb.contabilidad.periodo per
		INNER JOIN siisspolweb.siisspolweb.contabilidad.saldo sal
			ON sal.id_periodo = per.id_periodo
	);
	SET @fecha = DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, @fecha) + 1, 0));

	SELECT 
		sum(sal.saldo) AS saldo, 
		pcp.PCP_NOMBRE as fondo,
		'BCE' AS tipo_inversion
	FROM siisspolweb.siisspolweb.contabilidad.saldo sal
		INNER JOIN siisspolweb.siisspolweb.contabilidad.cuenta cta
			ON cta.id_cuenta = sal.id_cuenta
		INNER JOIN siisspolweb.siisspolweb.contabilidad.periodo per 
			ON per.id_periodo = sal.id_periodo
		inner JOIN bvq_backoffice.isspol_cuentas_contables_de_bancos icb
			on icb.ICB_CUENTA = cta.cuenta
		left JOIN bvq_backoffice.portafolio por
			on por.por_id = icb.ICB_POR_ID
		left join BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO pcpo
			on pcpo.POR_ID = por.por_id
		left join BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO pcp
			on pcp.PCP_ID = pcpo.PCP_ID
	WHERE per.fecha_hasta = @fecha
	GROUP BY por.POR_ID, por.POR_CODIGO, pcp.PCP_NOMBRE
END
