create view bvq_backoffice.PortafolioCorte as
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
	latest_inicio,
	--latest_vencimiento,
	dbo.fnDias(latest_inicio,c,case when tiv_accrual_365=1 then 355 else tiv.tiv_tipo_base end)+case when tiv_accrual_365=1 then 1 else 0 end dias_al_corte,
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
	case when abs(round(sal,2))<=0.02 then 0 else round(sal,case when c>='2020-04-01' and tiv_tipo_valor=17 then 100 else 2 end) end sal,
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
			,2
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
	/*,
	tpo_categoria_inversion*/
	from
	(
					------------- VALORACIONES ---------------
					select
					latest_inicio=latest_vencimiento,
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
								(vpr_precio-100.0)/datediff(d,lastValDate,t.tiv_fecha_vencimiento)*datediff(d,c,t.tiv_fecha_vencimiento)+100.0
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
					lastValDate,
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
					from bvq_backoffice.EventoPortafolioCorte e
					join bvq_backoffice.titulos_portafolio tpo on e.htp_tpo_id=tpo.tpo_id

					left join
						BVQ_ADMINISTRACION.VALORACION_LINEAL_CACHE t
						join
						bvq_administracion.vector_precio vpr
						on t.tiv_id=vpr.tiv_id and convert(int,vpr_fecha)*1e8+vpr.vpr_id=f
					on t.tiv_id=tpo.tiv_id
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
					------------- FIN VALORACIONES ---------------
	) htp

	inner join bvq_administracion.titulo_valor tiv on htp.tiv_id=tiv.tiv_id
	--left join bvq_administracion.bde_perfil_contable prf on datediff(d,c,tiv_fecha_vencimento) between prf_dias_desde and prf_dias_hasta and prf_categoria_inversion
	left join bvq_administracion.titulo_flujo_comun tfl
	on
	tfl.tiv_id=tiv.tiv_id and
	latest_inicio=tfl_fecha_inicio
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
	inner join bvq_administracion.emisor ems on tiv_emisor=ems_id
	left join  bvq_administracion.item_catalogo itcpais on ems_pais=itcpais.itc_id
	left join  bvq_administracion.item_catalogo itcsector on ems_sector=itcsector.itc_id
	inner join bvq_backoffice.portafolio por on por.por_id=htp.por_id
	--left join bvq_prevencion.personacomitente per on por.ctc_id=per.ctc_id
	/*left join BVQ_BACKOFFICE.AJUSTES_DE_ACCRUAL AJU
	on HTP.TPO_ID=AJU.AJU_TPO_ID AND c>=AJU_DATE*/
