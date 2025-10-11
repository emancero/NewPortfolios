create view [BVQ_BACKOFFICE].[PortafolioCorte] as
	select
	tva_valor_tasa,
	arranqueValLineal,
	tvl_codigo,
	tvl_generico,
	bvq_administracion.date(tiv_fecha_emision) tiv_fecha_emision,
	bvq_administracion.date(tiv_fecha_vencimiento) tiv_fecha_vencimiento,
	tiv_tipo_tasa,
	tfl.tfl_id,
	--tfl_fecha_inicio,
	--tfl_fecha_vencimiento,
	latest_inicio
	=case when isnull(ipr_es_cxc,0)=0 and ev.tfl_fecha_inicio_orig2 is not null then tfl_fecha_inicio_orig2 else latest_inicio end
	,
	--latest_vencimiento,
	dias_al_corte=
		dbo.fnDias2(
			--latest_inicio
			case when tpo_fecha_susc_convenio is not null then
				fechaInicioOriginal
			when isnull(ipr_es_cxc,0)=0 and ev.tfl_fecha_inicio_orig2 is not null then tfl_fecha_inicio_orig2
			else latest_inicio end
			,c,case when tiv_accrual_365=1 then 355 when tiv_tipo_valor in (5,6,11) then 354 else tiv.tiv_tipo_base end)
		+case when tiv_accrual_365=1 then 1 else 0 end
		+case when (tiv_codigo like 'CEAOBL29%' or htp_numeracion='CEA-2022-12-27-5')
		and datepart(m,latest_inicio)=2
		then 1 else 0 end --porque es 29 de febrero
	,
	ems_nombre,
	pais=coalesce(itcpais.itc_valor,'ECUADOR'),
	sector_general=itcsector.itc_codigo,
	tiv.tiv_id,
	tiv_codigo,
	tiv_tipo_valor,
	tiv_emisor,
	tiv.tiv_tipo_renta,
	tiv_valor_nominal,
	tiv.tiv_tipo_base,
	tiv_tasa_margen,
	htp_numeracion,
	case when abs(round(sal,2))<=0.02 then 0 else round(sal,case when c>='2020-04-01' and tiv_tipo_valor in (17,10000006) then 100 else 2 end) end sal,
	sal sal2,
	salSinCupon,
	htp.por_id,
	htp_numeracion snum,
	htp.c tfcorte,
	htp.cortenum,
	htp.tpo_id httpo_id,
	/*row_number() over (order by c,tpo_id,htp.por_id,tiv.tiv_id,htp_numeracion)*/ 1 vsicav_id,
	por_tipo,
	por_nombre=null,--per.nombre,
 
	accrual=isnull
	(
		round
		(
			case when htp.c<(select tpor_tiempo from bvq_backoffice.tiempos_portafolio where tpor_codigo='ACCRUAL_POR_LATEST_INICIO') then acc else 0 end -- ANTES DE VARIABLE: '2015-12-31T23:57:59', FECHA_CAMBIO '2016-04-30T23:57:59'
			+round(salSinCupon,2) *
			case tiv_tipo_tasa when 365 then tiv_tasa_interes else isnull(tiv_tasa_margen+tva_valor_tasa,0) end
			*(dbo.fnDias(latest_inicio,c,case when tiv_accrual_365=1 then 355 else tiv.tiv_tipo_base end)+case when tiv_accrual_365=1 then 1 else 0 end)
			/(base_denominador*100)
			+
			isnull(
				--AJU_MONTO
				(select sum(AJU_MONTO) from bvq_backoffice.AJUSTES_DE_ACCRUAL where aju_tpo_id=htp.tpo_id and htp.c>=AJU_DATE)
				,0
			)
			,2
		),0
	),
	ult_fecha_interes,
	ult_accrual=isnull
	(
		round
		(
			+round(salSinCupon,2) *
			case tiv_tipo_tasa when 365 then tiv_tasa_interes else isnull(tiv_tasa_margen+tva_valor_tasa,0) end
			*(dbo.fnDias(ult_fecha_interes,c,case when tiv_accrual_365=1 then 355 else tiv.tiv_tipo_base end)+case when tiv_accrual_365=1 then 1 else 0 end)
			/(base_denominador*100),2
		),0
	),
	tiv_preciobk=null,--bvq_administracion.ObtenerUltimoPrecioValoracion2(htp.c, tiv.tiv_id, htp.tpo_id),
	tiv_precio=
		round(
		--start coalesce1
			coalesce(
			--nullif(hrt_precio_vector,0),
				hrt_precio_vector,
				prVpr,
				htp_precio_compra--case when c>='2016-09-30T23:59:59' then max_precio_compra else htp_precio_compra end
			),
			--end coalesce1
			case when tiv.tiv_valora_sin_redondear=1 or tiv.tiv_tipo_valor in (1,17) or exists(select * from bvq_administracion.parametro where par_codigo='VALORA_SIN_REDONDEAR' and par_valor='SI') then 100 else 4 end
		),
	prHRT=
	--nullif(hrt_precio_vector,0),
	hrt_precio_vector,
	prVPR
	,
	prVPRlineal=case when lastValDate is not null then 1 end
	--linear=case when
	--tiv.tiv_tipo_renta=153 and tiv_tipo_valor not in (10,13) and datediff(d,c,tiv_fecha_vencimiento)<=365 and c>='2015-05-01T00:00:00'
	--or (tiv_tipo_valor in (10) and c>='2015-12-31T23:57:59') then 1 else 0 end
	,
	prHTP=htp_precio_compra,
	hrt_precio_vector,
	vpr_precio,
	htp_precio_compra,
	valefe=isnull
	(
		round(
			round(sal,case when c>='2020-04-01' and tiv.tiv_tipo_valor=17 then 100 else 2 end)*
			(
				round(
					--start coalesce1
					coalesce(
						hrt_precio_vector,
						prVpr,
						htp_precio_compra--case when c>=(select tpor_tiempo from bvq_backoffice.tiempos_portafolio where tpor_codigo='MAX_FECHA_COMPRA') then max_precio_compra else htp_precio_compra end -- ANTES DE VARIABLE: '2016-09-30T23:59:59'
					)
					--end coalesce1
					,case when tiv_valora_sin_redondear=1 or tiv.tiv_tipo_valor=17 or exists(select * from bvq_administracion.parametro where par_codigo='VALORA_SIN_REDONDEAR' and par_valor='SI') then 100 else 4 end
				)
				/case when tiv.tiv_tipo_renta=153 then 100e else 1e end
			)
			,100
		),0
	),
 
	valEfeOper,iAmortizacion,amortizacion,itrans,
	tiv_tasa_interes=case tiv_tipo_tasa when 365 then tiv_tasa_interes else isnull(tiv_tasa_margen+tva_valor_tasa,0) end,--bvq_administracion.TasaInteresCase(tiv_tipo_tasa,tiv_tasa_interes,tiv_tasa_margen,tva_valor_tasa)
	fecha_compra,
	lastvalDate,
	htp_compra,
	liq_rendimiento,
	pond_rendimiento,
	acc,
	por.ctc_id,
	por.por_codigo,
	por.por_siglas,
	tpo_tipo_valoracion,
	tpo_categoria,
	f,
	prox_capital,
	prox_interes,
	prVpr00,
	max_fecha_compra,
	max_precio_compra,
	tpo_custodio
	,civ_siglas
	,civ_descripcion
	,civ_prefijo_cuenta
	,bde_cta_nombre
	,bde_cta_descripcion
 
	,htp.max_interes
	,htp.max_comision_bolsa
	,htp.max_comision_casa
 
	,vpr_duracion_efectiva_anual
	,vpr_duracion_modificada_anual
	,ems_codigo_sic2
	,precio_sin_redondear=
	coalesce(
		--nullif(hrt_precio_vector,0),
		hrt_precio_vector,
		prVpr,
		htp_precio_compra--case when c>='2016-09-30T23:59:59' then max_precio_compra else htp_precio_compra end
	)
	,costo_amortizado	
	,htp.liq_bolsa
	,htp.liq_numero_bolsa
	,htp.pond_precio_compra
	,sum_ve= htp.sal * isnull(htp.pond_precio_compra,1.0) / case when tiv.tiv_tipo_renta=153 then 100e else 1e end
	,prf_descripcion
 
	,vpr_tasa_descuento
	,vpr_tasa_referencia
 
	 -- 6-4-2022
	,vpr_rendimiento_equivalente
 
	,htp.grp_id
	,htp.tpo_cobro_cupon
	,htp.ult_liq_id
 
	--campos que identifican algoritmo y si es cxc para el Isspol
	,IPR_NOMBRE_PROG
	,IPR_ES_CXC
 
	--newf
	,ACEP.ACP_ID
	,ACEP.ACP_NOMBRE
	,CAL.CAL_NOMBRE
	,ENC.ENC_VALOR
	,HTP.HTP_RENDIMIENTO
	,TCA.TCA_VALOR
	--,TIV.TIV_ACTA
	,TIV.TIV_CLASE
	,HTP.tiv_codigo_vector--=coalesce(case when datediff(d,c,tiv_fecha_vencimiento)>365 then (select tiv_codigo_vector from bvq_administracion.titulo_valor where tiv_id=tiv.tiv_split_de) end,tiv_codigo_vector)--tiv.tiv_codigo_vector
	,TIV_MONTO_EMISION=coalesce(etvl.etvl_monto_emision, TIV.TIV_MONTO_EMISION)
	,HTP.TPO_CUPON_VECTOR
	,HTP.TPO_FECHA_SUSC_CONVENIO
	,HTP.TPO_FECHA_VEN_CONVENIO
	,HTP.TPO_FKOP
	,HTP.TPO_INTERVINIENTES
	,HTP.TPO_MANTIENE_VECTOR_PRECIO
	,HTP.TPO_OBJETO
	,HTP.TPO_PRECIO_ULTIMA_COMPRA
	,HTP.TPO_PROG
	,HTP.TPO_ACTA
	,VBA.VBA_PATRIMONIO_TECNICO
	,TVL_DESCRIPCION
	,GCXC.GCXC_NOMBRE
	,HTP.TPO_F1
	,HTP.TPO_CODIGO_VECTOR
	,HTP.TPO_INTERES_TRANSCURRIDO
	,HTP.TPO_OTROS_COSTOS
	,HTP.TPO_COMISIONES
	--,HTP.TPO_RECURSOS
	,TPO_RECURSOS=case when
		datediff(yy,fecha_compra,c)>0 and c>='20250101' AND TPO_RECURSOS='Excedentes de liquidez'
		then 'PAI' else TPO_RECURSOS end
	,HTP.TPO_ABONO_INTERES
	,HTP.TPO_VALNOM_ANTERIOR
	,HTP.TPO_FECHA_ENCARGO
	,ems.asi_emi_codemi
	,HTP.TPO_ORD
	,HTP.TPO_COMISION_BOLSA
	,HTP.TPO_DIVIDENDOS_EN_ACCIONES
	,TIV.TIV_SERIE
	,HTP.TPO_PRECIO_REGISTRO_VALOR_EFECTIVO
	,htp.TPO_DESGLOSAR_F1
	,ev.tfl_fecha_inicio_orig2
	,tiv.tiv_split_de
	,htp.TPO_TABLA_AMORTIZACION
	,tiv.TIV_CODIGO_TITULO_SIC
	,case when abs(round(salNewValNom,2))<=0.02 then 0 else round(salNewValNom,case when c>='2020-04-01' and tiv_tipo_valor in (17,10000006) then 100 else 2 end) end salNewValNom
	,htp.valnomCompraAnterior
	,htp.precioCompraAnterior
	,htp.UFO_USO_FONDOS
	,htp.UFO_RENDIMIENTO
	,valefeConRendimiento=case when htp.tiv_subtipo=3 then
		case when round(htp.ufo_rendimiento,6)>0 then
			htp.sal-(100.0-htp.precioCompraAnterior)/100.0*htp_compra+ufo_rendimiento
		when htp.tpo_fecha_susc_convenio is not null then
			htp.sal
		end
	end
	,htp.tiv_subtipo
	,htp.MIN_TIENE_VALNOM
	,ems_abr=ems.ems_codigo
	,tiv.TIV_NUMERO_TRAMO_SICAV

	,fecha_ultima_compra=
	case when isnull(ipr_es_cxc,0)=0 then
		case when isnull(rtrim(htp.tiv_codigo_vector),'')<>'' and datediff(d,htp.c,tiv_fecha_vencimiento)<=365 then
			coalesce(
				lastValDate
				,case when 1=1 and htp.c>='20250910' then [fecha_compra] end
			)
		when isnull(rtrim(htp.tiv_codigo_vector),'')='' then [fecha_compra]
		when isnull(rtrim(htp.tiv_codigo_vector),'')<>'' and datediff(d,htp.c,tiv_fecha_vencimiento)>365 then
			htp.c
		end
	else
		CASE WHEN tvl_codigo NOT IN ('DER', 'OBL', 'PAG') or TPO_MANTIENE_VECTOR_PRECIO = 1 THEN [fecha_compra] end
	END
	,prEfectivo
	,htp.TPO_FECHA_VENCIMIENTO_ANTERIOR
	,htp.fechaInicioOriginal
	,htp.totalUfoUsoFondos
	,htp.totalUfoRendimiento
	,htp.TPO_FECHA_COMPRA_ANTERIOR
	,htp.TPO_PRECIO_COMPRA_ANTERIOR
	,htp.TPO_FECHA_CORTE_OBLIGACION
	,htp.TPO_AJUSTE_DIAS_DE_INTERES_GANADO
	,htp.interesCoactivo
	,htp.TPO_FECHA_LIQUIDACION_OBLIGACION

	--,plazo_anterior=dbo.fnDias(htp.TPO_FECHA_COMPRA_ANTERIOR,htp.TPO_FECHA_VENCIMIENTO_ANTERIOR,case when tvl_codigo in ('BE','VCC','OBL') then 354 else 355 end)

	/*,
	tpo_categoria_inversion*/
	,TPO_NOMBRE_BONO_GLOBAL
  ,SECTOR_DETALLADO=case when itcsector.itc_codigo='SEC_PRI_FIN' then
		case when EMS_NOMBRE collate modern_spanish_ci_ai like 'COOPERATIVA DE AHORRO Y CRÉDITO%' THEN 'ECONOMÍA POPULAR Y SOLIDARIA' else 'PRIVADO FINANCIERO' end
	else
		case itcsector.itc_codigo WHEN 'SEC_PRI_FIN' then 'PRIVADO FINANCIERO Y ECONOMÍA POPULAR SOLIDARIA' WHEN 'SEC_PRI_NFIN' THEN 'PRIVADO NO FINANCIERO' WHEN 'SEC_PUB_FIN' THEN 'PUBLICO' WHEN 'SEC_PUB_NFIN' THEN 'PUBLICO' END
	END
	,FON_ID
	from
	(
					------------- VALORACIONES ---------------
					select
					latest_inicio=case
						when tpo_prog='oblSums' and htp_tpo_id in (321,324) then
							(
								select top 1 retr_fecha_esperada from bvq_backoffice.retraso r
								where retr_tpo_id=htp_tpo_id and RETR_FECHA_COBRO=latest_vencimiento order by retr_fecha_esperada desc
							)
						when datediff(d,fecha_compra,latest_vencimiento)=0 then cupoper_tfl_fecha_inicio
						else latest_vencimiento end,
					isnull(tpo_numeracion,'') htp_numeracion,
					tpo.por_id,
					tpo.tiv_id,
					htp_tpo_id tpo_id,
					c,
					cortenum,
					cupoper_base_denominador base_denominador,
					sal,
					amortizacion,
					itrans,
					valefeoper,
					iamortizacion,
					acc,
					fecha_compra,
					latest_vencimiento,
					tpo_tipo_valoracion,
					tpo_categoria,
					--arranqueValLineal2='2015-12-31T23:57:59',
					salSinCupon,
					prox_capital,
					prox_interes,
					max_fecha_compra,
					max_precio_compra,
					max_compra,
					max_rendimiento,
	 
					e.max_interes,
					e.max_comision_bolsa,
					e.max_comision_casa,
						costo_amortizado=
								case when
									isnull(tpo.tpo_tipo_valoracion,0)=1
								then
									case when salSinCupon>=5e-3 then
									valPre/salSinCupon*100.0
									else
										100.0
									end
								end,
								
 					prVpr=
					coalesce
					(
						case
 

						when
										exists(select * from bvq_administracion.parametro where par_codigo='C_AMORTIZADO_02' and par_valor='SI')
										and isnull(tpo.tpo_tipo_valoracion,0)=1
						then
							case when salSinCupon>=5e-3 and valPre>=-5e-3 /*cuando hay ventas totales a veces valpre es negativo, no dividir*/ then
								valPre/salSinCupon*100.0
							else
								100.0
							end
						when
							lastValDate is not null
						then
							case when exists(select 1 from bvq_administracion.parametro where par_codigo='VALCOMP_SHORT' and c<=(select tpor_tiempo from bvq_backoffice.tiempos_portafolio where tpor_codigo='VALCOMP_SHORT')) then
								max_precio_compra
							else
								vpr_precio--(vpr_precio-100.0)/datediff(d,lastValDate,t.tiv_fecha_vencimiento)*datediff(d,c,t.tiv_fecha_vencimiento)+100.0
							end
						when
							tpo_categoria_inversion is not null
						then
							1/((1/(max_precio_compra/100.0)-1)/datediff(d,max_fecha_compra,e.tiv_fecha_vencimiento)*datediff(d,c,e.tiv_fecha_vencimiento)+1)*100.0
							--(max_precio_compra-100.0)/datediff(d,max_fecha_compra,e.tiv_fecha_vencimiento)*datediff(d,c,e.tiv_fecha_vencimiento)+100.0
						when
						--e.tiv_tipo_valor in (10,32)
							e.tiv_subtipo in (3)
							and (c>=(select tpor_tiempo from bvq_backoffice.tiempos_portafolio where tpor_codigo='ARRANQUE_VAL_LINEAL') or e.tiv_tipo_valor=10)
						then -- ANTES_DE_VARIABLE:'2015-12-31T23:57:59' FECHA_CAMBIO '2016-04-30T23:57:59'
							case when c>=(select tpor_tiempo from bvq_backoffice.tiempos_portafolio where tpor_codigo='MAX_FECHA_COMPRA') and isnull(tpo_lineal_desde_primera_compra,0)=0 then -- ANTES_DE_VARIABLE: '2016-09-30T23:59:59', FECHA_CAMBIO '2016-10-31T23:59:59'
							--select val_lineal from bvq_administracion.fnValoracionLineal(max_precio_compra,max_fecha_compra,tiv_fecha_vencimiento,c)
								case when exists(select * from bvq_administracion.parametro where par_codigo='VAL_HIPERBOLA' and par_valor='SI') then
									case when sal>=5e-3 then hiperb/round(sal,2)*100.0 else 100.0 end
								else
									(max_precio_compra-100.0)/datediff(d,max_fecha_compra,e.tiv_fecha_vencimiento)*datediff(d,c,e.tiv_fecha_vencimiento)+100.0
								end
							else
						--select val_lineal from bvq_administracion.fnValoracionLineal(htp_precio_compra,fecha_compra,tiv_fecha_vencimiento,c)
								(e.htp_precio_compra-100.0)/datediff(d,fecha_compra,e.tiv_fecha_vencimiento)*datediff(d,c,e.tiv_fecha_vencimiento)+100.0
							end
						when datediff(d,c,e.tiv_fecha_vencimiento)>365 and tiv.tiv_split_de<>0
						then
							(
								select vpr_precio from
								bvq_administracion.vector_precio vpr 
								where vpr.tiv_id=tiv.tiv_split_de and datediff(d,vpr_fecha,c)=0
							)

						end
						,nullif(vpr_precio,0)
					),
					prVpr00=
						coalesce
						(
							case when
								lastValDate is not null
							then
								'lastValDateNotNull'
							when 
							--e.tiv_tipo_valor in (10,32)
								e.tiv_subtipo in (3)
								and c>=(select tpor_tiempo from bvq_backoffice.tiempos_portafolio where tpor_codigo='ARRANQUE_VAL_LINEAL')
							then -- ANTES_DE_VARIABLE:'2015-12-31T23:57:59' FECHA_CAMBIO '2016-04-30T23:57:59'
								case when c>=(select tpor_tiempo from bvq_backoffice.tiempos_portafolio where tpor_codigo='MAX_FECHA_COMPRA') and isnull(tpo_lineal_desde_primera_compra,0)=0 then -- ANTES_DE_VARIABLE: '2016-09-30T23:59:59', FECHA_CAMBIO '2016-10-31T23:59:59'
									--select val_lineal from bvq_administracion.fnValoracionLineal(max_precio_compra,max_fecha_compra,tiv_fecha_vencimiento,c)
									'>max_fecha_compra'
								else
								--select val_lineal from bvq_administracion.fnValoracionLineal(htp_precio_compra,fecha_compra,tiv_fecha_vencimiento,c)
									'<max_fecha_compra'
								end
							end
							,'ALL_NUll'
						),
					htp_precio_compra,
					arranqueValLineal,
					t.lastValDate,
					vpr_precio,
						e.htp_compra,--htp_compra=max_compra,
					liq_rendimiento=max_rendimiento,
					pond_rendimiento,
					f,
					tpo.tpo_custodio
					,civ.civ_siglas
					,civ.civ_descripcion
					,civ.civ_prefijo_cuenta
					,bdecta.cta_nombre bde_cta_nombre
					,bdecta.cta_descripcion bde_cta_descripcion
					,ult_fecha_interes=(select top 1 latest_vencimiento from (select fecha=e.latest_vencimiento union select max_fecha_compra union select c) s order by fecha desc)
					,vpr_duracion_efectiva_anual
					,vpr_duracion_modificada_anual
					,liq_bolsa=e.max_bolsa
					,liq_numero_bolsa=e.max_numero_bolsa
					,e.pond_precio_compra
					,prf_descripcion
	 
					,vpr_tasa_descuento
					,vpr_tasa_referencia
 
					-- 6-4-2022
					,vpr_rendimiento_equivalente
	 
					,tpo.GRP_ID
					,tpo.tpo_cobro_cupon
					,ult_liq_id=e.max_liq_id
 
					--newf
					,HTP_RENDIMIENTO
					,TPO.TPO_CUPON_VECTOR
					,TPO.TPO_FECHA_SUSC_CONVENIO
					,TPO.TPO_FECHA_VEN_CONVENIO
					,TPO.TPO_FKOP
					,TPO.TPO_INTERVINIENTES
					,TPO.TPO_MANTIENE_VECTOR_PRECIO
					,TPO.TPO_OBJETO
					,TPO.TPO_PRECIO_ULTIMA_COMPRA
					,TPO.TPO_PROG
					,TPO.TPO_ACTA
					,TPO.TPO_F1
					,TPO.TPO_CODIGO_VECTOR
					,TPO.TPO_INTERES_TRANSCURRIDO
					,TPO.TPO_OTROS_COSTOS
					,TPO.TPO_COMISIONES
					,TPO.TPO_RECURSOS
					,TPO.TPO_ABONO_INTERES
					,TPO.TPO_VALNOM_ANTERIOR
					,TPO.TPO_FECHA_ENCARGO
					,TPO.TPO_ORD
					,TPO.TPO_COMISION_BOLSA
					,TPO.TPO_DIVIDENDOS_EN_ACCIONES
					,TPO.TPO_PRECIO_REGISTRO_VALOR_EFECTIVO
					,tpo.TPO_DESGLOSAR_F1
					,TPO.TPO_TABLA_AMORTIZACION
					,e.salNewValNom
					,TPO.TPO_ID_ANTERIOR
					,TPO2.valnomCompraAnterior
					,TPO2.precioCompraAnterior
					,e.UFO_USO_FONDOS
					,e.UFO_RENDIMIENTO
					,e.tiv_subtipo
					,e.MIN_TIENE_VALNOM
					,e.prEfectivo
					,TPO.TPO_FECHA_VENCIMIENTO_ANTERIOR
					,fechaInicioOriginal=case when (TPO.TPO_FECHA_SUSC_CONVENIO='20221031' and tpo_numeracion like 'PLAZA_PROYECTA-%' OR TPO.TPO_NUMERACION LIKE 'CDD-%') THEN '20221031' else e.fechaInicioOriginal end
					,e.totalUfoUsoFondos
					,e.totalUfoRendimiento
					,TPO.TPO_FECHA_COMPRA_ANTERIOR
					,TPO.TPO_PRECIO_COMPRA_ANTERIOR
					,TPO.TPO_FECHA_CORTE_OBLIGACION
					,TPO.TPO_AJUSTE_DIAS_DE_INTERES_GANADO
					,e.interesCoactivo
					,TPO.TPO_FECHA_LIQUIDACION_OBLIGACION
					,tiv_codigo_vector=coalesce(case when datediff(d,c,e.tiv_fecha_vencimiento)>365
						or c>='20250910'
						then (select tiv_codigo_vector from bvq_administracion.titulo_valor where tiv_id=tiv.tiv_split_de) end,tiv_codigo_vector)--tiv.tiv_codigo_vector
					,TPO.TPO_NOMBRE_BONO_GLOBAL
					,e.FON_ID
					from bvq_backoffice.EventoPortafolioCorte e
					join bvq_backoffice.titulos_portafolio tpo on e.htp_tpo_id=tpo.tpo_id
					join bvq_administracion.titulo_valor tiv on tiv.tiv_id=tpo.tiv_id
					left join
						BVQ_ADMINISTRACION.VALORACION_LINEAL_CACHE t
						join
						bvq_administracion.vector_precio vpr
						on vpr.tiv_id = coalesce(case when t.cc>='20250910' then nullif(t.tiv_split_de,0) end,t.tiv_id) and convert(int,vpr_fecha)*1e8+vpr.vpr_id=f
					on (t.tiv_id=tpo.tiv_id and tpo.tiv_id<>7755 or t.tiv_id=7093 and tpo.tiv_id=7755)
					and c=t.cc
 
					--bde_perfil_contable
					left join bvq_backoffice.bde_perfil_contable bdeprf on
					(
						bdeprf.prf_categoria_inversion=tpo_categoria_inversion or exists(
							select * from bvq_administracion.parametro where par_codigo='SIN_CAT_INVERSION' and par_valor='SI'
						)
					) and
					datediff(d,c,e.tiv_fecha_vencimiento) between bdeprf.prf_dias_desde and bdeprf.prf_dias_hasta
					left join bvq_backoffice.sb_categoria_inversion civ on civ.civ_id=tpo_categoria_inversion
					left join bvq_backoffice.cuenta_contable bdecta on bdeprf.prf_cta_id=bdecta.cta_id
					left join (select valnomCompraAnterior=tpo_cantidad, precioCompraAnterior=tpo_precio_ingreso, tpo_id from BVQ_BACKOFFICE.titulos_portafolio) tpo2 on tpo2.tpo_id=tpo.tpo_id_anterior
					------------- FIN VALORACIONES ---------------
	) htp
 
	inner join bvq_administracion.titulo_valor tiv on htp.tiv_id=tiv.tiv_id
	left join bvq_administracion.emisor_tipo_valor etvl on etvl.ETVL_CODIGO_SIC2=tiv_codigo_sic and tiv_tipo_valor=10 and fecha_compra>='20250414'--tiv_codigo_sic in (37543,37114)
	
	--left join bvq_administracion.bde_perfil_contable prf on datediff(d,c,tiv_fecha_vencimento) between prf_dias_desde and prf_dias_hasta and prf_categoria_inversion

	--start
	left join bvq_administracion.titulo_flujo_comun tfl
		left join (
			select distinct retr_fecha_cobro, retr_fecha_esperada, tpo.tiv_id from bvq_backoffice.retraso retr join bvq_backoffice.titulos_portafolio tpo on retr_tpo_id=tpo.tpo_id
			where tiv_id in (1596,6864)
		) retr on retr_fecha_esperada=tfl_fecha_inicio and tfl.tiv_id=retr.tiv_id
	on
	tfl.tiv_id=tiv.tiv_id and
	latest_inicio=coalesce(retr_fecha_cobro,tfl_fecha_inicio)

	left join bvq_administracion.TasaValorCompact ts on tfl.tfl_id=ts.tfl_id
	left join
	(
		SELECT row_number() over (partition by tpo_id,c.c order by hrt_fecha desc,hrt_id desc) r, hrt_precio_vector,hrt.tiv_id,hrt_fecha,tpo_id rtpo_id,c cc 
		FROM BVQ_BACKOFFICE.HISTORICO_VALORACION_TITULOS HRT
		join bvq_backoffice.titulos_portafolio tpo on tpo.tiv_id=hrt.tiv_id and tpo.por_id=hrt.por_id
		join corteslist c on datediff(dd, HRT_FECHA, c.c )=0
	) s
	on htp.c=s.cc AND (htp.tpo_id is null or s.rtpo_id=htp.tpo_id) and s.r=1
 
 
	inner join bvq_administracion.tipo_valor tvl on tvl.tvl_id=tiv_tipo_valor
	inner join bvq_administracion.emisor ems on tiv_emisor=ems.ems_id
	left join  bvq_administracion.item_catalogo itcpais on ems_pais=itcpais.itc_id
	left join  bvq_administracion.item_catalogo itcsector on ems_sector=itcsector.itc_id
	inner join bvq_backoffice.portafolio por on por.por_id=htp.por_id
 
	
	--joins para campos del Isspol
	left join bvq_backoffice.aceptante acep on tiv.acp_id=acep.acp_id
	left join bvq_administracion.variables_balance vba on tiv.tiv_emisor=vba.ems_id and htp.c between vba_fecha_desde and dateadd(s,-1,vba_fecha_hasta)
	left join (
		select row_number() over (partition by tiv_id order by tca_fecha_desde desc,tca_id desc) r,tca_valor,cal_id,tiv_id
		from bvq_administracion.titulos_calificacion tca
	) tca on tca.r=1 and tca.tiv_id=tiv.tiv_id
	left join (
		select row_number() over (partition by enc_numero_emision order by enc_fecha_desde desc,enc_id desc) r,enc_valor,cal_id,enc_numero_corto_emision
		from bvq_administracion.emision_calificacion enc
	) enc on enc.r=1 and isnull(tiv.tiv_codigo_titulo_sic,'')<>'' and tiv.tiv_codigo_titulo_sic=enc.enc_numero_corto_emision
	left join bvq_administracion.calificadoras cal on cal.cal_id=coalesce(tca.cal_id,enc.cal_id)
	left join BVQ_BACKOFFICE.ISSPOL_PROGS progs	on HTP.TPO_PROG=progs.IPR_NOMBRE_PROG
	--left join (select tfl_fecha_inicio_orig2=tfl_fecha_inicio_orig,tfl_fecha_vencimiento2,htp_tpo_id2=htp_tpo_id from bvq_backoffice.EventoPortafolio where htp_tiene_valnom=1) ev on htp.c between ev.tfl_fecha_inicio_orig2 and ev.tfl_fecha_vencimiento2 and ev.htp_tpo_id2=htp.tpo_id and isnull(progs.ipr_es_cxc,0)=0
	left join (
		select ncorte=cl.c,tfl_fecha_inicio_orig2=min(tfl_fecha_inicio_orig),tfl_fecha_vencimiento2=max(tfl_fecha_vencimiento2),htp_tpo_id2=htp_tpo_id from bvq_backoffice.EventoPortafolioAprox e
		join corteslist cl on cl.c between tfl_fecha_inicio_orig and tfl_fecha_vencimiento2 and e.htp_id<>8829100001533
		where htp_tiene_valnom=1
		group by htp_tpo_id,cl.c
	) ev on htp.c=ncorte and ev.htp_tpo_id2=htp.tpo_id and isnull(progs.ipr_es_cxc,0)=0

	left join BVQ_ADMINISTRACION.GRUPOS_CXC GCXC
		on tvl_codigo=gcxc.GCXC_CODIGO
	--left join bvq_prevencion.personacomitente per on por.ctc_id=per.ctc_id
	/*left join BVQ_BACKOFFICE.AJUSTES_DE_ACCRUAL AJU
	on HTP.TPO_ID=AJU.AJU_TPO_ID AND c>=AJU_DATE*/
