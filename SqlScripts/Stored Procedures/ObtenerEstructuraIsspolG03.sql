create PROCEDURE BVQ_BACKOFFICE.ObtenerEstructuraIsspolG03
--declare
	@i_fechaCorte DateTime='20251130',
	@i_lga_id int
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;
	declare @i_fechaIni DateTime=DATEADD(month, DATEDIFF(month, 0, @i_fechaCorte), 0);


	exec bvq_backoffice.ObtenerDetallePortafolioConLiquidez 1,@i_fechaIni,@i_fechaCorte,null
	select
	 EMS_NOMBRE
	,FON_ID
	,Interes_Acumulado
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
	,Valor_AccionHoy=Precio_Mercado--Valor_Accion
	,Precio_Mercado
	,Valor_Mercado=isnull(Valor_Mercado,0)
	,Fecha_Precio_Mercado
	,Fondo_Inversion
	,Periodo_Amortizacion_codigo
	,Periodo_Amortizacion
	,Periodicidad_Cupon_codigo
	,Periodicidad_Cupon
	,Casa_de_Valores_codigo
	,Casa_Valores
	,Tipo_Id_Custodio
	,Documento_Aprobacion=replace(numero_resolucion,'-','')
	,Resolucion_Decreto=replace(Resolucion_Decreto,'-','')
	,Nro_de_Inscripcion_Decreto
	,Inscripcion_CPMV
	,Id_Custodio
	,Numero_Liquidacion
	,Tipo_Transaccion
	,Fecha_Transaccion
	,Dias_Transcurridos=isnull(Dias_Transcurridos,0)
	,Fuente_Cotizacion
	,Dias_Vencer=isnull(Dias_por_vencer,0)
	,No_Acciones=Numero_Acciones
	,Yield
	,Valor_Capital=isnull(valor_pago_capital,0)
	,Valor_Pago_Cupon=isnull(valor_pago_cupon,0)
	,Fecha_Ultimo_Pago
	,Saldo_Valor_Nominal=isnull(Saldo_Valor_Nominal,0)
	,Calificadora_Riesgo=Calificadora_Riesgo_Emision
	,Calificacion_Riesgo=sbc.codigo
	,Fecha_Ultima_Calificacion
	,Pago_dividendo_en_acciones=isnull(Pago_dividendo_en_acciones,0)
	,Pago_dividendo_efectivo=isnull(Pago_dividendo_efectivo,0)
	,tiv_tipo_renta
	from BVQ_BACKOFFICE.EstructuraIsspolView
	left join BVQ_ADMINISTRACION.SB_CALIFICACIONES sbc on sbc.sandp=Calificacion_Riesgo_Emision
	--where oper=0
	where esCxc=0
	and Fecha_transaccion between @i_fechaIni and @i_fechaCorte
	--order by aru_opc_via,2
END