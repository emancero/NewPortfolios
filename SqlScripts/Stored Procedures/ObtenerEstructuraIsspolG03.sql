CREATE PROCEDURE BVQ_BACKOFFICE.ObtenerEstructuraIsspolG03
--declare
	@i_fechaCorte DateTime='20251130',
	@i_lga_id int
AS
BEGIN
	SET NOCOUNT ON;
	declare @i_fechaIni DateTime=DATEADD(month, DATEDIFF(month, 0, @i_fechaCorte), 0);

	--GenCortesListByRange
	delete from corteslist
	;with a as(select @i_fechaIni i, num=1 union all select dateadd(d,1,a.i),num+1 from a where a.i<@i_fechaCorte)
	insert into corteslist(c,cortenum)
	select i,num from a
	option(maxrecursion 0)
	--end GenCortesListByRange

	exec BVQ_BACKOFFICE.GenerarValoracionSB
	select
	 Interes_Acumulado
	,Vector_Precio
	,Fecha_Vencimiento
	,Fecha_Compra
	,Tipo_Id_Emisor
	,Id_Emisor
	,Codigo_Instrumento
	,Tipo_Instrumento
	,Id_Instrumento
	,Bolsa_Valores
	,Fecha_Emision
	,Tipo_Tasa
	,Base_Tasa_Interes
	,Tasa_Nominal
	,Valor_Nominal
	,Precio_Compra
	,Valor_Efectivo_Libros
	,Plazo_Inicial
	,Calificadora_Riesgo_Emision
	,Calificacion_Riesgo_Emision
	,Fecha_Ultima_Calificacion
	,Numero_Acciones
	,Valor_AccionHoy=Valor_Accion
	,Precio_Mercado
	,Valor_Mercado
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
	,Numero_Liquidacion
	,Tipo_Transaccion
	,Fecha_Transaccion
	,Dias_Transcurridos
	,Fuente_Cotizacion
	,Dias_Vencer=Dias_por_vencer
	,No_Acciones=Numero_Acciones
	,Yield
	,Valor_Capital=valor_pago_capital
	,Valor_Pago_Cupon=valor_pago_cupon
	,Fecha_Ultimo_Pago
	,Saldo_Valor_Nominal
	,Calificacion_Riesgo=Calificacion_Riesgo_Emision
	,Calificadora_Riesgo=Calificadora_Riesgo_Emision
	,Fecha_Ultima_Calificacion
	,Pago_dividendo_en_acciones
	,Pago_dividendo_efectivo
	,tiv_tipo_renta
	from BVQ_BACKOFFICE.EstructuraIsspolView
	--where oper=0
	where esCxc=0
	and Fecha_transaccion between @i_fechaIni and @i_fechaCorte
	--order by aru_opc_via,2
END