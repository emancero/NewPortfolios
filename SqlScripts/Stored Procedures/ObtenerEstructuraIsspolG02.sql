alter PROCEDURE [BVQ_BACKOFFICE].[ObtenerEstructuraIsspolG02]
--declare
		@fecha DateTime='20240831',
		@i_todos_los_vigentes bit=0,
		@i_lga_id int=null
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET NOCOUNT ON;
		declare @i_fechaIni DateTime=DATEADD(month, DATEDIFF(month, 0, @fecha), 0);
	delete from corteslist
	insert into corteslist
	values(@fecha,1)

	
	--declare @sysver bigint = isnull((select min(CTT_ULTIMA_VERSION) from BVQ_ADMINISTRACION.CT_TABLES),0)
	--if 1=1 or exists(
	--	select 1 from changetable(changes bvq_backoffice.HISTORICO_TITULOS_PORTAFOLIO,@sysver) ct
	--	union all select 1 from changetable(changes bvq_backoffice.TITULOS_PORTAFOLIO,@sysver) ct
	--)
	begin
		--update bvq_administracion.ct_tables set ctt_ultima_version=change_tracking_current_version()
		exec bvq_backoffice.GenerarCompraVentaFlujo

		--GenCortesListByRange
		delete from corteslist
		;with a as(select @i_fechaIni i, num=1 union all select dateadd(d,1,a.i),num+1 from a where a.i<@fecha)
		insert into corteslist(c,cortenum)
		select i,num from a
		option(maxrecursion 0)
		--end GenCortesListByRange
		exec BVQ_ADMINISTRACION.GenerarVectores
		exec bvq_administracion.PrepararValoracionLinealCache
		exec BVQ_BACKOFFICE.GenerarValoracionSB
	end

	if @i_todos_los_vigentes=0
		select
		 EMS_NOMBRE
		,FON_ID
		,tiv_tipo_renta
		,Vector_Precio
		,Fecha_Vencimiento
		,Fecha_Compra
		,TIPO_ID_EMISOR
		,ID_EMISOR
		,Codigo_Instrumento
		,Tipo_Instrumento
		,id_Instrumento
		,Bolsa_Valores
		,Fecha_Emision
		,Tipo_Tasa
		,Base_Tasa_Interes
		,Tasa_Nominal
	
		,Valor_Nominal
		,Precio_Compra
		,Valor_Efectivo_Libros
		,Plazo_Inicial=isnull(Plazo_Inicial,0)
		,Calificadora_Riesgo_Emision
		,Calificacion_Riesgo_Emision=sbc.codigo
		,Fecha_Ultima_Calificacion
		,Numero_Acciones
		,Valor_Accion=Precio_Mercado
		,Precio_Mercado
	
		,Fecha_Precio_Mercado
		,Fondo_Inversion
		,Periodo_Amortizacion_codigo
		,Periodo_Amortizacion
		,Periodicidad_Cupon_codigo
		,Periodicidad_Cupon
		,Casa_de_Valores_codigo
		,Casa_Valores
		,Tipo_Id_Custodio
	
		,Documento_Aprobacion=numero_resolucion
		,Resolucion_Decreto
		,Nro_de_Inscripcion_Decreto
		,Inscripcion_CPMV
		,Id_Custodio
		,Numero_liquidacion
		,Tipo_transaccion
		,Fecha_transaccion
		,Dias_transcurridos
		,Dias_por_vencer
		,Yield
		from BVQ_BACKOFFICE.EstructuraIsspolView
		left join BVQ_ADMINISTRACION.SB_CALIFICACIONES sbc on sbc.sandp=Calificacion_Riesgo_Emision
		where esCxc=0 and oper=0
		and (
			Fecha_transaccion between @i_fechaIni and @fecha
			or @i_todos_los_vigentes=1
		)
	else
		select
		 EMS_NOMBRE
		,FON_ID
		,tiv_tipo_renta
		,Vector_Precio
		,Fecha_Vencimiento
		,Fecha_Compra
		,TIPO_ID_EMISOR
		,ID_EMISOR
		,Codigo_Instrumento
		,Tipo_Instrumento
		,id_Instrumento
		,Bolsa_Valores
		,Fecha_Emision
		,Tipo_Tasa
		,Base_Tasa_Interes
		,Tasa_Nominal
	
		,Valor_Nominal
		,Precio_Compra
		,Valor_Efectivo_Libros
		,Plazo_Inicial=isnull(Plazo_Inicial,0)
		,Calificadora_Riesgo_Emision
		,Calificacion_Riesgo_Emision=sbc.codigo
		,Fecha_Ultima_Calificacion
		,Numero_Acciones
		,Valor_Accion=Precio_Compra--Precio_Mercado
		,Precio_Mercado=Precio_Compra
	
		,Fecha_Precio_Mercado
		,Fondo_Inversion
		,Periodo_Amortizacion_codigo
		,Periodo_Amortizacion
		,Periodicidad_Cupon_codigo
		,Periodicidad_Cupon
		,Casa_de_Valores_codigo
		,Casa_Valores
		,Tipo_Id_Custodio
	
		,Documento_Aprobacion=numero_resolucion
		,Resolucion_Decreto
		,Nro_de_Inscripcion_Decreto
		,Inscripcion_CPMV
		,Id_Custodio
		,Numero_liquidacion
		,Tipo_transaccion
		,Fecha_transaccion
		,Dias_transcurridos
		,Dias_por_vencer
		,Yield

		from BVQ_BACKOFFICE.EstructuraIsspolView
		left join BVQ_ADMINISTRACION.SB_CALIFICACIONES sbc on sbc.sandp=Calificacion_Riesgo_Emision
		where esCxc=0 and oper=-1
		and datediff(d,fecha_transaccion,@fecha)=0 -- 1 para T-1

END
