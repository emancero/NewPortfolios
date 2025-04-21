create view bvq_backoffice.PortafolioCortePrcInt as
select
tva_valor_tasa,arranqueValLineal,tvl_codigo,tvl_generico,tiv_fecha_emision,tiv_fecha_vencimiento,tiv_tipo_tasa,tfl_id,latest_inicio,dias_al_corte,ems_nombre,pais,sector_general,pcorte.tiv_id,tiv_codigo,tiv_tipo_valor,tiv_emisor,tiv_tipo_renta,tiv_valor_nominal,tiv_tipo_base,tiv_tasa_margen,htp_numeracion,sal,sal2,salSinCupon,por_id,snum,tfcorte,cortenum,httpo_id,vsicav_id,por_tipo,por_nombre,accrual,ult_fecha_interes,ult_accrual,tiv_preciobk,tiv_precio,prHRT,prVPR,prVPRlineal,prHTP,hrt_precio_vector,vpr_precio,htp_precio_compra,valefe,valEfeOper,iAmortizacion,amortizacion,itrans,tiv_tasa_interes,fecha_compra,lastvalDate,htp_compra,liq_rendimiento,pond_rendimiento,acc,ctc_id,por_codigo,por_siglas,tpo_tipo_valoracion,tpo_categoria,f,prox_capital,prox_interes,prVpr00,max_fecha_compra,max_precio_compra,tpo_custodio,civ_siglas,civ_descripcion,civ_prefijo_cuenta,bde_cta_nombre,bde_cta_descripcion,max_interes,max_comision_bolsa,max_comision_casa,vpr_duracion_efectiva_anual,vpr_duracion_modificada_anual,ems_codigo_sic2,precio_sin_redondear,costo_amortizado,liq_bolsa,liq_numero_bolsa,pond_precio_compra,sum_ve,prf_descripcion,vpr_tasa_descuento,vpr_tasa_referencia,vpr_rendimiento_equivalente,grp_id,tpo_cobro_cupon,ult_liq_id,IPR_NOMBRE_PROG,IPR_ES_CXC,ACP_ID,ACP_NOMBRE,CAL_NOMBRE,ENC_VALOR,HTP_RENDIMIENTO,TCA_VALOR,TIV_CLASE,tiv_codigo_vector,TIV_MONTO_EMISION,TPO_CUPON_VECTOR,TPO_FECHA_SUSC_CONVENIO,TPO_FECHA_VEN_CONVENIO,TPO_FKOP,TPO_INTERVINIENTES,TPO_MANTIENE_VECTOR_PRECIO,TPO_OBJETO,TPO_PRECIO_ULTIMA_COMPRA,TPO_PROG,TPO_ACTA,VBA_PATRIMONIO_TECNICO,TVL_DESCRIPCION,GCXC_NOMBRE,TPO_F1,TPO_CODIGO_VECTOR,TPO_INTERES_TRANSCURRIDO,TPO_OTROS_COSTOS,TPO_COMISIONES,TPO_RECURSOS,TPO_ABONO_INTERES,TPO_VALNOM_ANTERIOR,TPO_FECHA_ENCARGO,asi_emi_codemi,TPO_ORD,TPO_COMISION_BOLSA,TPO_DIVIDENDOS_EN_ACCIONES,TIV_SERIE,TPO_PRECIO_REGISTRO_VALOR_EFECTIVO,TPO_DESGLOSAR_F1,tfl_fecha_inicio_orig2,tiv_split_de,TPO_TABLA_AMORTIZACION,TIV_CODIGO_TITULO_SIC,salNewValNom,valnomCompraAnterior,precioCompraAnterior,UFO_USO_FONDOS,UFO_RENDIMIENTO,valefeConRendimiento,tiv_subtipo,MIN_TIENE_VALNOM,ems_abr,TIV_NUMERO_TRAMO_SICAV,fecha_ultima_compra,prEfectivo,TPO_FECHA_VENCIMIENTO_ANTERIOR,fechaInicioOriginal,totalUfoUsoFondos,totalUfoRendimiento,TPO_FECHA_COMPRA_ANTERIOR,TPO_PRECIO_COMPRA_ANTERIOR,TPO_FECHA_CORTE_OBLIGACION,TPO_AJUSTE_DIAS_DE_INTERES_GANADO,interesCoactivo,TPO_FECHA_LIQUIDACION_OBLIGACION,TPO_NOMBRE_BONO_GLOBAL,SECTOR_DETALLADO
,VALOR_UNITARIO=case when tiv_tipo_renta=154 then coalesce(VNU.VNU_VALOR,pcorte.tiv_valor_nominal) else 1 end
                                               ,VALOR_NOMINAL=
                                                    case when pcorte.tvl_codigo='FI'
                                                        then sal*htp_precio_compra
                                                    else
                                                        sal*
                                                        case when tiv_tipo_renta=154 then coalesce(VNU.VNU_VALOR,pcorte.tiv_valor_nominal)
                                                        else 1 end
                                                    end

                                                ,PRECIO_DE_HOY=
													case when pcorte.tiv_tipo_renta=154 then pcorte.tiv_precio else
														iif(
															case
															when [TPO_MANTIENE_VECTOR_PRECIO]=1 or
															isnull([IPR_ES_CXC],0)=0 
															or pcorte.tvl_codigo in ('SWAP') then rtrim([TIV_CODIGO_VECTOR]) end<>''
															,
															case when TPO_MANTIENE_VECTOR_PRECIO=1 OR tiv_codigo_vector<>'' then [tiv_precio]/100.0 end
															,
															pcorte.htp_precio_compra/100.0
														)+
														datediff(d,fecha_ultima_compra,tfcorte)
														* (
															1.0-
															iif(
																case
																when [TPO_MANTIENE_VECTOR_PRECIO]=1 or isnull([IPR_ES_CXC],0)=0 
																or pcorte.tvl_codigo in ('SWAP') then rtrim([TIV_CODIGO_VECTOR]) end<>''
																,
																case when TPO_MANTIENE_VECTOR_PRECIO=1 OR tiv_codigo_vector<>'' then [tiv_precio]/100.0 end
																,
																pcorte.htp_precio_compra/100.0
															)
														)
														/
														datediff(d,fecha_ultima_compra,tiv_fecha_vencimiento)
													end
                              ,INTERES_GANADO=isnull(
													case
													when pcorte.tvl_codigo in
                                                      ('FAC','PCO') and
                                                            pcorte.tiv_tipo_base=355 and
                                                            latest_inicio=pcorte.fecha_compra and pcorte.ipr_es_cxc=1 then datediff(d,pcorte.tiv_fecha_vencimiento,pcorte.tfcorte)
                                                        else pcorte.dias_al_corte
                                                    end
		                                            /360.0e0 * pcorte.sal * pcorte.tiv_tasa_interes/100.0
												,0)
from bvq_backoffice.portafoliocorte pcorte
left join BVQ_BACKOFFICE.VALOR_NOMINAL_UNITARIO VNU ON VNU.TIV_ID=pcorte.TIV_ID and pcorte.tfcorte>=VNU.VNU_FECHA_INICIO and pcorte.tfcorte<VNU.VNU_FECHA_FIN
