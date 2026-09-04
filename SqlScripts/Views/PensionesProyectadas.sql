ALTER VIEW BVQ_BACKOFFICE.PensionesProyectadas
AS
WITH Meses AS (
    SELECT 0 AS NumMes
    UNION ALL
    SELECT NumMes + 1
    FROM Meses
    WHERE NumMes < 23
)
SELECT 
    portafolio = CAST(NULL AS varchar)
    ,cuenta_contable = CAST(NULL AS varchar)
    ,fecha_vencimiento = EOMONTH(GETDATE(), NumMes)
    ,cupon = CASE MONTH(EOMONTH(GETDATE(), NumMes))
                WHEN 8  THEN 25000000 * 1.5   -- Agosto
                WHEN 12 THEN 25000000 * 2     -- Diciembre
                ELSE 25000000
             END
    ,origen = 'Proyectado'
    ,[real] = 0
    ,[itc_valor] = 'PENSIONES'
    ,[tipo] = 'Proyectado'
    ,id_cuenta = CAST(NULL AS INT)
    ,[I/E] = CAST(NULL AS varchar)
    ,CRC_NUMERO_OPERACION = 0
    ,id_rubro = CAST(NULL AS varchar)
    ,tasa = CAST(NULL AS FLOAT)
    ,producto = CAST(NULL AS varchar)
    ,segmento = CAST(NULL AS varchar)
    ,estado = CAST(NULL AS CHAR)
    ,valor = CAST(NULL AS MONEY)
    ,abono = CAST(NULL AS MONEY)
    ,tipo_papel=CAST(NULL AS varchar)
FROM Meses;