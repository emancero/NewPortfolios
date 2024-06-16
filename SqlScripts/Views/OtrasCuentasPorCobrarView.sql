CREATE view bvq_backoffice.OtrasCuentasPorCobrarView as
	SELECT
		TVL_NOMBRE = TVL_NOMBRE
	   ,CUENTA_CONTABLE = CUENTA_CONTABLE
	   ,VECTOR_PRECIO = VECTOR_PRECIO
	   ,TIPO = TIPO
	   ,CUPON = CUPON
	   ,PLAZO_PACTADO = PLAZO_PACTADO
	   ,FECHA_VENCIMIENTO_CONVENIO_PAGO = FECHA_VENCIMIENTO_CONVENIO_PAGO
	   ,FECHA_SUSCRIPCION_CONVENIO_PAGO = FECHA_SUSCRIPCION_CONVENIO_PAGO
	   ,FECHA_VENCIMIENTO_ORIGINAL = FECHA_VENCIMIENTO_ORIGINAL
	   ,DECRETO_EMISOR = DECRETO_EMISOR
	   ,intervinientes = intervinientes
	   ,VALOR_NOMINAL = SUM(VALOR_NOMINAL)
	   ,VALOR_EFECTIVO = SUM(VALOR_EFECTIVO)
	   ,INTERES_TRANSCURRIDO = SUM(INTERES_TRANSCURRIDO)
	   ,PRECIO_DE_HOY = PRECIO_DE_HOY
	   ,INTERES_ACUMULADO = SUM(INTERES_ACUMULADO)
	   ,VALOR_DE_MERCADO = SUM(VALOR_DE_MERCADO)
	   ,PCT_DEL_VALOR_DE_MERCADO = SUM(PCT_DEL_VALOR_DE_MERCADO)
	   ,VENCER = VENCER
	   ,FECHA_VALOR_DE_COMPRA = FECHA_VALOR_DE_COMPRA
	   ,VALOR_EFECTIVO_HISTORICO = SUM(VALOR_EFECTIVO_HISTORICO)
	   ,YIELD = YIELD
	   ,PRECIO = PRECIO
	   ,SECTOR = SECTOR
	   ,MONTO_EMITIDO = MONTO_EMITIDO
	   ,PATRIMONIO = PATRIMONIO
	   ,CALIFICADORA_DE_RIESGO = CALIFICADORA_DE_RIESGO
	   ,CALIFICACION_DE_RIESGO = CALIFICACION_DE_RIESGO
	   ,VALOR_PROVISIONADO = SUM(VALOR_PROVISIONADO)
	   ,FECHA_DE_PAGO_ULTIMO_CUPON = FECHA_DE_PAGO_ULTIMO_CUPON
	   ,DIAS_DE_INTERES_GANADO = DIAS_DE_INTERES_GANADO
	   ,INTERES_GANADO = SUM(INTERES_GANADO)
	   ,INTERES_AL_VENCIMIENTO_ORIGINAL_ = SUM(INTERES_AL_VENCIMIENTO_ORIGINAL_)
	   ,INTERES_POR_DIAS_DE_RETRASO = SUM(INTERES_POR_DIAS_DE_RETRASO)
	   ,PCT_A_AJUSTAR = PCT_A_AJUSTAR
	   ,DIAS_POR_VENCER_A_LA_COMPRA = DIAS_POR_VENCER_A_LA_COMPRA
	   ,PCT_AJUSTE_DIARIO = PCT_AJUSTE_DIARIO
	   ,FACTOR_DE_AJUSTE = FACTOR_DE_AJUSTE
	   ,CONTROLADOR_SECTOR = CONTROLADOR_SECTOR
	   ,CONTROLADOR_POSICION = CONTROLADOR_POSICION
	   ,PRECIO_ULTIMA_COMPRA = PRECIO_ULTIMA_COMPRA
	   ,FECHA_ULTIMA_COMPRA = FECHA_ULTIMA_COMPRA
	   ,BASE_PARA_DIAS_INTERES = BASE_PARA_DIAS_INTERES
	   ,BASE_PARA_TASA_INTERES = BASE_PARA_TASA_INTERES
	   ,VECTOR_PRECIO2 = VECTOR_PRECIO2
	   ,CUPON_VECTOR = CUPON_VECTOR
	   ,CODIGO_TITULO = CODIGO_TITULO
	   ,TIPO_VECTOR = TIPO_VECTOR

	   ,VALORES_RECUPERADOS = SUM(VALORES_RECUPERADOS)
	   ,ACCIONES_REALIZADAS = ACCIONES_REALIZADAS
	   ,MANTIENE_VECTOR_PRECIO = MANTIENE_VECTOR_PRECIO
	   ,ACP_ID = ACP_ID
	   ,PROG = PROG
	   ,FKOP = SUM(FKOP)
	   ,ACTA = ACTA
	   ,GCXC_NOMBRE = GCXC_NOMBRE
	   ,tvl_codigo = tvl_codigo
	   ,ems_nombre = ems_nombre
	   --,TPO_F1 = TPO_F1
	   ,TPO_F1=(case when TPO_DESGLOSAR_F1 = 1 then TPO_F1 end)
	   ,OTROS_COSTOS = sum(OTROS_COSTOS)
	   ,COMISIONES = SUM(COMISIONES)
	   ,TPO_PROG = TPO_PROG
	   ,RECURSOS = RECURSOS
	   ,tiv_valor_nominal = tiv_valor_nominal
	   ,htp_compra = SUM(htp_compra)
	   ,ABONO_INTERES = sum(ABONO_INTERES)
	   ,VALNOM_ANTERIOR = sum(VALNOM_ANTERIOR)
	   ,FECHA_ENCARGO = FECHA_ENCARGO
	   ,DIVIDENDOS_EN_ACCIONES = DIVIDENDOS_EN_ACCIONES
	   ,
		--POR_SIGLAS = dbo.StringAGG(por_siglas, '-')
		por_siglas = (
				SELECT
				STUFF((SELECT
						distinct '-',por_ord+'',por.por_siglas+''
					FROM BVQ_BACKOFFICE.TITULOS_PORTAFOLIO p2
					JOIN BVQ_BACKOFFICE.PORTAFOLIO por
						ON por.por_id = p2.por_id
					WHERE (
						p2.TPO_NUMERACION = s.desglosarB
						and isnull(p2.tpo_f1,-1)=isnull(case when s.TPO_DESGLOSAR_F1 = 1 then s.TPO_F1 end,-1)
						--or p2.TPO_PROG='cxcnomovs' and p2.tpo_f1=s.f1group--s.htp_numeracion
					)
					AND TPO_ESTADO = 352
					ORDER BY por.por_ord+''
					FOR XML PATH (''))
				, 1, 1, ''))
		,s.desglosarb
	    ,s.ems_abr
	    ,s.min_tiene_valnom
	    ,s.tiv_id
	    ,s.tiv_split_de
		,tfcorte
		,s.f1group
		,s.TPO_FECHA_VENCIMIENTO_ANTERIOR
		,DesglosarF1=(case when s.TPO_DESGLOSAR_F1 = 1 then s.TPO_F1 end)
	FROM (SELECT
			TVL_NOMBRE = TVL_DESCRIPCION
		   ,CUENTA_CONTABLE = '7.1.5.90.90'
		   ,VECTOR_PRECIO =
			CASE
				WHEN [TPO_MANTIENE_VECTOR_PRECIO] = 1 OR
					ISNULL([IPR_ES_CXC], 0) = 0 THEN [tiv_codigo_vector]
			END
		   ,TIPO = TVL_DESCRIPCION
		   ,CUPON = case when tiv_subtipo=3 then 0 else [tiv_tasa_interes] / 100.0 end
		   ,PLAZO_PACTADO = dbo.fnDiasEu([fecha_compra], [tiv_fecha_vencimiento], tiv_tipo_base)
		   ,FECHA_VENCIMIENTO_CONVENIO_PAGO = TPO_FECHA_VEN_CONVENIO
		   ,FECHA_SUSCRIPCION_CONVENIO_PAGO = TPO_FECHA_SUSC_CONVENIO
		   ,FECHA_VENCIMIENTO_ORIGINAL = coalesce(
				case when tvl_codigo='SWAP' then
					convert(datetime,'20341228')
				when htp_numeracion not like 'FEC-%' then
					TPO_FECHA_VENCIMIENTO_ANTERIOR
				end
				,tiv_fecha_vencimiento)
		   ,DECRETO_EMISOR = [ems_nombre] + ISNULL('/' + [ACP_NOMBRE], '')
		   ,intervinientes = TPO_INTERVINIENTES
		   ,VALOR_NOMINAL = sal
		   
		   ,VALOR_EFECTIVO =
			CASE
				WHEN valefeConRendimiento is not null then
					valefeConRendimiento
				WHEN [TPO_F1] = (SELECT TOP 1
							kf1
						FROM keyf1
						WHERE natkey LIKE 'MINISTERIO DE FINANZAS|20240620|20160108|%'
						AND kf1 = 339) THEN
							(1954061.2-1567189.4-895.53-3582.15-895.53-3582.15-2985.12-2985.12)/867885 * sal
						--377916.44 / 873855.24 * sal
				WHEN [tvl_codigo] IN ('PCO') THEN sal * [htp_precio_compra] / 100.0
				ELSE sal * [tiv_precio] / 100.0
			END
		   ,INTERES_TRANSCURRIDO =
			   case when
				   tvl_codigo='PACTO'
				   and htp_numeracion not in ('MDF-2018-11-27') --excepciones
			   then
					[TPO_INTERES_TRANSCURRIDO]
			   else 0 end
		   ,PRECIO_DE_HOY =
			CASE
				WHEN tvl_codigo NOT IN ('DER', 'OBL', 'PAG') THEN [tiv_precio] / 100.0
				ELSE NULL
			END
		   ,INTERES_ACUMULADO = [dias_al_corte] *
			CASE
				WHEN [tvl_codigo] IN ('FAC'

					, 'PCO') THEN [HTP_RENDIMIENTO]
				ELSE [tiv_tasa_interes]
			END
		   ,VALOR_DE_MERCADO = valefe
		   ,PCT_DEL_VALOR_DE_MERCADO = [valefe]
		   ,VENCER = DATEDIFF(d, [tfcorte], [tiv_fecha_vencimiento])
		   ,FECHA_VALOR_DE_COMPRA = fecha_compra
		   ,VALOR_EFECTIVO_HISTORICO = ISNULL([TPO_INTERES_TRANSCURRIDO], 0) + ISNULL([TPO_COMISION_BOLSA], 0) + coalesce(valnomCompraAnterior,[htp_compra]) * coalesce(precioCompraAnterior, [htp_precio_compra]) /
			CASE
				WHEN [tiv_tipo_renta] = 153 THEN 100e
				ELSE 1e
			END
		   ,YIELD =
			CASE
				WHEN [tvl_codigo] in ('DER','PAG') THEN NULL
				WHEN [tvl_codigo] IN ('FAC', 'PCO') THEN [HTP_RENDIMIENTO]
				ELSE [tiv_tasa_interes]
			END / 100.0
		   ,PRECIO = htp_precio_compra
		   ,SECTOR =
			CASE [sector_general]
				WHEN 'SEC_PRI_FIN' THEN 'PRIVADO FINANCIERO'
				WHEN 'SEC_PRI_NFIN' THEN 'PRIVADO NO FINANCIERO'
				WHEN 'SEC_PUB_FIN' THEN 'PUBLICO'
				WHEN 'SEC_PUB_NFIN' THEN 'PUBLICO'
			END
		   ,MONTO_EMITIDO = [TIV_MONTO_EMISION]
		   ,PATRIMONIO = [VBA_PATRIMONIO_TECNICO]
		   ,CALIFICADORA_DE_RIESGO = [CAL_NOMBRE]
		   ,CALIFICACION_DE_RIESGO = COALESCE([ENC_VALOR], [TCA_VALOR])
		   ,VALOR_PROVISIONADO = sal * [tiv_precio] / 100.0
		   ,FECHA_DE_PAGO_ULTIMO_CUPON = latest_inicio
		   ,DIAS_DE_INTERES_GANADO =
			CASE
				WHEN tvl_codigo IN

					('FAC', 'PCO') AND
					pc.tiv_tipo_base = 355 AND
					latest_inicio = fecha_compra THEN DATEDIFF(d, tiv_fecha_vencimiento, tfcorte)
				ELSE pc.dias_al_corte
			END
		   ,INTERES_GANADO =
			CASE
				WHEN tvl_codigo IN ('FAC', 'PCO') AND
					pc.tiv_tipo_base = 355 AND
					latest_inicio = fecha_compra THEN DATEDIFF(d, tiv_fecha_vencimiento, tfcorte)
				ELSE pc.dias_al_corte
			END
			*
			CASE
				WHEN [tvl_codigo] IN ('FAC', 'PCO', 'PACTO') THEN (CASE
						WHEN [tvl_codigo] IN ('PCO') THEN sal * [htp_precio_compra] / 100.0
						ELSE pc.valefe
					END +
					CASE
						WHEN TPO_INTERVINIENTES

							LIKE 'Capital Ventura%' THEN TPO_INTERES_TRANSCURRIDO
						ELSE 0
					END)
					* [HTP_RENDIMIENTO] / 100.0 / 360.0
				ELSE (sal - ISNULL(TPO_VALNOM_ANTERIOR, 0))
					* [tiv_tasa_interes]
					/ 100.0 / 360.0
			END
			- ISNULL(TPO_ABONO_INTERES, 0)
			--,INTERES_AL_VENCIMIENTO_ORIGINAL_=CASE WHEN [TPO_FECHA_SUSC_CONVENIO] is not null
			--THEN [sal]*datediff(d,[FECHA_COMPRA],[TIV_FECHA_VENCIMIENTO])/360.0*CASE WHEN [TVL_CODIGO] in ('FAC','PCO') THEN 0/*[HTP_RENDIMIENTO]*/ ELSE [TIV_TASA_INTERES] END/100.0 END
			--,INTERES_POR_DIAS_DE_RETRASO=
			--CASE WHEN [TPO_FECHA_SUSC_CONVENIO] is not null THEN sal*[TIV_PRECIO]/100.0*datediff(d,[TIV_FECHA_VENCIMIENTO],[LATEST_INICIO])/360.0*CASE WHEN [TVL_CODIGO] in ('FAC','PCO') THEN [HTP_RENDIMIENTO] ELSE [TIV_TASA_INTERES] END/100.0 END,
		   ,INTERES_AL_VENCIMIENTO_ORIGINAL_ =
			CASE
				WHEN [TPO_FECHA_SUSC_CONVENIO] IS NOT NULL THEN [sal] * DATEDIFF(d, [fecha_compra], [tiv_fecha_vencimiento]) / 360.0 *
					CASE
						WHEN [tvl_codigo] IN ('FAC', 'PCO') THEN 0/*[HTP_RENDIMIENTO]*/
						ELSE [tiv_tasa_interes]
					END / 100.0
				WHEN pc.tiv_emisor = 1000036 THEN (sal * [tiv_precio] / 100.0) * (dbo.fnDiasEu([fecha_compra], [tiv_fecha_vencimiento], tiv_tipo_base)) * ([tiv_tasa_interes] / 100.0) / 360
				WHEN pc.tiv_emisor = 1000042 THEN (CASE
						WHEN tiv_fecha_vencimiento > latest_inicio THEN sal * ([tiv_tasa_interes] / 100.0) * DATEDIFF(DAY, latest_inicio, tiv_fecha_vencimiento) / 360 --DATEDIFF(DAY, tiv_fecha_vencimiento, latest_inicio) / 360
					END)
			END
		   ,INTERES_POR_DIAS_DE_RETRASO =

			CASE
				WHEN [TPO_FECHA_SUSC_CONVENIO] IS NOT NULL THEN sal * [tiv_precio] / 100.0 * DATEDIFF(d, [tiv_fecha_vencimiento], [latest_inicio]) / 360.0 *
					CASE
						WHEN [tvl_codigo] IN ('FAC', 'PCO') THEN [HTP_RENDIMIENTO]
						ELSE [tiv_tasa_interes]
					END / 100.0

				--WHEN pc.tiv_emisor = 1000036 THEN -1
				WHEN pc.tiv_emisor = 1000042 THEN sal * ([tiv_tasa_interes] / 100.0) * DATEDIFF(DAY, latest_inicio, '20221005') / 360 --DATEDIFF(DAY, tiv_fecha_vencimiento, latest_inicio) / 360
			END
		   ,PCT_A_AJUSTAR =
			CASE
				WHEN tvl_codigo NOT IN ('DER', 'OBL', 'PAG') THEN 1 - [TPO_PRECIO_ULTIMA_COMPRA]
				ELSE NULL
			END
		   ,DIAS_POR_VENCER_A_LA_COMPRA =
			CASE
				WHEN tvl_codigo NOT IN ('DER', 'OBL', 'PAG') THEN DATEDIFF(d, [fecha_compra], [tiv_fecha_vencimiento])
				ELSE NULL
			END
		   ,PCT_AJUSTE_DIARIO =
			CASE
				WHEN tvl_codigo NOT IN ('DER', 'OBL', 'PAG') THEN (1 - [TPO_PRECIO_ULTIMA_COMPRA]) / DATEDIFF(d, [fecha_compra], [tiv_fecha_vencimiento])
				ELSE NULL
			END
		   ,FACTOR_DE_AJUSTE =
			CASE
				WHEN tvl_codigo NOT IN ('DER', 'OBL', 'PAG') THEN (1 - [TPO_PRECIO_ULTIMA_COMPRA]) / DATEDIFF(d, [fecha_compra], [tiv_fecha_vencimiento]) * DATEDIFF(d, [fecha_compra], [tfcorte])
				ELSE NULL
			END
		   ,CONTROLADOR_SECTOR =
			CASE
				WHEN [sector_general] = 'SEC_PRI_FIN' THEN 1
				WHEN [sector_general] = 'SEC_PRI_NFIN' THEN 2
				WHEN [sector_general] IN ('SEC_PUB_FIN', 'SEC_PUB_NFIN') THEN 3
				ELSE 0
			END
		   ,CONTROLADOR_POSICION =
			CASE
				WHEN DATEDIFF(d, [tfcorte], [tiv_fecha_vencimiento]) IS NULL THEN 0
				WHEN DATEDIFF(d, [tfcorte], [tiv_fecha_vencimiento]) < 366 THEN 1
				WHEN DATEDIFF(d, [tfcorte], [tiv_fecha_vencimiento]) < 1096 THEN 2


				WHEN DATEDIFF(d, [tfcorte], [tiv_fecha_vencimiento]) < 1826 THEN 3
				WHEN DATEDIFF(d, [tfcorte], [tiv_fecha_vencimiento]) < 3651 THEN 4
				ELSE 5
			END
		   ,PRECIO_ULTIMA_COMPRA = TPO_PRECIO_ULTIMA_COMPRA
		   ,FECHA_ULTIMA_COMPRA =
			CASE WHEN tvl_codigo NOT IN ('DER', 'OBL', 'PAG') or TPO_MANTIENE_VECTOR_PRECIO = 1 THEN [fecha_compra] END
			--,FECHA_ULTIMA_COMPRA=
			--   case when isnull(rtrim(tiv_codigo_vector),'')<>'' and datediff(d,@i_fechaCorte,tiv_fecha_vencimiento)<=365 then
			--	lastValDate
			--   when isnull(rtrim(tiv_codigo_vector),'')='' then [fecha_compra]
			--   when isnull(rtrim(tiv_codigo_vector),'')<>'' and datediff(d,@i_fechaCorte,tiv_fecha_vencimiento)>365 then
			--	tfcorte
			--   end
		   ,BASE_PARA_DIAS_INTERES =
			CASE
				WHEN
					[tiv_tipo_base] = 354 OR
					[IPR_ES_CXC] = 0 AND
					[tvl_codigo] NOT IN ('PCO') THEN '360'
				WHEN [tiv_tipo_base] = 355 THEN 'REAL'
				ELSE ''
			END
			
		   ,BASE_PARA_TASA_INTERES = 360
		   ,VECTOR_PRECIO2 =
			CASE
				WHEN TPO_MANTIENE_VECTOR_PRECIO = 1 OR
					tiv_codigo_vector <> '' THEN [tiv_precio] / 100.0
			END
		   ,CUPON_VECTOR = TPO_CUPON_VECTOR
		   ,CODIGO_TITULO = [TPO_CODIGO_VECTOR]
		   ,TIPO_VECTOR =
			CASE
				WHEN TPO_MANTIENE_VECTOR_PRECIO = 1 OR
					tiv_codigo_vector <> '' THEN [tvl_codigo] + ' ' +
					CASE
						WHEN [tvl_codigo] = 'swap' THEN [TPO_ACTA]
						ELSE [TIV_CLASE]
					END
			END
		   ,VALORES_RECUPERADOS = [htp_compra] - [sal]
		   ,ACCIONES_REALIZADAS = [TPO_OBJETO]
		   ,MANTIENE_VECTOR_PRECIO = TPO_MANTIENE_VECTOR_PRECIO
		   ,ACP_ID = ACP_ID
		   ,PROG = TPO_PROG
		   ,FKOP = TPO_FKOP
		   ,ACTA = TPO_ACTA
		   ,GCXC_NOMBRE = [GCXC_NOMBRE]
		   ,tvl_codigo = [tvl_codigo]
		   ,ems_nombre = [ems_nombre]
		   ,TPO_F1 = [TPO_F1]
		   ,OTROS_COSTOS = TPO_OTROS_COSTOS
		   ,COMISIONES = TPO_COMISION_BOLSA
		   ,TPO_PROG = [TPO_PROG]
		   ,RECURSOS = [TPO_RECURSOS]
		   ,tiv_valor_nominal = [tiv_valor_nominal]
		   ,htp_compra = [htp_compra]
		   ,ABONO_INTERES = TPO_ABONO_INTERES
		   ,VALNOM_ANTERIOR = TPO_VALNOM_ANTERIOR
		   ,FECHA_ENCARGO = TPO_FECHA_ENCARGO
		   ,DIVIDENDOS_EN_ACCIONES =
			CASE
				WHEN ems_nombre = 'RETRATOREC S.A.' AND
					fecha_compra = '20170331' THEN sal
			END
		   ,
			--por_siglas = pc.por_siglas, 
			port.por_ord AS orden
		   ,pc.htp_numeracion
		   ,pc.TPO_DESGLOSAR_F1
		   ,desglosarB=(case when TPO_DESGLOSAR_F1 = 1 then pc.htp_numeracion end)
		   ,f1Group=case when tpo_prog='cxcnomovs' and tpo_f1 in (337,338) then TPO_F1 end
		   ,pc.ems_abr
		   ,pc.min_tiene_valnom
		   ,pc.tiv_id
		   ,pc.tiv_split_de
		   ,tfcorte
		   ,pc.TPO_FECHA_VENCIMIENTO_ANTERIOR
		FROM BVQ_BACKOFFICE.PortafolioCorte pc
		JOIN BVQ_BACKOFFICE.PORTAFOLIO port
			ON pc.por_id = port.POR_ID
		WHERE sal > 0
		AND IPR_ES_CXC = ISNULL(1, '0')
		AND tiv_tipo_renta = 153
	--ORDER BY TVL_CODIGO,EMS_NOMBRE,TIV_FECHA_VENCIMIENTO
	) s
	GROUP BY
			TVL_NOMBRE
			,CUENTA_CONTABLE
			,VECTOR_PRECIO
			,TIPO
			,CUPON
			,PLAZO_PACTADO
			,FECHA_VENCIMIENTO_CONVENIO_PAGO
			,FECHA_SUSCRIPCION_CONVENIO_PAGO
			,FECHA_VENCIMIENTO_ORIGINAL
			,DECRETO_EMISOR
			,intervinientes
			,PRECIO_DE_HOY
			,VENCER
			,FECHA_VALOR_DE_COMPRA
			,YIELD
			,PRECIO
			,SECTOR
			,MONTO_EMITIDO
			,PATRIMONIO
			,CALIFICADORA_DE_RIESGO
			,CALIFICACION_DE_RIESGO
			,FECHA_DE_PAGO_ULTIMO_CUPON
			,DIAS_DE_INTERES_GANADO
			,PCT_A_AJUSTAR
			,DIAS_POR_VENCER_A_LA_COMPRA
			,PCT_AJUSTE_DIARIO
			,FACTOR_DE_AJUSTE
			,CONTROLADOR_SECTOR
			,CONTROLADOR_POSICION
			,PRECIO_ULTIMA_COMPRA
			,FECHA_ULTIMA_COMPRA
			,BASE_PARA_DIAS_INTERES
			,BASE_PARA_TASA_INTERES
			,VECTOR_PRECIO2
			,CUPON_VECTOR
			,CODIGO_TITULO
			,TIPO_VECTOR
			,ACCIONES_REALIZADAS
			,MANTIENE_VECTOR_PRECIO
			,ACP_ID
			,PROG
			,ACTA
			,GCXC_NOMBRE
			,tvl_codigo
			,ems_nombre
			--,TPO_F1
			,(case when TPO_DESGLOSAR_F1 = 1 then TPO_F1 end)
			--,OTROS_COSTOS
			,TPO_PROG
			,RECURSOS
			,tiv_valor_nominal
			--,ABONO_INTERES
			--,VALNOM_ANTERIOR
			,FECHA_ENCARGO
			,DIVIDENDOS_EN_ACCIONES
			--,htp_numeracion--(case when TPO_DESGLOSAR_F1 = 1 then htp_numeracion end)
			,desglosarB--(case when TPO_DESGLOSAR_F1 = 1 then s.htp_numeracion end)--
			,f1group
		    ,s.ems_abr
		    ,s.min_tiene_valnom
		    ,s.tiv_id
		    ,s.tiv_split_de
			,s.tfcorte
			,s.TPO_FECHA_VENCIMIENTO_ANTERIOR
	HAVING SUM(VALOR_NOMINAL)>=1
