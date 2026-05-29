CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerTasaInternaRetornoIsspol]
    @i_fecha_corte DATE,
    @i_lga_id      INT
AS
BEGIN
    SET NOCOUNT ON;

	if (OBJECT_ID('[BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA]') is NULL)
	begin
		select 
				b.descripcion as por_codigo
				,sum(valor) as total
				,convert(date,cut.fecha_vencimiento) as fecha_vencimiento
				,cr.id_cuenta
				,max(convert(int,cut.pagada)) as pagada
				,max(cut.id_rubro) as id_rubro
				,sum(case when cut.id_rubro = 'K' then cut.saldo end) as saldo
				,max(cr.id_estado) as id_estado
				,sum(case when cut.id_rubro='I' then cut.valor_pactado end) as valor_pactado
		into [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA]
		from	siisspolweb.siisspolweb.credito.cuota cut
				join siisspolweb.siisspolweb.credito.credito cr on cr.id_credito=cut.id_credito
				join siisspolweb.siisspolweb.banco.cuenta b on b.id_cuenta=cr.id_cuenta
		where cut.fecha_vencimiento>@i_fecha_corte
		group by b.descripcion,cut.fecha_vencimiento, cr.id_cuenta
	End
	else 
	begin
		truncate table [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA]
		insert into [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA]
		select 
				b.descripcion as por_codigo
				,sum(valor) as total
				,convert(date,cut.fecha_vencimiento) as fecha_vencimiento
				,cr.id_cuenta
				,max(convert(int,cut.pagada)) as pagada
				,max(cut.id_rubro) as id_rubro
				,sum(case when cut.id_rubro = 'K' then cut.saldo end) as saldo
				,max(cr.id_estado) as id_estado
				,sum(case when cut.id_rubro='I' then cut.valor_pactado end) as valor_pactado
		from	siisspolweb.siisspolweb.credito.cuota cut
				join siisspolweb.siisspolweb.credito.credito cr on cr.id_credito=cut.id_credito
				join siisspolweb.siisspolweb.banco.cuenta b on b.id_cuenta=cr.id_cuenta
		where cut.fecha_vencimiento>@i_fecha_corte
		group by b.descripcion,cut.fecha_vencimiento, cr.id_cuenta
	end

    SELECT * FROM
    (
        SELECT
            '' AS POR_CODIGO,
            DATEDIFF(M, @i_fecha_corte, fecha_vencimiento) AS mes,
            DATEDIFF(M, @i_fecha_corte, fecha_vencimiento) / 12.0 AS exponente,
            ISNULL(SUM(saldo), 0) AS recuperacion_capital,
            ISNULL(SUM(valor_pactado), 0) AS recuperacion_interes,
            SUM(ISNULL(saldo, 0) + ISNULL(valor_pactado, 0)) AS recuperacion_total,
            SUM((ISNULL(saldo, 0) + ISNULL(valor_pactado, 0)) / POWER(1.08, DATEDIFF(M, @i_fecha_corte, fecha_vencimiento) / 12.0)) AS valor_presente
        FROM [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA]
        GROUP BY DATEDIFF(M, @i_fecha_corte, fecha_vencimiento)

        UNION

        SELECT
            '' AS POR_CODIGO,
            DATEDIFF(M, @i_fecha_corte, CRC_FECHA_CIERRE) AS mes,
            1 AS exponente,
            NULL AS recuperacion_capital,
            NULL AS recuperacion_interes,
            -SUM(CRC_SALDO_PRESTAMO) AS recuperacion_total,
            -SUM(CRC_SALDO_PRESTAMO) AS valor_presente
        FROM BVQ_BACKOFFICE.CREDITOS_CARTERA
        WHERE DATEDIFF(M, @i_fecha_corte, CRC_FECHA_CIERRE) = 0
        GROUP BY CRC_FECHA_CIERRE
    ) AS t
    ORDER BY mes
END
