alter PROCEDURE BVQ_BACKOFFICE.ObtenerEstructuraIsspolG03
--declare
	@i_fechaCorte DateTime='20251130',
	@i_todos_los_vigentes bit=1,
	@i_lga_id int
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;
	declare @i_fechaIni DateTime=DATEADD(month, DATEDIFF(month, 0, @i_fechaCorte), 0);
	
	if 1=1
	begin
		exec bvq_backoffice.ObtenerDetallePortafolioConLiquidez 1,@i_fechaIni,@i_fechaCorte,null
		exec dropifexists '_temp.TempEstructuraIsspolViewG3'
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
		,Calificadora_Riesgo_Emision=iif(isnull(sbc.codigo,30)=30,0,isnull(Calificadora_Riesgo_Emision,0))
		,Calificacion_Riesgo_Emision=isnull(sbc.codigo,30)
		,Numero_Acciones


		,Valor_AccionHoy=case when Tipo_Instrumento in (20,21,22,24) then Precio_Mercado end
		,Precio_Mercado=case when tiv_tipo_renta=154 then 0 else Precio_Mercado end
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
		
		,Valor_Deteriorado=null
		,No_Acciones=Numero_Acciones
		,Yield
		,Valor_Capital=isnull(valor_pago_capital,0)
		,Valor_Pago_Cupon=isnull(valor_pago_cupon,0)
		,Fecha_Ultimo_Pago=iif(Fecha_Ultimo_Pago is not null, convert(date,@i_fechaCorte), null)
		,Saldo_Valor_Nominal=isnull(Saldo_Valor_Nominal,0)
		,Calificadora_Riesgo=Calificadora_Riesgo_Emision
		,Calificacion_Riesgo=sbc.codigo
		,Fecha_Ultima_Calificacion
		,Pago_dividendo_en_acciones=isnull(Pago_dividendo_en_acciones,0)
		,Pago_dividendo_efectivo=isnull(Pago_dividendo_efectivo,0)
		,tiv_tipo_renta
		,TVS_DESCRIPCION
		,INTERES_GANADO_2
		,tiv_tipo_base
		,tvl_descripcion
		,latest_inicio=Fecha_ultimo_pago
		,INTERES_GANADO
		,Fecha_Ultimo_Pago_Capital
		,Saldo_Provision=null
		into _temp.TempEstructuraIsspolViewG3

		--declare @i_fechaCorte datetime='2023-12-31T23:59:59'
		--declare @i_fechaIni DateTime=DATEADD(month, DATEDIFF(month, 0, @i_fechaCorte), 0);
		--select 1
		--,
		--	 Errores=
		-- case when Tipo_Instrumento not in (4,5,9,13,20,21,22,23,24,26) and isnull(fecha_ultima_calificacion,0)=0 then
		--	'Renta fija privada sin calificación.' else '' end
		-- +case when Tipo_Instrumento not in (20,21,22,23,24,26) and fecha_ultimo_pago is null then
		--	'Renta fija sin fecha de último pago.' else '' end
		from BVQ_BACKOFFICE.EstructuraIsspolView
		left join BVQ_ADMINISTRACION.SB_CALIFICACIONES sbc on sbc.sandp=Calificacion_Riesgo_Emision
		--where oper=0
		where esCxc=0
		and Fecha_transaccion between @i_fechaIni and @i_fechaCorte
		and (
			--@i_todos_los_vigentes=1
			datediff(d,Fecha_transaccion,@i_fechaCorte)=0
			or tipo_transaccion<>'V'--@i_todos_los_vigentes=0
		)
		--order by aru_opc_via,2
	end
	else
	begin
		--se envia null en las dos primeras tablas porque no se llama a ObtenerDetallePortafolioConLiquidez
		select null
		select null
	end




	--declare @i_fechaCorte datetime='20231231'
	declare @msgs table(Errores varchar(max),fon_id int,tipo_transaccion varchar(2))
	insert into @msgs(Errores,fon_id,tipo_transaccion)
	select dbo.stringagg(mensaje,'; '),fon_id,tipo_transaccion
	from _temp.tempEstructuraIsspolViewG3 e cross apply(
		select code=iif(tiv_tipo_renta=153 and tipo_transaccion='P' and (dias_transcurridos<=0 or dias_transcurridos is null),'G04_RF_DIAS_TRANS_MAYOR_CERO',null)
		union all select iif(tiv_tipo_renta=154 and yield is not null,'G04_RV_YIELD_NULO',null)
		union all select iif(tipo_transaccion='P' and datediff(d,Fecha_Ultimo_Pago,@i_fechaCorte)<>0,'G04_FECHA_ULT_CUPON_IGUAL_CORTE',null)
		union all select iif(tipo_transaccion in ('A','V','R','U') and Numero_Liquidacion<>'','G04_NUM_LIQ_BLANCO_TX_AVRU',null)
		union all select iif(tipo_instrumento in (20,21,22,24) and Valor_AccionHoy<=0
			or tipo_instrumento not in (20,21,22,24) and Valor_AccionHoy is not null,'G04_TIPO_INST_20_21_22_24_MAYOR_CERO',null)
		union all select iif(tipo_transaccion in ('V','A','U','P') and (Valor_Capital<>0 or Valor_Capital is null),'G04_TX_VAUP_VALOR_CAPITAL_CERO',null)
		union all select iif(tipo_transaccion in ('V','L','E','R','U','A') and Fecha_Ultimo_Pago is not null,'G04_TX_VLERUA_FECHA_ULT_CUPON_NULA',null)
		union all select iif(tipo_transaccion in ('L','P','R','U','A','E') and (Interes_Acumulado<>0 or Interes_Acumulado is null),'G04_TX_LPRUAE_INTERES_ACUM_CERO',null)
		union all select iif(tipo_transaccion in ('V') and tiv_tipo_renta=153 and not tipo_instrumento in (4,5,8,9)
			and (Interes_Acumulado<>0 or Interes_Acumulado is null),'G04_TX_V_RF_EXC_4_5_8_9_INTERES_CERO',null)
		union all select iif(Tipo_Instrumento not in (4,5,9,13,20,21,22,23,24,26) and isnull(fecha_ultima_calificacion,0)=0,'G04_RF_PRIVADA_SIN_CALIFICACION',null)
		union all select iif(Tipo_Transaccion in ('P') and Tipo_Instrumento not in (20,21,22,23,24,26) and fecha_ultimo_pago is null,'G04_RF_SIN_FECHA_ULTIMO_PAGO',null)
	) s join bvq_backoffice.EstructuraIsspolErrors errs on code=codigo
	group by fon_id,tipo_transaccion

	select
	Errores
	,e.* from _temp.TempEstructuraIsspolViewG3 e
	left join @msgs m on e.fon_id=m.fon_id and e.Tipo_Transaccion=m.tipo_transaccion
	order by FON_ID
END
go

/*
select * from BVQ_BACKOFFICE.EstructuraIsspolView where fecha_transaccion between '20231201' and '20231231' and tipo_transaccion<>'V'
and escxc=0

--select * from _temp.TempEstructuraIsspolViewG3 where tipo_transaccion<>'V'
sp_helptext 'BVQ_BACKOFFICE.ObtenerEstructuraIsspolG03'
*/