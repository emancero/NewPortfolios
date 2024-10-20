create procedure bvq_backoffice.ObtenerDetallePortafolioConValoresIniciales
	 @i_idPortfolio		int				--Identificador del portafolio
	,@i_fechaIni		datetime
	,@i_fechaFin		datetime
	,@i_client_id		int
	,@i_public			bit=0
	,@i_lga_id			int=null
as
begin
	exec bvq_backoffice.ObtenerDetallePortafolioConLiquidez
	 @i_idPortfolio=@i_idPortfolio
	,@i_fechaIni=@i_fechaIni
	,@i_fechaFin=@i_fechaFin
	,@i_client_id=@i_client_id
	,@i_public=@i_public
	,@i_mostrar=0
	,@i_lga_id=@i_lga_id


	select
	amount0,amountCosto,intacc,prov,fechaIni,prop,pr,orgIAmortizacion,oper,htp_id,es_vencimiento_interes,fecha,montoOper,vep_valor_efectivo,en_liquidez,por_id,saldo_liquidez,saldo_liquidez2,voucher_exists,lip_cliente_id,htp_tpo_id,fecha_compra,liq_compra,htp_fecha_operacion,tasa_cupon,porv_retencion,iAmortizacion,nombre,por_codigo,liquidez_descripcion,ems_nombre,grc_codigo,tvl_codigo,tiv_fecha_vencimiento,tiv_tipo_valor,tpo_numeracion,htp_numeracion_clean,por_tipo,tpo_categoria,vep_id,vep_fecha,vep_cta_id,vep_other_account,amount,account,vep_renovacion,ttl_id,vep_observaciones,ttl_nombre,lip_retencion,com_id,lip_documento,cliente_nombre,evp_id,en_espera,liq_retencion,tvl_nombre,liq_numero_bolsa,liq_ret_bolsa,liq_ret_casa,ret_codigo,valefeoper,liq_total_interes,liq_comision_casa,liq_comision_bolsa,aplica_retencion,com_numero_comprobante,por_public,TIV_ID,dias_cupon,TIV_FECHA_EMISION,TFL_FECHA_INICIO,TFL_FECHA_INICIO_ORIG,EVP_AJUSTE_PROVISION,TPO_FECHA_INGRESO,TPO_RECURSOS,TIV_SERIE,TIV_NUMERO_EMISION_SEB,TIV_FRECUENCIA,IPR_ES_CXC,fecha_original,htp_comision_bolsa,prEfectivo,EVP_AJUSTE_VALOR_EFECTIVO,tiv_tipo_base,saldo,tiv_interes_irregular,tfl_interes,provision,itrans,evp_referencia,UFO_USO_FONDOS,UFO_RENDIMIENTO,TPO_BOLETIN,TPO_FECHA_COMPRA_ANTERIOR,TPO_PRECIO_COMPRA_ANTERIOR,TPO_FECHA_VENCIMIENTO_ANTERIOR,TPO_TABLA_AMORTIZACION,originalProvision,TFL_PERIODO,evp_abono,FON_ID,TIV_SUBTIPO,HTP_TIENE_VALNOM,specialValnom,TIPO_RENTA,EVP_COSTAS_JUDICIALES,EVP_COSTAS_JUDICIALES_REFERENCIA,diasTran,diasInteres,descAm,htp_compra,hist_fecha_compra,hist_precio_compra,comisiones,por_ord,precio_efectivo,tiv_tipo_renta,plazo,capMonto,plazo_anterior,prov2
	,(iAmortizacion+amount) AS 'total_cuota'
	from bvq_backoffice.liqintprov
	where fecha between @i_fechaIni and @i_fechaFin
	and (abs(round(amount,2))>0.05e or oper=2)

end
