CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerInversionesSC]
    @i_fechaOperacion DATE,
	@i_lga_id int     
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE 
        @FechaInicioMes DATE,
        @FechaFinMes    DATE;

    SET @FechaInicioMes = DATEFROMPARTS(
                              YEAR(@i_fechaOperacion),
                              MONTH(@i_fechaOperacion),
                              1
                          );

    SET @FechaFinMes = EOMONTH(@i_fechaOperacion);


    SELECT
		sector,
        htp_fecha_operacion,                -- fecha de filtro
        tiv_tipo_renta,
        tvl_nombre,
		tvl_nombre_detallado,
        ems_nombre,
		condicion,
        SUM(montooper)           AS montooper,
        MAX(tpo_precio_ingreso)  AS tpo_precio_ingreso,
        SUM(valefeoper)          AS valefeoper,
        SUM(htp_comision_bolsa)  AS htp_comision_bolsa,

        tasa_cupon,
        MAX(plazo_dias)          AS plazo_dias,
        tiv_fecha_vencimiento,

        MAX(tipo_operacion)      AS tipo_operacion,
        MAX(tipo_mercado)        AS tipo_mercado,
		interes_a_recibir,
		recursos

    FROM bvq_backoffice.[DetallePortafolioBursatil]
    WHERE htp_fecha_operacion BETWEEN @FechaInicioMes AND @FechaFinMes
    GROUP BY
		sector,
        htp_fecha_operacion,
        tiv_tipo_renta,
        tvl_nombre,
		tvl_nombre_detallado,
        ems_nombre,
		condicion,
        tasa_cupon,
        tiv_fecha_vencimiento,
		interes_a_recibir,
		recursos
    ORDER BY
		htp_fecha_operacion,
        ems_nombre,
        tvl_nombre;
END