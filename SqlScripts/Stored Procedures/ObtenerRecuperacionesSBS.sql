CREATE PROCEDURE BVQ_BACKOFFICE.ObtenerRecuperacionesSBS
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
		CASE tipo_renta
			WHEN '153' THEN 'Renta Fija'
			WHEN '154' THEN 'Renta Variable'
			ELSE NULL
		END AS tipo_renta,
		sector,
		fecha_compra,
		fecha_vencimiento,
		nombre,
		tvl_nombre,
		saldo_valor_nominal,
		rendimiento,
		plazo_cupon
		,capital,
		iamortizacion,
		pago_total
		,fecha_pago
		,fecha_de_vencimiento_flujo
		,acciones_judiciales
		,primer_nivel
		,tipo_flujo

    FROM bvq_backoffice.DetalleRecuperacionesIsspol
    WHERE fecha_pago BETWEEN @FechaInicioMes AND @FechaFinMes
  --  GROUP BY
		--tpo_numeracion,oper,fecha_pago,tpo.tiv_id
    ORDER BY
		fecha_compra,
        nombre
END
