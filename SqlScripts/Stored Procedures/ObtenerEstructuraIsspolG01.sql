--exec BVQ_BACKOFFICE.ObtenerEstructuraIsspolG01 '2023-12-31T23:59:59',1
alter PROCEDURE BVQ_BACKOFFICE.ObtenerEstructuraIsspolG01
	--declare
	@lastReportDate datetime='20231231',
	@i_todos_los_vigentes bit=1,
	@i_lga_id int=null
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	declare @fecha DateTime = @lastReportDate
	declare @i_fechaIni DateTime=DATEADD(month, DATEDIFF(month, 0, @fecha), 0);
	delete from corteslist
	insert into corteslist
	values(@fecha,1)
	--select replace(dbo.colstr('bvq_backoffice.emisorestructuraisspolview'),',',char(13)+char(10)+', e.')
	exec bvq_backoffice.GenerarCompraVentaFlujo

	if @i_todos_los_vigentes=0
		select distinct
		  e.Errores
		, e.vigentes
		, e.fecha_transaccion
		, e.EMS_NOMBRE
		, e.pju_identificacion
		, e.decreto_emisor
		, e.clasificacion
		, e.tipo_identificacion
		, e.pais
		, e.tipo_emisor
		, e.patrimonio
		, e.CCA_SUSCRITO
		, e.ECA_VALOR
		, e.fecha_desde
		, e.CAL_NOMBRE
		, e.Calificacion_Codigo
		, e.Calificadora_Codigo
		from bvq_backoffice.EmisorEstructuraIsspolView e
		--left join (select max(fecha) f, emiid from #x group by emiid) x on x.emiid=ems.ems_id
		where
		e.vigentes=0
		and (
			e.fecha_transaccion between @i_fechaIni and @fecha
			or
			e.fecha_desde between @i_fechaIni and @fecha
			or
			e.fecha_desde between @i_fechaIni and @fecha
		)
	else
		select distinct
		  e.Errores
		, e.fecha_transaccion
		, e.vigentes
		, e.EMS_NOMBRE
		, e.pju_identificacion
		, e.decreto_emisor
		, e.clasificacion
		, e.tipo_identificacion
		, e.pais
		, e.tipo_emisor
		, e.patrimonio
		, e.CCA_SUSCRITO
		, e.ECA_VALOR
		, e.fecha_desde
		, e.CAL_NOMBRE
		, e.Calificacion_Codigo
		, e.Calificadora_Codigo
		from bvq_backoffice.EmisorEstructuraIsspolView e
		left join bvq_backoffice.isspolRentaFijaViewNew i on i.id_emisor=e.ems_id and e.fecha_transaccion=i.tfcorte
		where e.vigentes=1 and datediff(d,@lastReportDate,e.fecha_transaccion)=0 and (i.id_emisor is not null or e.clasificacion=2)
END