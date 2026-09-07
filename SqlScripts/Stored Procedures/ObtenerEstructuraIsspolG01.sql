create PROCEDURE BVQ_BACKOFFICE.ObtenerEstructuraIsspolG01--b
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
	begin
		insert into corteslist
		values(@i_fechaini,2)
		select distinct
		  e.Errores
		, e.ems_id
		, e.vigentes
		--, fecha_transaccion=FECHA_VALOR_DE_COMPRA--.fecha_transaccion
		, e.EMS_NOMBRE
		, e.pju_identificacion
		, e.decreto_emisor
		, e.clasificacion
		, e.tipo_identificacion
		, e.pais
		, e.tipo_emisor
		, patrimonio=coalesce(vba.VBA_PATRIMONIO_TECNICO,0)
		, CCA_SUSCRITO=
			case when cca.CCA_SUSCRITO is not null then cca.CCA_SUSCRITO
			--EMN: De acuerdo a Whatsapp del Isspol del 6 de marzo de 2026, si no tiene capital suscrito
			--y es titularización o cooperativa, se coloca el patrimonio
			when tipo_emisor=4 or EMS_ES_TIT=1 then coalesce(vba.VBA_PATRIMONIO_TECNICO,0)
			else 0 end
		, ECA_VALOR=isnull(eca.ECA_VALOR,30)
		, fecha_desde=eca.fecha_desde
		, CAL_NOMBRE=eca.CAL_NOMBRE
		, Calificacion_Codigo=isnull(eca.Calificacion_Codigo,30)
		, Calificadora_Codigo=isnull(eca.Calificadora_Codigo,0)
		, cca.cca_fecha_desde
		, vba.vba_fecha_desde
		from bvq_backoffice.EmisorEstructuraIsspolView e
		join bvq_backoffice.isspolRentaFijaViewNew i on i.id_emisor=e.ems_id-- and e.fecha_transaccion=i.tfcorte
		outer apply(
				select top 1 EMI_ID, ECA_VALOR, eca.CAL_ID
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
				and ECA.EMI_ID=e.EMS_ID
				and eca_fecha_desde<=@fecha
				order by eca_fecha_desde desc
		) eca


		outer apply (
			select top 1 CCA_SUSCRITO, cca_fecha_desde
			from BVQ_ADMINISTRACION.COMPOSICION_CAPITAL cca --where CCA_ESTADO=21
			where cca.emi_id=e.ems_id
			and cca_fecha_desde<=@fecha
			order by cca_fecha_desde desc
		) cca

		outer apply (
			select top 1 vba_patrimonio_tecnico,vba_fecha_desde
			from bvq_administracion.variables_balance vba
			where  vba.EMS_ID=e.ems_id
			and vba_fecha_desde<=@fecha
			order by vba_fecha_desde desc
		) vba
		left join BVQ_ADMINISTRACION.cambio_de_patrimonio_retrasado cpr
		on cpr.cpr_fecha_reporte=convert(date,@fecha)

		--left join (select max(fecha) f, emiid from #x group by emiid) x on x.emiid=ems.ems_id
		where
		e.vigentes=0
		and (
			i.FECHA_VALOR_DE_COMPRA between @i_fechaIni and @fecha
			or
			eca.fecha_desde between @i_fechaIni and @fecha
			or
			cca.cca_fecha_desde between @i_fechaIni and @fecha
			or
			vba.vba_fecha_desde between @i_fechaIni and @fecha
			--or
			--cpr.cpr_fecha_desde_real between @i_fechaIni and @fecha
		)
	end
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