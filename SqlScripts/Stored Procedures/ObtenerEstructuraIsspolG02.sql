alter PROCEDURE [BVQ_BACKOFFICE].[ObtenerEstructuraIsspolG02]
		@fecha DateTime,
		@i_todos_los_vigentes bit=0,
		@i_lga_id int
	AS
BEGIN
		SET NOCOUNT ON;
		declare @i_fechaIni DateTime=DATEADD(month, DATEDIFF(month, 0, @fecha), 0);
	delete from corteslist
	insert into corteslist
	values(@fecha,1)

	exec bvq_backoffice.GenerarCompraVentaFlujo
	--GenCortesListByRange
	delete from corteslist
	;with a as(select @i_fechaIni i, num=1 union all select dateadd(d,1,a.i),num+1 from a where a.i<@fecha)
	insert into corteslist(c,cortenum)
	select i,num from a
	option(maxrecursion 0)
	--end GenCortesListByRange
	exec BVQ_BACKOFFICE.GenerarValoracionSB

	select
	tiv_tipo_renta
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
	,Valor_Accion
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
	--order by aru_opc_via,2
END
