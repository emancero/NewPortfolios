alter view bvq_backoffice.EmisorEstructuraIsspolView as
	select distinct
	 Errores=
	 case when isnull(vba.VBA_PATRIMONIO_TECNICO,0)=0 and tipoEmisor.codigo<>3 then
			'Sin patrimonio y no es público'
		 end
	,fecha_transaccion
	,vigentes
	,ems.EMS_ID
	,ems.EMS_NOMBRE
	,pju_identificacion
	,decreto_emisor=null,clasificacion=1,tipo_identificacion='R'
	,pais='EC'
	,tipo_emisor=tipoEmisor.codigo
	,patrimonio=coalesce(vba.VBA_PATRIMONIO_TECNICO, 0)
	,CCA_SUSCRITO=
		case when CCA_SUSCRITO is not null then CCA_SUSCRITO
		--EMN: De acuerdo a Whatsapp del Isspol del 6 de marzo de 2026, si no tiene capital suscrito
		--y es titularización o cooperativa, se coloca el patrimonio
		when tipoEmisor.codigo=4 or ems.EMS_ES_TIT=1 then coalesce(vba.VBA_PATRIMONIO_TECNICO,0)
		else 0 end
	,ECA_VALOR=isnull(ECA.codigo,30)
	,eca.fecha_desde
	,eca.CAL_NOMBRE--*
	,Calificacion_Codigo=isnull(eca.Calificacion_Codigo,30)
	,Calificadora_Codigo=isnull(eca.Calificadora_Codigo,0)
	,cca_fecha_desde=cca.fecha_desde
	,VBA_FECHA_DESDE
	,ems.EMS_ES_TIT
	--,
	from (
		select EMS_ID, EMS_NOMBRE
		,PJU_ID
	    ,SECTOR_DETALLADO=case when itcsector.itc_codigo='SEC_PRI_FIN' then
			case when EMS_NOMBRE collate modern_spanish_ci_ai like 'COOPERATIVA DE AHORRO Y CRÉDITO%' THEN 'ECONOMÍA POPULAR Y SOLIDARIA' else 'PRIVADO FINANCIERO' end
		else
			case itcsector.itc_codigo WHEN 'SEC_PRI_FIN' then 'PRIVADO FINANCIERO Y ECONOMÍA POPULAR SOLIDARIA' WHEN 'SEC_PRI_NFIN' THEN 'PRIVADO NO FINANCIERO' WHEN 'SEC_PUB_FIN' THEN 'PUBLICO' WHEN 'SEC_PUB_NFIN' THEN 'PUBLICO' END
		END
		--select definition,is_persisted,is_computed,* from sys.computed_columns c where object_id=object_id('bvq_administracion.emisor') and name like 'emi_es_tit'
		--select ems.*
		,EMS_ES_TIT=(case when charindex('FIDEICOMISO',[ems_nombre])>(0) OR charindex('TITULARIZACION',[ems_nombre] collate modern_spanish_ci_ai)>(0) then (1) else (0) end)
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

	--fechas: genera dos tipos de operación diferenciadas por el campo vigentes
	cross apply (
		select fecha_transaccion=htp.EMS_FECHA_PRIMER_USO, convert(bit,0 )vigentes
		union all select c,convert(bit,1) from corteslist
	) fechas
	--fin fechas

	left join (
		select EMI_ID, CCA_SUSCRITO, fecha_desde=CCA_FECHA_ACTUALIZACION
		,fecha_hasta=isnull(lead(CCA_FECHA_ACTUALIZACION) over (partition by EMI_ID order by CCA_FECHA_ACTUALIZACION),'99991231')
		from BVQ_ADMINISTRACION.COMPOSICION_CAPITAL cca --where CCA_ESTADO=21
	) CCA on CCA.EMI_ID=EMS.EMS_ID and fechas.fecha_transaccion>=cca.fecha_desde and fechas.fecha_transaccion<cca.fecha_hasta
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
	) ECA on ECA.EMI_ID=EMS.EMS_ID and fechas.fecha_transaccion>=eca.fecha_desde and fechas.fecha_transaccion<eca.fecha_hasta
	left join bvq_administracion.variables_balance vba on EMS.EMS_ID=vba.ems_id and fechas.fecha_transaccion between vba_fecha_desde and dateadd(s,-1,vba_fecha_hasta)
	--select id_emisor,decreto_emisor,* from bvq_backoffice.IsspolRentaFijaView where id_emisor=538
	--select * from bvq_administracion.variables_balance where ems_id=538
	union all
	select
	 Errores=null
	,fecha_transaccion=c
	,vigentes=1
	,EMS_ID=null
	,EMS_NOMBRE='DECEVALE'
	,pju_identificacion='0991283765001'
	,decreto_emisor=null
	,clasificacion=2
	,tipo_identificacion='R'
	,pais='EC'
	,tipo_emisor=1--3-público--02--tipoEmisor.codigo
	,patrimonio=3327694.18--coalesce(patrimonio, vba.VBA_PATRIMONIO_TECNICO, 0)
	,CCA_SUSCRITO=2700000--isnull(CCA_SUSCRITO,0)
	,ECA_VALOR=null--isnull(ECA.codigo,30)
	,fecha_desde=null
	,CAL_NOMBRE=null--*
	,Calificacion_Codigo=30--isnull(eca.Calificacion_Codigo,30)
	,Calificadora_Codigo=0--isnull(eca.Calificadora_Codigo,0)
	,cca_fecha_desde=null
	,vba_fecha_desde=null
	,ems_es_tit=0
	from corteslist
	union all select
	 Errores=null
	,fecha_transaccion=c
	,vigentes=1
	,EMS_ID=null
	,EMS_NOMBRE='DCV-BCE'
	,pju_identificacion='1760002600001'
	,decreto_emisor=null
	,clasificacion=2
	,tipo_identificacion='R'
	,pais='EC'
	,tipo_emisor=3--3-público--02--tipoEmisor.codigo
	,patrimonio=0--coalesce(patrimonio, vba.VBA_PATRIMONIO_TECNICO, 0)
	,CCA_SUSCRITO=0--isnull(CCA_SUSCRITO,0)
	,ECA_VALOR=null--isnull(ECA.codigo,30)
	,fecha_desde=null
	,CAL_NOMBRE=null--*
	,Calificacion_Codigo=30--isnull(eca.Calificacion_Codigo,30)
	,Calificadora_Codigo=0--isnull(eca.Calificadora_Codigo,0)
	,cca_fecha_desde=null
	,vba_fecha_desde=null
	,ems_es_tit=0
	from corteslist