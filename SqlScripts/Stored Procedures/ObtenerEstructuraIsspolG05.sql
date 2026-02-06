CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerEstructuraIsspolG05]
    @i_fechaCorte DATETIME,
	@i_todos_los_vigentes bit = 0,
    @i_lga_id     INT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READUNCOMMITTED
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
		e.Codigo_Instrumento,
		e.Tipo_Instrumento,
		Numero_Contrato,
		Numero_Inversion,
		e.id_Instrumento AS Nombre_Fideicomiso,
		e.id_Instrumento AS Nombre_Corto_Fideicomiso,
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
    from BVQ_BACKOFFICE.EstructuraIsspolView e
	left join BVQ_BACKOFFICE.ESTRUCTURA_ISSPOL_G05 g on g.FON_ID=e.FON_ID
	left join BVQ_ADMINISTRACION.SB_CALIFICACIONES sbc on sbc.sandp=Calificacion_Riesgo_Emision
	left join (
		select distinct tpo.FON_ID from bvq_backoffice.portafolioCorte pc
		join bvq_backoffice.TITULOS_PORTAFOLIO tpo on tpo.tpo_id=pc.httpo_id
		where sal>0
	) pc
	on @i_todos_los_vigentes=1 and e.FON_ID=pc.FON_ID
	where esCxc=0 and oper=0
	and (
		Fecha_transaccion between @i_fechaIni and @i_fechaCorte
		or @i_todos_los_vigentes=1
	)
	and e.Tipo_Instrumento=23 --23=Encargo fiduciario


END