CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerPAIPorAnio]
    @i_anio    VARCHAR(100),
    @i_lga_id  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        tab.TAB_NOMBRE  AS Tabla,
        tab.TAB_ORDEN   AS TablaOrden,
        tip.TIP_NOMBRE  AS [Tipo Inversión],
        tip.TIP_ORDEN   AS TipoInversionOrden,
        fop.FOP_NOMBRE  AS Fondo,
        fop.FOP_ORDEN   AS FondoOrden,
        pm.PAIM_MONTO   AS Monto
    FROM BVQ_BACKOFFICE.PAI_GENERAL pg
    INNER JOIN BVQ_BACKOFFICE.PAI_TABLA tab
        ON tab.PAI_ID = pg.PAI_ID
    INNER JOIN BVQ_BACKOFFICE.PAI_MONTO pm
        ON pm.TAB_ID = tab.TAB_ID
    INNER JOIN BVQ_BACKOFFICE.PAI_TIPO_INVERSION tip
        ON tip.TIP_ID = pm.TIP_ID
    INNER JOIN BVQ_BACKOFFICE.PAI_FONDO fop
        ON fop.FOP_ID = pm.FOP_ID
    WHERE pg.PAI_PERIODO = @i_anio
    ORDER BY tab.TAB_ORDEN, tip.TIP_ORDEN, fop.FOP_ORDEN;
END
