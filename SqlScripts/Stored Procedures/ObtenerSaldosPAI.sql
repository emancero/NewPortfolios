CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerSaldosPAI]
    @i_fecha DATETIME,
	@i_pdc_id INT,
    @i_lga_id  INT
AS
BEGIN
	DECLARE @FechaInicioAnio DATE, @FechaFinAnio DATE;
	SET @FechaInicioAnio = DATETIMEFROMPARTS(YEAR(@i_fecha), 1, 1, 0, 0, 0, 0);
	SET @FechaFinAnio = DATETIMEFROMPARTS(YEAR(@i_fecha), 12, 1,23,59,59,0);

	DECLARE @fecha DATETIME;
	SET @fecha = (
		SELECT MAX(per.fecha_hasta)
		FROM siisspolweb.siisspolweb.contabilidad.periodo per
		INNER JOIN siisspolweb.siisspolweb.contabilidad.saldo sal
			ON sal.id_periodo = per.id_periodo
		WHERE per.fecha_hasta BETWEEN @FechaInicioAnio AND @FechaFinAnio
	);

	SET @fecha = DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, @fecha) + 1, 0));

	EXEC bvq_backoffice.PrepararLiquidezCache null;

	SELECT
		sum(sal.saldo) AS saldo, 
		pcp.PCP_NOMBRE as fondo,
		'BCE' AS tipo_inversion,
		'Bancos' AS grupo
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

	UNION

	select 
		s.PDS_SALDO_FINAL,
		pcp.PCP_NOMBRE as fondo,
		c.PDC_NOMBRE,
		'Disponibilidad' AS grupo
	from BVQ_BACKOFFICE.ISSPOL_PROYECCION_DISP_SAL s
		LEFT JOIN BVQ_BACKOFFICE.ISSPOL_PROYECCION_DISP_CAB c
			ON c.PDC_ID = s.PDS_PDC_ID
		inner JOIN bvq_backoffice.isspol_cuentas_contables_de_bancos icb
			on icb.ICB_DESCRIPCION = s.PDS_PORTAFOLIO
		left JOIN bvq_backoffice.portafolio por
			on por.por_id = icb.ICB_POR_ID
		left join BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO pcpo
			on pcpo.POR_ID = por.por_id
		left join BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO pcp
			on pcp.PCP_ID = pcpo.PCP_ID
	WHERE c.PDC_ID = @i_pdc_id

	UNION

	SELECT
		SUM(v.montoOper) AS saldo,
		pcp.PCP_NOMBRE AS fondo,
		v.tvl_nombre AS tipo_inversion,
		'Colocaciones' AS grupo
	FROM bvq_backoffice.ObtenerDetallePortafolioConLiquidezView v
		LEFT JOIN BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO pcpo
			ON pcpo.POR_ID = v.por_id
		LEFT JOIN BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO pcp
			ON pcp.PCP_ID = pcpo.PCP_ID
	WHERE ISNULL(v.IPR_ES_CXC, 0) = 0
		AND v.oper = 0
		AND v.compra_htp_id = v.htp_id
		AND v.htp_fecha_operacion BETWEEN @FechaInicioAnio AND @FechaFinAnio
	GROUP BY pcp.PCP_NOMBRE, v.tvl_nombre
END
