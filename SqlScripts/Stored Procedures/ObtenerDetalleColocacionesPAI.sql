CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerDetalleColocacionesPAI]
	@i_fecha DATETIME,
	@i_tipo_inversion VARCHAR(200) = NULL, --NULL = todos, '' = tipo_inversion IS NULL
	@i_fondo VARCHAR(200) = NULL           --NULL = todos los fondos (columna Total), '' = fondo IS NULL
AS
BEGIN
	--Detalle (drilldown) de la seccion Colocaciones de ObtenerSaldosPAI que viene de PAIColocacionesView
	DECLARE @FechaInicioAnio DATETIME, @FechaFinAnio DATETIME;
	SET @FechaInicioAnio = DATETIMEFROMPARTS(YEAR(@i_fecha), 1, 1, 0, 0, 0, 0);
	--Mismo rango que ObtenerSaldosPAI, para que el detalle cuadre con la celda
	SET @FechaFinAnio = DATETIMEFROMPARTS(YEAR(@i_fecha), 12, 1, 23, 59, 59, 0);

	SELECT
		v.fondo,
		v.tipo_inversion,
		v.tvl_nombre,
		v.ems_nombre,
		v.htp_fecha_operacion,
		v.tiv_fecha_vencimiento,
		v.valefeoper,
		v.htp_comision_bolsa,
		v.lip_retencion,
		v.saldo
	FROM BVQ_BACKOFFICE.PAIColocacionesView v
	WHERE v.htp_fecha_operacion BETWEEN @FechaInicioAnio AND @FechaFinAnio
		AND (@i_tipo_inversion IS NULL
			OR (@i_tipo_inversion = '' AND v.tipo_inversion IS NULL)
			OR v.tipo_inversion = @i_tipo_inversion)
		AND (@i_fondo IS NULL
			OR (@i_fondo = '' AND v.fondo IS NULL)
			OR v.fondo = @i_fondo)
	ORDER BY v.fondo, v.htp_fecha_operacion
END
--go
--exec [BVQ_BACKOFFICE].[ObtenerDetalleColocacionesPAI] '20260101', null, null
