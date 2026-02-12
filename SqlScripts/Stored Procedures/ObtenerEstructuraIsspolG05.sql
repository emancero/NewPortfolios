CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerEstructuraIsspolG05]
--declare
    @i_fechaCorte DATETIME,
	@i_todos_los_vigentes bit = 0,
    @i_lga_id     INT
AS

BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    SET NOCOUNT ON;
	

	declare @i_fechaIni DateTime=DATEADD(month, DATEDIFF(month, 0, @i_fechaCorte), 0);

	if @i_todos_los_vigentes=0
		SELECT
			e.EMS_NOMBRE,
			Tipo_Id=TIPO_ID_EMISOR,
			ID_EMISOR AS Identificacion,
			e.Codigo_Instrumento,
			e.Tipo_Instrumento,
			Numero_Contrato,
			Numero_Inversion,
			e.ems_nombre AS Nombre_Fideicomiso,
			e.ems_codigo AS Nombre_Corto_Fideicomiso,
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
		where esCxc=0 and oper=0
		and Fecha_transaccion between @i_fechaIni and @i_fechaCorte
		and e.Tipo_Instrumento=23 --23=Encargo fiduciario
	else
		SELECT
			e.EMS_NOMBRE,
			Tipo_Id=TIPO_ID_EMISOR,
			ID_EMISOR AS Identificacion,
			e.Codigo_Instrumento,
			e.Tipo_Instrumento,
			Numero_Contrato,
			Numero_Inversion,
			e.ems_nombre AS Nombre_Fideicomiso,
			e.ems_nombre AS Nombre_Corto_Fideicomiso,
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
		where esCxc=0 and oper=-1
		and datediff(d,fecha_transaccion,@i_fechaCorte)=0 -- 1 para T-1
		and e.Tipo_Instrumento=23 --23=Encargo fiduciario
END

--exec bvq_backoffice.generarvaloracionsb
/*
--pruebas:
update bvq_administracion.emisor set ems_codigo='SANTA CRUZ'
select ems_id,ems_codigo,*
from BVQ_BACKOFFICE.EstructuraIsspolView e
where oper=0--1
and datediff(m,fecha_transaccion,'20240801')=0 and tipo_instrumento=23
select tfcorte
select ems_id,ems_codigo,tvl_codigo,htp_tpo_id,montooper,* from
bvq_backoffice.evttemp e
where htp_tpo_id=2175--tpo_numeracion='MONTECRISTI-2015-12-29-2'
where fecha='20240801' and oper=0
		select tfcorte,pc.tiv_id,htp_numeracion,tpo.fon_id,* from bvq_backoffice.portafolioCorte pc
		join bvq_backoffice.TITULOS_PORTAFOLIO tpo on tpo.tpo_id=pc.httpo_id
		where sal>0
	
		and tvl_codigo='enc'
select tiv_emisor from bvq_administracion.titulo_valor where tiv_id=1e9+120 and tiv_emisor=1e9+8
select tpo_numeracion,fon_id,* from bvq_backoffice.titulos_portafolio tpo where tpo_numeracion like 'montec%'
select fecha_transaccion,fon_id,oper,escxc,* from bvq_backoffice.estructuraisspolview where 1=1--fecha_transaccion between '20240101' and '20240803' and oper=0
and tipo_instrumento=23 and fon_id=849 and oper=0
*/
--select * from bvq_administracion.emisor where emi_nombre like '%montecr%'