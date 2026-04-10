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
		inversion = SCI_NOMBRE,--CONCAT(sector, ' ', tiv_tipo_renta),
		sum(capital) as capital,
		sum(iamortizacion) as iamortizacion,
		por.por_codigo,
		max(fecha) as fecha,
        SCI.SCI_ORD,
        por.por_ord
    --select distinct sci_nombre--*
    FROM
    BVQ_BACKOFFICE.PORTAFOLIO POR
    cross join
    --select * from
    BVQ_ADMINISTRACION.SECTOR_ISSPOL SCI
    left join bvq_backoffice.DetalleRecuperacionesIsspolFondos d
        cross apply (
            select secIsspol=case
                when d.tvl_codigo='ACC' then 'ACCIONES'
                when d.tiv_tipo_renta=154 then 'INVERSIONES DE RENTA VARIABLE EN EL SECTOR PRIVADO'
                when d.sector='Público' then 'INVERSIONES DE RENTA FIJA EN EL SECTOR PUBLICO'
                when d.sector='Privado no Financ.' then 'INVERSIONES DE RENTA FIJA EN EL SECTOR PRIVADO'
                when d.sector='Privado Financiero' then 'TÍTULOS EMITIDOS POR INSTITUCIONES FINANCIERAS'
                else 'OTRAS'
            end
        ) secMap
    on SCI.SCI_NOMBRE=secMap.secIsspol
        and por.por_id=d.por_id
        and fecha BETWEEN @FechaInicioMes AND @FechaFinMes
    GROUP BY
		SCI.SCI_NOMBRE,SCI.SCI_ORD,--CONCAT(sector, ' ', tiv_tipo_renta),
		por.por_codigo,por.por_ord
    ORDER BY
        por.por_ord,SCI.SCI_ORD;
END
GO


