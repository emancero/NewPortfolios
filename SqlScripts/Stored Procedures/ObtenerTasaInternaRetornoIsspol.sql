CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerTasaInternaRetornoIsspol]
    @i_fecha_corte DATEtime,
    @i_lga_id      INT=null
AS
BEGIN
--declare @i_fecha_corte date='20260430'

    SELECT mes
    ,exponente
    ,recuperacion_capital=sum(recuperacion_capital)
    ,recuperacion_interes=sum(recuperacion_interes)
    ,recuperacion_total=sum(recuperacion_total)
    ,valor_presente=sum(valor_presente)
    ,tasa
    ,plazo
    ,producto
    ,fondo
    from bvq_backoffice.CreditoCuota
    GROUP BY mes,exponente,tasa,plazo,producto,fondo
    ORDER BY tasa,plazo,
    mes
END
