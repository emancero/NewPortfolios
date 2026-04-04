CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerIngresosPorInversiones]
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
		inversion = CONCAT(sector, ' ', tiv_tipo_renta),
		sum(capital) as capital,
		sum(iamortizacion) as iamortizacion,
		por_codigo,
		max(fecha) as fecha

    FROM bvq_backoffice.[DetalleRecuperacionesIsspolFondos]
    WHERE fecha BETWEEN @FechaInicioMes AND @FechaFinMes
    GROUP BY
		CONCAT(sector, ' ', tiv_tipo_renta),
		por_codigo
    ORDER BY
        por_codigo;
END