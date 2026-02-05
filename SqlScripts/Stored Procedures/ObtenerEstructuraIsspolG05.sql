alter PROCEDURE [BVQ_BACKOFFICE].[ObtenerEstructuraIsspolG05]
    @i_fechaCorte DATETIME,
	@i_todos_los_vigentes bit = 0,
    @i_lga_id     INT
AS
BEGIN
    SET NOCOUNT ON;
	declare @i_fechaIni DateTime=DATEADD(month, DATEDIFF(month, 0, @i_fechaCorte), 0);

	/*
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
	*/
    --ejemplo
	SELECT
		Tipo_Id=TIPO_ID_EMISOR,
		ID_EMISOR AS Identificacion,
		Codigo_Instrumento,
		Tipo_Instrumento,
		CAST('' AS VARCHAR(20)) AS Numero_Contrato,
		CAST(0 AS NUMERIC(3,0)) AS Numero_Inversion,
		id_Instrumento AS Nombre_Fideicomiso,
		id_Instrumento AS Nombre_Corto_Fideicomiso,
		CAST('1900-01-01' AS DATE) AS Fecha_Constitucion,
		CAST('1900-01-01' AS DATE) AS Fecha_Inscripcion,
		CAST(null AS NUMERIC(1,0)) AS Tipo_Fideicomiso,
		CAST(null AS NUMERIC(2,0)) AS Duracion_Fideicomiso,
		CAST(null AS CHAR(2)) AS Periodicidad_Rendicion_Cuentas,
		CAST(null AS DATE) AS Ultimo_Periodo_Rendicion,
		CAST(null AS CHAR(2)) AS Periodicidad_Estados_Financieros,
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
		CAST(0.00 AS NUMERIC(15,2)) AS Valores_Restituidos_Bienes
    from BVQ_BACKOFFICE.EstructuraIsspolView e
	left join BVQ_BACKOFFICE.ESTRUCTURA_ISSPOL_G05 g on g.FON_ID=e.FON_ID
	left join BVQ_ADMINISTRACION.SB_CALIFICACIONES sbc on sbc.sandp=Calificacion_Riesgo_Emision
	where esCxc=0 and oper=0
	and (
		Fecha_transaccion between @i_fechaIni and @i_fechaCorte
		or @i_todos_los_vigentes=1
	)


END