create PROCEDURE BVQ_BACKOFFICE.ObtenerEstructuraIsspolG01
	@lastReportDate datetime,
	@i_todos_los_vigentes bit=0,
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

	exec bvq_backoffice.GenerarCompraVentaFlujo
	select distinct
	 Errores=
	 case when isnull(Patrimonio,0)=0 and tipoEmisor.codigo<>3 then
			'Sin patrimonio y no es público'
		 end
	,ems.EMS_NOMBRE
	,pju_identificacion
	,decreto_emisor,clasificacion=1,tipo_identificacion='R',pju_identificacion,pais='EC'
	,tipo_emisor=tipoEmisor.codigo
	,patrimonio=coalesce(patrimonio, vba.VBA_PATRIMONIO_TECNICO, 0)
	,CCA_SUSCRITO=isnull(CCA_SUSCRITO,0)
	,ECA_VALOR=isnull(ECA.codigo,30)
	,eca.fecha_desde
	,eca.CAL_NOMBRE--*
	,eca.Calificacion_Codigo
	,eca.Calificadora_Codigo
	--,
	from (
		select EMS_ID, EMS_NOMBRE
		,PJU_ID
	    ,SECTOR_DETALLADO=case when itcsector.itc_codigo='SEC_PRI_FIN' then
			case when EMS_NOMBRE collate modern_spanish_ci_ai like 'COOPERATIVA DE AHORRO Y CRÉDITO%' THEN 'ECONOMÍA POPULAR Y SOLIDARIA' else 'PRIVADO FINANCIERO' end
		else
			case itcsector.itc_codigo WHEN 'SEC_PRI_FIN' then 'PRIVADO FINANCIERO Y ECONOMÍA POPULAR SOLIDARIA' WHEN 'SEC_PRI_NFIN' THEN 'PRIVADO NO FINANCIERO' WHEN 'SEC_PUB_FIN' THEN 'PUBLICO' WHEN 'SEC_PUB_NFIN' THEN 'PUBLICO' END
		END
		from bvq_administracion.emisor ems
		join bvq_administracion.item_catalogo itcsector on itcsector.itc_id=ems.ems_sector
	) ems
	join (
		select min(htp_fecha_operacion) EMS_FECHA_PRIMER_USO, tiv_emisor
		from bvq_backoffice.HISTORICO_TITULOS_PORTAFOLIO htp 
		join bvq_administracion.titulo_valor tiv on htp.tiv_id=tiv.tiv_id
		where htp_estado=352
		group by tiv_emisor
	) htp on ems.ems_id=htp.tiv_emisor
	left join bvq_administracion.persona_juridica pju on ems.pju_id=pju.pju_id
	left join (values
		('PRIVADO FINANCIERO',1),('PRIVADO NO FINANCIERO',2),('PUBLICO',3),('ECONOMÍA POPULAR Y SOLIDARIA',4)
	) tipoEmisor(nombre,codigo) on SECTOR_DETALLADO=tipoEmisor.nombre
	left join (
		select EMI_ID, CCA_SUSCRITO, fecha_desde=CCA_FECHA_ACTUALIZACION
		,fecha_hasta=isnull(lead(CCA_FECHA_ACTUALIZACION) over (partition by EMI_ID order by CCA_FECHA_ACTUALIZACION),'99991231')
		from BVQ_ADMINISTRACION.COMPOSICION_CAPITAL cca where CCA_ESTADO=21
	) CCA on CCA.EMI_ID=EMS.EMS_ID and htp.EMS_FECHA_PRIMER_USO>=cca.fecha_desde and htp.EMS_FECHA_PRIMER_USO<cca.fecha_hasta
	left join (
		select EMI_ID, ECA_VALOR, eca.CAL_ID
		, Calificacion_Codigo=sbc.codigo, Calificadora_Codigo=csm.CSM_CODIGO
		, cal.CAL_NOMBRE
		,fecha_desde=ECA_FECHA_DESDE
		,fecha_hasta=isnull(lead(ECA_FECHA_DESDE) over (partition by EMI_ID order by ECA_FECHA_DESDE),'99991231')
		,codigo
			from BVQ_ADMINISTRACION.EMISORES_CALIFICACION eca
		left join BVQ_ADMINISTRACION.CALIFICADORAS CAL ON CAL.CAL_ID=ECA.CAL_ID
		left join BVQ_ADMINISTRACION.SB_CALIFICACIONES sbc on sbc.sandp=ECA_VALOR
		left join bvq_administracion.CALIFICADORA_SB_MAP csm on csm.csm_cal_id=eca.CAL_ID
		where ECA_ESTADO=21
	) ECA on ECA.EMI_ID=EMS.EMS_ID and htp.EMS_FECHA_PRIMER_USO>=eca.fecha_desde and htp.EMS_FECHA_PRIMER_USO<eca.fecha_hasta
	left join bvq_backoffice.isspolRentaFijaViewNew i on @i_todos_los_vigentes=1 and i.id_emisor=ems.ems_id
	left join bvq_administracion.variables_balance vba on EMS.EMS_ID=vba.ems_id and EMS_FECHA_PRIMER_USO between vba_fecha_desde and dateadd(s,-1,vba_fecha_hasta)
	
	--left join (select max(fecha) f, emiid from #x group by emiid) x on x.emiid=ems.ems_id
	where
	(
		EMS_FECHA_PRIMER_USO between @i_fechaIni and @fecha
		or
		cca.fecha_desde between @i_fechaIni and @fecha
		or
		eca.fecha_desde between @i_fechaIni and @fecha
		or
		@i_todos_los_vigentes=1 and i.id_emisor is not null
	)
END