CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerEstructuraIsspolG05]
    @i_fechaCorte DATETIME,
    @i_lga_id     INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Tipo_Id,
        Identificacion,
        Codigo_Instrumento,
        Tipo_Instrumento,
        Numero_Contrato,
        Numero_Inversion,
        Nombre_Fideicomiso,
        Nombre_Corto_Fideicomiso,
        Fecha_Constitucion,
        Fecha_Inscripcion,
        Tipo_Fideicomiso,
        Duracion_Fideicomiso,
        Periodicidad_Rendicion_Cuentas,
        Ultimo_Periodo_Rendicion,
        Periodicidad_Estados_Financieros,
        Ultimo_Periodo,
        Fecha_Ultima_Auditoria,
        Nombre_Fiduciaria,
        Activos,
        Pasivos,
        Patrimonio_Autonomo,
        Saldo_Otros,
        Saldo_Fiduciarios,
        Fecha_Liquidacion,
        Valores_Restituidos_Efectivo,
        Valores_Restituidos_Bienes
    FROM BVQ_BACKOFFICE.ESTRUCTURA_ISSPOL_G05;

    /*--ejemplo
	SELECT
		CAST('R' AS CHAR(1)) AS Tipo_Id,
		CAST('1790012345001' AS CHAR(13)) AS Identificacion,
		CAST('FI' AS CHAR(2)) AS Codigo_Instrumento,
		CAST(20 AS NUMERIC(2,0)) AS Tipo_Instrumento,
		CAST('CONTR-EP-2020-001' AS CHAR(20)) AS Numero_Contrato,
		CAST(1 AS NUMERIC(3,0)) AS Numero_Inversion,
		CAST('FIDEICOMISO DE INVERSION INMOBILIARIA QUITO CENTRO' AS CHAR(70)) 
			AS Nombre_Fideicomiso,
		CAST('FIDEI INMOB QUITO' AS CHAR(50)) AS Nombre_Corto_Fideicomiso,
		CAST('2020-03-15' AS DATE) AS Fecha_Constitucion,
		CAST('2020-04-01' AS DATE) AS Fecha_Inscripcion,
		CAST(1 AS NUMERIC(1,0)) AS Tipo_Fideicomiso,
		CAST(20 AS NUMERIC(2,0)) AS Duracion_Fideicomiso,
		CAST('AN' AS CHAR(2)) AS Periodicidad_Rendicion_Cuentas,
		CAST('2024-12-31' AS DATE) AS Ultimo_Periodo_Rendicion,
		CAST('AN' AS CHAR(2)) AS Periodicidad_Estados_Financieros,
		CAST('2024-12-31' AS DATE) AS Ultimo_Periodo,
		CAST('2025-02-15' AS DATE) AS Fecha_Ultima_Auditoria,
		CAST('FIDUCIARIA NACIONAL DEL ECUADOR S.A.' AS CHAR(50)) AS Nombre_Fiduciaria,
		CAST(2500000.00 AS NUMERIC(15,2)) AS Activos,
		CAST(750000.00 AS NUMERIC(15,2)) AS Pasivos,
		CAST(1750000.00 AS NUMERIC(15,2)) AS Patrimonio_Autonomo,
		CAST(300000.00 AS NUMERIC(15,2)) AS Saldo_Otros,
		CAST(2050000.00 AS NUMERIC(15,2)) AS Saldo_Fiduciarios,
		CAST(NULL AS DATE) AS Fecha_Liquidacion,
		CAST(0.00 AS NUMERIC(15,2)) AS Valores_Restituidos_Efectivo,
		CAST(0.00 AS NUMERIC(15,2)) AS Valores_Restituidos_Bienes;
    */

END