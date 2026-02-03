create PROCEDURE BVQ_BACKOFFICE.ObtenerEstructuraIsspolG01
	@lastReportDate datetime,
	@i_todos_los_vigentes bit=0,
	@i_lga_id int=null
AS
BEGIN
	SET NOCOUNT ON;
	declare @fecha DateTime = @lastReportDate
	declare @i_fechaIni DateTime=DATEADD(month, DATEDIFF(month, 0, @fecha), 0);
	delete from corteslist
	insert into corteslist
	values(@fecha,1)

	select distinct
	ems.ems_nombre,pju_identificacion
	,decreto_emisor,clasificacion=1,tipo_identificacion='R',pju_identificacion,pais='EC'
	,tipo_emisor=tipoEmisor.codigo
	,patrimonio=isnull(patrimonio,0)
	,CCA_SUSCRITO=isnull(CCA_SUSCRITO,0)
	,ECA_VALOR=isnull(ECA.codigo,30)
	,eca.fecha_desde
	,CAL_NOMBRE--*
	--,
	from bvq_backoffice.isspolRentaFijaViewNew i
	join bvq_administracion.emisor ems on i.id_emisor=ems.ems_id
	left join bvq_administracion.persona_juridica pju on ems.pju_id=pju.pju_id
	left join (values
		('PRIVADO FINANCIERO',1),('PRIVADO NO FINANCIERO',2),('PUBLICO',3),('ECONOMÍA POPULAR Y SOLIDARIA',4)
	) tipoEmisor(nombre,codigo) on SECTOR_DETALLADO=tipoEmisor.nombre
	left join (
		select EMI_ID, CCA_SUSCRITO, fecha_desde=CCA_FECHA_ACTUALIZACION
		,fecha_hasta=isnull(lead(CCA_FECHA_ACTUALIZACION) over (partition by EMI_ID order by CCA_FECHA_ACTUALIZACION),'99991231')
		from BVQ_ADMINISTRACION.COMPOSICION_CAPITAL cca where CCA_ESTADO=21
	) CCA on CCA.EMI_ID=EMS.EMS_ID and i.tfcorte>=cca.fecha_desde and i.tfcorte<cca.fecha_hasta
	left join (
		select EMI_ID, ECA_VALOR, CAL_ID
		,fecha_desde=ECA_FECHA_DESDE
		,fecha_hasta=isnull(lead(ECA_FECHA_DESDE) over (partition by EMI_ID order by ECA_FECHA_DESDE),'99991231')
		,codigo
		from BVQ_ADMINISTRACION.EMISORES_CALIFICACION eca
		left join BVQ_ADMINISTRACION.SB_CALIFICACIONES sbc on sbc.sandp=ECA_VALOR
		where ECA_ESTADO=21
	) ECA on ECA.EMI_ID=EMS.EMS_ID and i.tfcorte>=eca.fecha_desde and i.tfcorte<eca.fecha_hasta
	left join BVQ_ADMINISTRACION.CALIFICADORAS CAL ON CAL.CAL_ID=ECA.CAL_ID
	--left join (select max(fecha) f, emiid from #x group by emiid) x on x.emiid=ems.ems_id
	where
	(
		ems_fecha_creacion between @i_fechaIni and tfcorte
		or
		cca.fecha_desde between @i_fechaIni and tfcorte
		or
		eca.fecha_desde between @i_fechaIni and tfcorte
		or
		@i_todos_los_vigentes=1
	)
END