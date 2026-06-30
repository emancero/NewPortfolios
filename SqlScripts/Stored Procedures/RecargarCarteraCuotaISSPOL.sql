create procedure bvq_backoffice.RecargarCarteraCuotaISSPOL as
begin

    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    TRUNCATE TABLE [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA];

    INSERT INTO [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA]
        (por_codigo
		, total
		, fecha_vencimiento
		, id_cuenta
		, pagada
		, id_rubro
		, tasa
		, abono
		, estado
		, valor_pactado
		, id_credito
		, id_numero_cuota
		, fecha_pago
		)
    SELECT
         b.descripcion AS por_codigo
        ,valor
        ,cut.fecha_vencimiento
        ,cr.id_cuenta
        ,CONVERT(INT, cut.pagada) AS pagada
        ,cut.id_rubro AS id_rubro
        ,cr.tasa
        ,abono
        ,estado
        ,valor_pactado
		,cut.id_credito
		,cut.id_numero_cuota
		,cut.fecha_pago
    FROM siisspolweb.siisspolweb.credito.cuota cut
    JOIN siisspolweb.siisspolweb.credito.credito cr ON cr.id_credito = cut.id_credito
    JOIN siisspolweb.siisspolweb.banco.cuenta b ON b.id_cuenta = cr.id_cuenta
    WHERE cut.fecha_vencimiento > '20251130';

end