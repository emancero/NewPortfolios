CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerDetalleColocacionesPAI]
	@i_fecha DATETIME,
	@i_tipo_inversion VARCHAR(200) = NULL, --NULL = todos, '' = tipo_inversion IS NULL
	@i_fondo VARCHAR(200) = NULL,          --NULL = todos los fondos (columna Total), '' = fondo IS NULL
	@i_fecha_corte DATETIME = NULL,         --NULL = 31 de diciembre del año de @i_fecha
	@i_lga_id  INT = NULL,
	@i_pai_id INT = NULL                   --PAI consultado: agrega sus facturas (NULL = sin facturas)
AS
BEGIN
	--Detalle (drilldown) de la seccion Colocaciones de ObtenerSaldosPAI: operaciones de PAIColocacionesView
	--mas las facturas del PAI consultado (PAI_FACTURA_FONDO)
	DECLARE @FechaInicioAnio DATETIME, @FechaFinAnio DATETIME;
	SET @FechaInicioAnio = DATETIMEFROMPARTS(YEAR(@i_fecha), 1, 1, 0, 0, 0, 0);
	--Mismo rango que ObtenerSaldosPAI (1 de enero del año de @i_fecha hasta la fecha de corte inclusive), para que el detalle cuadre con la celda
	SET @FechaFinAnio = ISNULL(@i_fecha_corte, DATETIMEFROMPARTS(YEAR(@i_fecha), 12, 31, 0, 0, 0, 0));
	SET @FechaFinAnio = DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, @FechaFinAnio) + 1, 0));

	SELECT d.*
	FROM (
		SELECT
			v.fondo,
			v.tipo_inversion,
			v.tvl_nombre,
			v.ems_nombre,
			CAST(NULL AS VARCHAR(200)) AS custodio,
			v.htp_fecha_operacion,
			v.tiv_fecha_vencimiento,
			v.valefeoper,
			v.htp_comision_bolsa,
			v.lip_retencion,
			v.saldo,
			v.numeracion
		FROM BVQ_BACKOFFICE.PAIColocacionesView v
		WHERE v.htp_fecha_operacion BETWEEN @FechaInicioAnio AND @FechaFinAnio

		UNION ALL

		--Facturas del PAI consultado (mismo criterio que ObtenerSaldosPAI: fecha de factura hasta la fecha de corte)
		SELECT
			pcep.PCP_NOMBRE AS fondo,
			pcet.PCP_NOMBRE AS tipo_inversion,
			'Factura' AS tvl_nombre,
			NULL AS ems_nombre,
			pfc.PFC_NOMBRE AS custodio,
			pfa.PAF_FECHA_FACTURA AS htp_fecha_operacion,
			NULL AS tiv_fecha_vencimiento,
			pff.PFF_MONTO AS valefeoper,
			NULL AS htp_comision_bolsa,
			NULL AS lip_retencion,
			pff.PFF_MONTO AS saldo,
			CAST(NULL AS VARCHAR(250)) AS numeracion
		FROM BVQ_BACKOFFICE.PAI_FACTURA_FONDO pff
			INNER JOIN BVQ_BACKOFFICE.PAI_FACTURA pfa ON pfa.PAF_ID = pff.PAF_ID
			LEFT JOIN BVQ_BACKOFFICE.PAI_FACTURA_CUSTODIO pfc ON pfc.PFC_ID = pfa.PFC_ID
			LEFT JOIN BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO pcep ON pcep.PCP_ID = pff.PCP_ID_FONDO
			LEFT JOIN BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO pcet ON pcet.PCP_ID = pff.PCP_ID_TIPO
		WHERE pfa.PAI_ID = @i_pai_id
			AND pfa.PAF_FECHA_FACTURA <= @FechaFinAnio
	) d
	WHERE (@i_tipo_inversion IS NULL
			OR (@i_tipo_inversion = '' AND d.tipo_inversion IS NULL)
			OR d.tipo_inversion = @i_tipo_inversion)
		AND (@i_fondo IS NULL
			OR (@i_fondo = '' AND d.fondo IS NULL)
			OR d.fondo = @i_fondo)
	ORDER BY d.fondo, d.htp_fecha_operacion
END
--go
--exec [BVQ_BACKOFFICE].[ObtenerDetalleColocacionesPAI] '20260101', null, null, '20261117', null, 2 --año de @i_fecha, fecha de corte, PAI consultado
