CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerEstructuraIsspolG04]
    @i_fechaCorte DATETIME,
    @i_lga_id     INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Tipo_Id_Emisor,
        Id_Emisor,
        Codigo_Instrumento,
        Tipo_Instrumento,
        Id_Instrumento,
        Numero_Liquidacion,
        Tipo_Transaccion,
        Fecha_Transaccion,
        Interes_Acumulado,
        Precio_Mercado,
        Valor_AccionHoy,
        Valor_Mercado,
        Valor_Capital,
        Valor_Pago_Cupon,
        Dividendo_Acciones,
        Dividendo_Efectivo,
        Fecha_Ultimo_Pago,
        Saldo_Valor_Nominal,
        Dias_Transcurridos,
        Dias_Vencer,
        Valor_Efectivo_Libros,
        Fuente_Cotizacion,
        Calificacion_Riesgo,
        Calificadora_Riesgo,
        Fecha_Ultima_Calificacion,
        Valor_Deteriorado,
        Saldo_Provision
    FROM BVQ_BACKOFFICE.ESTRUCTURA_ISSPOL_G04;

    /*--ejemplo
	SELECT
		CAST('R' AS CHAR(1)) AS Tipo_Id_Emisor,
		CAST(1790012345001 AS NUMERIC(13,0)) AS Id_Emisor,
		CAST('OB' AS CHAR(2)) AS Codigo_Instrumento,
		CAST(10 AS NUMERIC(2,0)) AS Tipo_Instrumento,
		CAST('INST-000000000001' AS CHAR(20)) AS Id_Instrumento,
		CAST('LIQ-2024-000002' AS CHAR(20)) AS Numero_Liquidacion,
		CAST('V' AS CHAR(1)) AS Tipo_Transaccion,
		CAST('2024-07-01' AS DATE) AS Fecha_Transaccion,
		CAST(9800.50 AS NUMERIC(15,2)) AS Interes_Acumulado,
		CAST(99.85 AS NUMERIC(5,2)) AS Precio_Mercado,
		CAST(48.75 AS NUMERIC(7,2)) AS Valor_AccionHoy,
		CAST(487500.00 AS NUMERIC(15,2)) AS Valor_Mercado,
		CAST(500000.00 AS NUMERIC(15,2)) AS Valor_Capital,
		CAST(20000.00 AS NUMERIC(15,2)) AS Valor_Pago_Cupon,
		CAST(75.00 AS NUMERIC(10,2)) AS Dividendo_Acciones,
		CAST(12000.00 AS NUMERIC(15,2)) AS Dividendo_Efectivo,
		CAST('2024-06-15' AS DATE) AS Fecha_Ultimo_Pago,
		CAST(600000.00 AS NUMERIC(15,2)) AS Saldo_Valor_Nominal,
		CAST(90 AS NUMERIC(4,0)) AS Dias_Transcurridos,
		CAST(270 AS NUMERIC(4,0)) AS Dias_Vencer,
		CAST(610000.00 AS NUMERIC(15,2)) AS Valor_Efectivo_Libros,
		CAST('Q' AS CHAR(1)) AS Fuente_Cotizacion,
		CAST('A' AS CHAR(1)) AS Calificacion_Riesgo,
		CAST(1 AS NUMERIC(1,0)) AS Calificadora_Riesgo,
		CAST('2024-05-31' AS DATE) AS Fecha_Ultima_Calificacion,
		CAST(4500.00 AS NUMERIC(15,2)) AS Valor_Deteriorado,
		CAST(3000.00 AS NUMERIC(15,2)) AS Saldo_Provision;
    */
END