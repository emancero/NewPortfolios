---- =========================================================================
----	Author:			Patricio Villacis
----	Create date:	23/08/2023
----	Description:	Obtiene información de limites ISSPOL
----	History:
---- =========================================================================
create procedure [splimites]	
	  @i_fechaCorte datetime=NULL
	, @i_lga_id int
AS

BEGIN
	SET NOCOUNT ON;

	if(@i_fechaCorte is NULL)
		set @i_fechaCorte=GETDATE()

	declare @v_fechaIni datetime
	declare @v_fecha_patrimonio_tecnico datetime
	declare @v_renta_variable int

	set @v_fechaIni = dateadd(s, -3, DATEADD(dd, 1, DATEDIFF(dd, 0, @i_fechaCorte)))

	select @v_fecha_patrimonio_tecnico=max(vba_fecha_desde) from BVQ_ADMINISTRACION.VARIABLES_BALANCE
	
	select @v_renta_variable=ITC_ID from BVQ_ADMINISTRACION.CatalogoItemCatalogo where cat_codigo='TIPO_RENTA' and ITC_CODIGO='REN_VARIABLE'

	if 1=1 or datediff(d,@i_fechaCorte,(select top 1 c from corteslist))=0 and convert(time,@i_fechaCorte)=convert(time,(select top 1 c from corteslist))
	begin
		print 'invalidate'
		truncate table corteslist
		insert into corteslist select @v_fechaIni,1
		exec bvq_backoffice.GenerarCompraVentaPortafolio
		exec bvq_administracion.GenerarTituloFlujoComun
		exec bvq_administracion.GenerarTasaValorCompact
		exec bvq_backoffice.GenerarCompraVentaFlujo
		exec bvq_backoffice.GenerarTotalesCompraVentaFlujo
		exec bvq_administracion.GenerarVectores
		exec BVQ_ADMINISTRACION.PrepararValoracionLinealCache
		exec bvq_administracion.GenerarEmisionCalificacion
	end

	select	sal
			,accrual
			,tiv_precio
			,valefe
			,httpo_id
			,por_id
			,tmp.ems_nombre
			,ems_sector_desc=sec.ITC_DESCRIPCION
			,ems_tipo_emisor_desc=ems.EMS_TIPO_EMISOR
			,ems_patrimonio_tecnico=vba.VBA_PATRIMONIO_TECNICO
			,EMS_REGION=coalesce(EMS_REGION,CIU_REGION)
			,emical.eca_valor
			,emical.eca_nombre
			,emical.eca_fecha_resolucion
			,TPO_PROG
			,TIV_DECRETO
			,tvl.tvl_codigo
			,tmp.tiv_tipo_renta
			,tpo_acta
			,tvl.tvl_nombre
			,tmp.VALOR_NOMINAL
			,tmp.PRECIO_DE_HOY
			,tmp.INTERES_GANADO_2
			,VALOR_DE_MERCADO =	sal*
				isnull(PRECIO_DE_HOY,1)+isnull(INTERES_GANADO_2*dbo.fnDias3(latest_inicio,@i_fechaCorte,354),0)--,sum(valor_nominal)--isnull(sum(sal*case when tipo_renta='RENTA VARIABLE' then tiv_valor_nominal else 1 end),0)

	into #tmpInversiones
	from bvq_backoffice.portafoliocortePrcInt tmp
		inner join BVQ_ADMINISTRACION.TITULO_VALOR tiv
			on tmp.tiv_id=tiv.TIV_ID
		inner join BVQ_ADMINISTRACION.EMISOR ems 
			on tmp.tiv_emisor=ems.EMS_ID
		left join BVQ_ADMINISTRACION.ITEM_CATALOGO sec
			on ems.EMS_SECTOR=sec.ITC_ID
		inner join BVQ_ADMINISTRACION.TIPO_VALOR tvl 
			on tmp.tiv_tipo_valor=tvl.tvl_id
		left join BVQ_ADMINISTRACION.VARIABLES_BALANCE vba 
			on	ems.EMS_ID=vba.EMS_ID and 
				datediff(dd,@v_fechaIni,VBA_FECHA_DESDE)<0 and
				datediff(dd,@v_fechaIni,VBA_FECHA_HASTA)>0
		left join BVQ_ADMINISTRACION.emisor_origen_tipo eot
			on tmp.tiv_emisor=eot.EMS_ID
		--left join BVQ_ADMINISTRACION.PERSONA_JURIDICA pju
			--on ems.pju_id=pju.pju_id
		left join BVQ_ADMINISTRACION.PjuCiudadPrincipal pciu
			on ems.pju_id=pciu.pju_id
		left join BVQ_ADMINISTRACION.CIUDADES ciu
			on pciu.ciu_id=ciu.ciu_id
		left join (	select 
					row_number() over (partition by emi_id order by eca_fecha_resolucion desc,eca_id desc) r
					,emi_id
					,eca_valor
					,cal_nombre eca_nombre
					,cal_nombre_personalizado eca_nombre_personalizado
					,eca_fecha_resolucion
					from bvq_administracion.emisores_calificacion eca
					join bvq_administracion.calificadoras cal on eca.cal_id=cal.cal_id
					where eca_estado=21 and (eca_fecha_resolucion is null or eca_fecha_resolucion<=@v_fechaIni)
				) emical on (tmp.tvl_generico=1 or tmp.tiv_tipo_valor in (13)) and emical.emi_id=tmp.tiv_emisor and emical.r=1

	where	round(sal,2)>0 and isnull(tmp.ipr_es_cxc,0)=0

	--[+]	Limites por Bancos
	select @v_fecha_patrimonio_tecnico
	--format(@v_fecha_patrimonio_tecnico,'al dd ''de'' MMMM ''de'' yyyy')
	as [FECHA_PATRIMONIO_TECNICO]
	select @v_fechaIni as [MONTO_INVERTIDO_AL],min(eca_fecha_resolucion) as [CALIFICACION_DE_RIESGO_AL]
	from #tmpInversiones where ems_nombre like '%banco%'
	select 
			BANCOS=ems_nombre
			,MONTO_INVERTIDO=ems_monto_invertido
			,CALIFICACION_DE_RIESGO=ems_calificacion
			,PATRIMONIO_SIERRA=case when UPPER(ems_region)='SIERRA' then ems_patrimonio_tecnico else 0 end
			,PATRIMONIO_COSTA=case when UPPER(ems_region)='COSTA' then ems_patrimonio_tecnico else 0 end
			,CUPO_CALIFICADO_PCT=0.05
			,CUPO_CALIFICADO_DOLARES=(isnull(ems_patrimonio_tecnico,0)*0.05)
	from (
			select 
					ems_nombre
					,max(ems_sector_desc) as ems_sector
					,sum(sal) as ems_monto_invertido
					,max(EMS_REGION) as ems_region
					,max(ems_patrimonio_tecnico) as ems_patrimonio_tecnico
					,max(ECA_VALOR) as ems_calificacion
			
			from #tmpInversiones tmp
			where 
				ems_nombre like '%banco%'
			group by ems_nombre ) as T1
	--[+]

	--[+]Limites por Sociedades Financieras
	select --format(@v_fecha_patrimonio_tecnico,'al dd ''de'' MMMM ''de'' yyyy')
	@v_fecha_patrimonio_tecnico
	as [FECHA_PATRIMONIO_TECNICO]
	select @v_fechaIni as [MONTO_INVERTIDO_AL],min(eca_fecha_resolucion) as [CALIFICACION_DE_RIESGO_AL]
	from #tmpInversiones 
	where ems_tipo_emisor_desc like '%financier%'
		and ems_nombre not like '%banco%'
		and ems_nombre not like '%cooperativa%'
	select 
			FINANCIERAS=ems_nombre
			,MONTO_INVERTIDO=ems_monto_invertido
			,CALIFICACION_DE_RIESGO=ems_calificacion
			,PATRIMONIO_SIERRA=case when UPPER(ems_region)='SIERRA' then ems_patrimonio_tecnico else 0 end
			,PATRIMONIO_COSTA=case when UPPER(ems_region)='COSTA' then ems_patrimonio_tecnico else 0 end
			,CUPO_CALIFICADO_PCT=0.05
			,CUPO_CALIFICADO_DOLARES=(isnull(ems_patrimonio_tecnico,0)*0.05)
	from (
			select 
					ems_nombre
					,max(ems_sector_desc) as ems_sector
					,sum(sal) as ems_monto_invertido
					,max(EMS_REGION) as ems_region
					,max(ems_patrimonio_tecnico) as ems_patrimonio_tecnico
					,max(ECA_VALOR) as ems_calificacion
			
			from #tmpInversiones tmp
			where 
				ems_tipo_emisor_desc like '%financier%'
				and ems_nombre not like '%banco%'
				and ems_nombre not like '%cooperativa%'
			group by ems_nombre ) as T1	
	--[+]

	--[+]Limites por Cooperativas
	select --format(@v_fecha_patrimonio_tecnico,'al dd ''de'' MMMM ''de'' yyyy') 
	@v_fecha_patrimonio_tecnico as [FECHA_PATRIMONIO_TECNICO]
	select @v_fechaIni as [MONTO_INVERTIDO_AL],min(eca_fecha_resolucion)  as [CALIFICACION_DE_RIESGO_AL]
	from #tmpInversiones 
	where ems_nombre like '%cooperativa%'
	select 
			COOPERATIVAS=ems_nombre
			,MONTO_INVERTIDO=ems_monto_invertido
			,CALIFICACION_DE_RIESGO=ems_calificacion
			,PATRIMONIO_SIERRA=case when UPPER(ems_region)='SIERRA' then ems_patrimonio_tecnico else 0 end
			,PATRIMONIO_COSTA=case when UPPER(ems_region)='COSTA' then ems_patrimonio_tecnico else 0 end
			,CUPO_CALIFICADO_PCT=0.05
			,CUPO_CALIFICADO_DOLARES=(isnull(ems_patrimonio_tecnico,0)*0.05)
	from (
			select 
					ems_nombre
					,max(ems_sector_desc) as ems_sector
					,sum(sal) as ems_monto_invertido
					,max(EMS_REGION) as ems_region
					,max(ems_patrimonio_tecnico) as ems_patrimonio_tecnico
					,max(ECA_VALOR) as ems_calificacion
			
			from #tmpInversiones tmp
			where ems_nombre like '%cooperativa%'
			group by ems_nombre ) as T1	
	--[+]

	--[+]Limites por Sector Público
	select 
			BONOS=coalesce(tvl_codigo+': '+coalesce(tpo_acta,tiv_decreto),tvl_nombre)
			,MONTO_INVERTIDO=ems_monto_invertido
			,CALIFICACION_DE_RIESGO=ems_calificacion
			,PATRIMONIO_SIERRA=case when UPPER(ems_region)='SIERRA' then ems_patrimonio_tecnico else 0 end
			,PATRIMONIO_COSTA=case when UPPER(ems_region)='COSTA' then ems_patrimonio_tecnico else 0 end
			,CUPO_CALIFICADO_PCT=0.05
			,CUPO_CALIFICADO_DOLARES=(isnull(ems_patrimonio_tecnico,0)*0.05)
	from (
			select 
					replace(replace(nullif(TIV_DECRETO,''),'ACTA',''),'ACT RESOL','') as tiv_decreto
					,max(ems_sector_desc) as ems_sector
					,sum(sal) as ems_monto_invertido
					,max(EMS_REGION) as ems_region
					,max(ems_patrimonio_tecnico) as ems_patrimonio_tecnico
					,max(ECA_VALOR) as ems_calificacion
					,tvl_codigo
					,max(tpo_acta) as tpo_acta
					,tvl_nombre
			from #tmpInversiones tmp
			where ems_tipo_emisor_desc like '%gobierno%central%'--and TPO_PROG='rfMinDist'
			group by TVL_CODIGO,tvl_nombre,TIV_DECRETO ) as T1	
	--[+]

		--[+]Limites por reportos bursátiles
	select 
			REPORTOS_BURSATILES='REEPO '+TVL_CODIGO
			,MONTO_INVERTIDO=ems_monto_invertido
			,CALIFICACION_DE_RIESGO=ems_calificacion
			,PATRIMONIO_SIERRA=case when UPPER(ems_region)='SIERRA' then ems_patrimonio_tecnico else 0 end
			,PATRIMONIO_COSTA=case when UPPER(ems_region)='COSTA' then ems_patrimonio_tecnico else 0 end
			,CUPO_CALIFICADO_PCT=0.05
			,CUPO_CALIFICADO_DOLARES=(isnull(ems_patrimonio_tecnico,0)*0.05)
	from (
			select 
					ems_nombre
					,max(ems_sector_desc) as ems_sector
					,sum(sal) as ems_monto_invertido
					,max(EMS_REGION) as ems_region
					,max(ems_patrimonio_tecnico) as ems_patrimonio_tecnico
					,max(ECA_VALOR) as ems_calificacion
					,TVL_CODIGO
					
			from #tmpInversiones tmp
			where TVL_CODIGO='REP'
			group by ems_nombre,TVL_CODIGO ) as T1	
	--[+]

	--[+]Limites por Titularizaciones
	select 
			TITULARIZACIONES=ems_nombre
			,MONTO_INVERTIDO=ems_monto_invertido
			,CALIFICACION_DE_RIESGO=ems_calificacion
			,PATRIMONIO_SIERRA=case when UPPER(ems_region)='SIERRA' then ems_patrimonio_tecnico else 0 end
			,PATRIMONIO_COSTA=case when UPPER(ems_region)='COSTA' then ems_patrimonio_tecnico else 0 end
			,CUPO_CALIFICADO_PCT=0.05
			,CUPO_CALIFICADO_DOLARES=(isnull(ems_patrimonio_tecnico,0)*0.05)
	from (
			select 
					ems_nombre
					,max(ems_sector_desc) as ems_sector
					,sum(sal) as ems_monto_invertido
					,max(EMS_REGION) as ems_region
					,max(ems_patrimonio_tecnico) as ems_patrimonio_tecnico
					,max(ECA_VALOR) as ems_calificacion
					
			from #tmpInversiones tmp
			where TVL_CODIGO='VCC'
			group by ems_nombre ) as T1	
	--[+]

	--[+]Limites por Obligaciones y Papel Comercial
	select 
			OBLIGACIONES_Y_PAPEL_COMERCIAL=ems_nombre+'-'+tvl_codigo
			,MONTO_INVERTIDO=ems_monto_invertido
			,CALIFICACION_DE_RIESGO=ems_calificacion
			,PATRIMONIO_SIERRA=case when UPPER(ems_region)='SIERRA' then ems_patrimonio_tecnico else 0 end
			,PATRIMONIO_COSTA=case when UPPER(ems_region)='COSTA' then ems_patrimonio_tecnico else 0 end
			,CUPO_CALIFICADO_PCT=0.05
			,CUPO_CALIFICADO_DOLARES=(isnull(ems_patrimonio_tecnico,0)*0.05)
	from (
			select 
					ems_nombre
					,max(ems_sector_desc) as ems_sector
					,sum(sal) as ems_monto_invertido
					,max(EMS_REGION) as ems_region
					,max(ems_patrimonio_tecnico) as ems_patrimonio_tecnico
					,max(ECA_VALOR) as ems_calificacion
					,TVL_CODIGO

			from #tmpInversiones tmp
			where TVL_CODIGO IN ('OBL','PCO')
			group by ems_nombre,TVL_CODIGO ) as T1	
	--[+]

	--[+]Limites por Renta Variable
	select @v_fechaIni as [MONTO_INVERTIDO_AL] 
	select 
			RENTA_VARIABLE=ems_nombre
			,MONTO_INVERTIDO=ems_monto_invertido
	from (
			select 
					ems_nombre
					,sum(VALOR_NOMINAL) as ems_monto_invertido
			
			from #tmpInversiones tmp
			where
				tiv_tipo_renta=@v_renta_variable
			group by ems_nombre ) as T1	
	--[+]

	-- Límites
	select SECTOR, PCT
	from bvq_backoffice.isspol_detalle_limites detlim

	--saldo renta fija
	select VALOR_DE_MERCADO =
	sum(
				sal*
				isnull(PRECIO_DE_HOY,1)+isnull(INTERES_GANADO_2*dbo.fnDias3(latest_inicio,@i_fechaCorte,354),0)--,sum(valor_nominal)--isnull(sum(sal*case when tipo_renta='RENTA VARIABLE' then tiv_valor_nominal else 1 end),0)
	),
	VALOR_NOMINAL = sum(sal)
	from bvq_backoffice.portafoliocortePrcInt tmp
	where	round(sal,2)>0 and isnull(tmp.ipr_es_cxc,0)=0 and tiv_tipo_renta=153


	if object_id('tempdb..#tmpInversiones') is not null
		drop table #tmpInversiones
 end
