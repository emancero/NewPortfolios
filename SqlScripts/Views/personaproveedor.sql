-- =============================================
-- Author:			Patricio Villacis
-- Create date: 	17/04/2017
-- Description:		Vista que muestra la información de proveedores
-- History:			
-- =============================================
 
create view bvq_backoffice.personaproveedor as
 
select	pro.pro_id
		,'J' as pro_inicial_tipo
		,isnull(prj.prj_identificacion,'NO DISPONIBLE') as identificacion
		,rtrim(prj.prj_razon_social) as nombre
		,itcEst.ITC_CODIGO as estado
		,pro.pro_estado
		,prj.prj_id as codigo
		,pro.PRO_FECHA_CREACION
		--,PRO_FECHA_ACTUALIZACION=isnull(pro.PRO_FECHA_ACTUALIZACION,prj.PRJ_FECHA_ULTIMA_ACT)
		,PRO_FECHA_ACTUALIZACION = prj.PRJ_FECHA_ULTIMA_ACT
from bvq_backoffice.proveedor pro
	inner join bvq_prevencion.persona_juridica prj on pro.prj_id=prj.prj_id
	inner join BVQ_ADMINISTRACION.ITEM_CATALOGO itcEst on pro.PRO_ESTADO=itcEst.ITC_ID
union
select	
		pro.pro_id
		,'N' as pro_inicial_tipo
		,(case when itc.itc_codigo='PRO_RUC' then pna.pna_identificacion+'001' else pna.pna_identificacion end) as identificacion
		,rtrim(PNA_PRIMER_APELLIDO + isnull(' ' + PNA_SEGUNDO_APELLIDO,'')) +', ' + PNA_PRIMER_NOMBRE + isnull(' ' + PNA_SEGUNDO_NOMBRE,'') as nombre
		,itcEst.ITC_CODIGO as estado
		,pro.pro_estado
		,pna.pna_id
		,pro.PRO_FECHA_CREACION
		--,PRO_FECHA_ACTUALIZACION=isnull(pro.PRO_FECHA_ACTUALIZACION,pna.PNA_FECHA_ULTIMA_ACT)
		,PRO_FECHA_ACTUALIZACION=pna.PNA_FECHA_ULTIMA_ACT
from bvq_backoffice.proveedor pro
	inner join bvq_prevencion.persona_natural pna on pro.pna_id=pna.pna_id
	inner join bvq_administracion.item_catalogo itc on pro.pro_identificacion_tributaria=itc.itc_id
	inner join BVQ_ADMINISTRACION.ITEM_CATALOGO itcEst on pro.PRO_ESTADO=itcEst.ITC_ID