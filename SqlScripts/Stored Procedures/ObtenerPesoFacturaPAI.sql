CREATE PROCEDURE bvq_backoffice.ObtenerPesoFacturaPAI
    @fechaCorte DATETIME = '20261022',
    @i_lga_id INT = null,
    @i_pai_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @fechaEnd DATETIME;
    SET @fechaEnd = DATEADD(s, -1, DATEADD(dd, 1, DATEDIFF(dd, 0, @fechaCorte)));

    TRUNCATE TABLE corteslist;

    INSERT INTO corteslist (c, cortenum)
    SELECT @fechaEnd, 1;

    IF OBJECT_ID('tempdb..#celdas') IS NOT NULL DROP TABLE #celdas;

    SELECT DISTINCT
        pf.PCP_ID AS F_ID,
        pt.PCP_ID AS T_ID
    INTO #celdas
    FROM BVQ_BACKOFFICE.PAI_GENERAL pg
        INNER JOIN BVQ_BACKOFFICE.PAI_TABLA tab ON tab.PAI_ID = pg.PAI_ID
        INNER JOIN BVQ_BACKOFFICE.PAI_FONDO fop ON fop.TAB_ID = tab.TAB_ID
        INNER JOIN BVQ_BACKOFFICE.PAI_TIPO_INVERSION tip ON tip.TAB_ID = tab.TAB_ID
        INNER JOIN BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO pf
            ON pf.PCP_TIPO = 'FONDO' AND pf.PCP_CODIGO = fop.FOP_CODIGO
        INNER JOIN BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO pt
            ON pt.PCP_TIPO = 'TIPO_INVERSION' AND pt.PCP_CODIGO = tip.TIP_CODIGO
    WHERE pg.PAI_ID = @i_pai_id;

    IF OBJECT_ID('tempdb..#saldos') IS NOT NULL DROP TABLE #saldos;

    SELECT
        pc.por_id,
        pcep.PCP_ID AS id_fondo,
        pcep.PCP_NOMBRE AS fondo,
        pc.tvl_codigo,
        pcet.PCP_ID AS id_tipo_inversion,
        pcet.PCP_NOMBRE AS tipo_inversion,
        SUM(pc.sal) AS saldo
    INTO #saldos
    FROM BVQ_BACKOFFICE.PortafolioCorte pc
        INNER JOIN BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO pcp ON pcp.POR_ID = pc.por_id
        INNER JOIN BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO pcep ON pcep.PCP_ID = pcp.PCP_ID
        INNER JOIN BVQ_ADMINISTRACION.TIPO_VALOR tvl ON tvl.TVL_CODIGO = pc.tvl_codigo
        INNER JOIN BVQ_BACKOFFICE.PAI_CODIGO_TIPO_VALOR pct ON pct.TVL_ID = tvl.TVL_ID
        INNER JOIN BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO pcet ON pcet.PCP_ID = pct.PCP_ID
        INNER JOIN #celdas c ON c.F_ID = pcep.PCP_ID AND c.T_ID = pcet.PCP_ID
    WHERE pc.sal > 0 AND ISNULL(pc.IPR_ES_CXC, 0) = 0
    GROUP BY pc.por_id, pcep.PCP_ID, pcep.PCP_NOMBRE, pc.tvl_codigo, pcet.PCP_ID, pcet.PCP_NOMBRE;

    DECLARE @totalSaldo FLOAT = (SELECT SUM(saldo) FROM #saldos);

    IF ISNULL(@totalSaldo, 0) <= 0
    BEGIN
        SELECT por_id, id_fondo, fondo, tvl_codigo, id_tipo_inversion, tipo_inversion, saldo, CAST(0 AS FLOAT) AS peso
        FROM #saldos
        WHERE 1 = 0;
        RETURN;
    END

    SELECT
        por_id,
        id_fondo,
        fondo,
        tvl_codigo,
        id_tipo_inversion,
        tipo_inversion,
        saldo,
        saldo / @totalSaldo AS peso
    FROM #saldos
    ORDER BY saldo / @totalSaldo DESC;
END
