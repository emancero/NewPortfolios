exec dropifexists 'bvq_backoffice.tfEstadoDeCuentaPortafolio'
go
CREATE function bvq_backoffice.tfEstadoDeCuentaPortafolio(@i_idPortfolio int, @i_fecha datetime)
returns @v_tabla table
(
	 POR_CODIGO VARCHAR(50)
	,EMISOR varchar(200)
	,PAIS varchar(200)
	,SECTOR varchar(100)
	,TIPO_RENTA  varchar(50)
	,TIPO_VALOR  varchar(50)
	,GENERICO bit
	,SUBTIPO varchar(50)
	,GRP_ID int
	,TIV_PLAZO_REMANENTE int
	,TIPO_TASA varchar(50)
	,TIPO_TASA_ID int
	,TIV_TASA_INTERES float
	,TPO_SALDO float
	,TIV_PRECIO_SPOT float
	,VALOR_EFECTIVO float
	,POR_ID int
	,TIV_ID int
	,TPO_CANTIDAD float
	,TPO_ESTADO int
	,TIV_CODIGO VARCHAR(50)
	,TIV_RENDIMIENTO float
	,TEA float
	,INTERES_ACUMULADO float
	,TIV_TASA_MARGEN float
	,TIV_TASA_CUPON_REMANENTE float
	,MON_NOMBRE varchar(50)
	,TPO_PRECIO_INGRESO float
	,TPO_COBRO_CUPON bit
	,TIV_TIPO_RENTA int
	,MON_CODIGO_ISO varchar(3)
	,TIV_PLAZO int
	,TIV_SUBTIPO int
	,TIV_SECTOR int
	,TIV_TIPO_VALOR int
	,TIV_MONEDA int
	,TIV_CODIGO_SIC int
	,TIV_CODIGO_GEN_SIC int
	,HTP_CUPON bit
	,ESTADO_REP VARCHAR(40)
	-- NIF
	, TPO_CATEGORIA VARCHAR(100)
	-- FIN NIF
	, TIV_FECHA_VENCIMIENTO DATETIME
	,TIV_FECHA_EMISION DATETIME
	,PRECIO_PONDERADO FLOAT
	,VALOR_EFECTIVO_A_PRECIO_PONDERADO FLOAT
	,ACUMULADO FLOAT
        ---NUEVOS CAMPOS ESTADO DE CUENTA
	,TIV_DESMATERIALIZADO BIT
	,HTP_NUMERACION varchar(250)
	,TIV_DESMATERIALIZADO_NOMBRE varchar(50)
	,VALOR_NOMINAL_DENTRO_DE_ACCIONES float
	,CANTIDAD float
	,TIV_VALOR_NOMINAL float
	,TIV_TIPO_BASE int
	,TPO_ID int
	,valor varchar(20)
	,calificadora varchar(200)
	,califOrig varchar(20)
	,tipo_base varchar(100)
	,custodio varchar(100)
	,rendimiento_operacion float
	,fecha_resolucion datetime
	,tvl_codigo varchar(50)
	,grupo_tipo_valor varchar(100)
	,ems_codigo varchar(20)
	,por2_fecha_compra datetime
	,por2_precio_compra float
	,por2_valefeoper float
	,por2_accrual float
	,por2_latest_inicio datetime
	,tipo_plazo varchar(255)
	,tpo_tipo_valoracion bit
	,por2_sal float
	,por2_dias_al_corte int
	,por2_prox_capital datetime
	,por2_prox_interes datetime
	,por2_por_nombre varchar(200)
	,por2_sector_general varchar(20)

	,por2_civ_siglas varchar(100)
	,por2_civ_descripcion varchar(200)
	,por2_civ_prefijo_cuenta varchar(100)
	,por2_bde_cta_nombre varchar(100)
	,por2_bde_cta_descripcion varchar(200)

	,porant_sal float
	,porant_tiv_precio float
	,porant_accrual float
	
	,TIV_PERIODO_CAPITAL_SEB int
	,TIV_FRECUENCIA_SEB int
	
	,PERIODO_INTERES varchar(50)
	,PERIODO_CAPITAL varchar(50)
	
	,vn_orig float
	,pond_rendimiento float
	
	,max_interes float
	,max_comision_bolsa float
	,max_comision_casa float
	,max_fecha_compra datetime
	,nombre_comitente varchar(150)
	,porant_duracion_efectiva_anual float
	,porant_duracion_modificada_anual float
	,ems_codigo_sic2 int
	,precio_sin_redondear float
	,TIV_TIPO int
	,registrado varchar(100)
	
	,bolsa varchar(50)
	,numero_bolsa varchar(50)

	,TIV_CODIGO_BVQ varchar(50)
	,apreciacion float
	,TIV_NUMERO_EMISION_SEB NCHAR(6)
	,TIV_MONTO_EMISION float
	,prf_descripcion varchar(50)
	,por2_duracion_efectiva_anual float
	,por2_duracion_modificada_anual float
	--Columna por_public
	,POR_PUBLIC bit
	
	--Columnas Banrio, valor_nominal_compra/valor_efectivo_compra
	,pond_precio_compra float
	
	--Columna valor_nominal_compra
	,por2_compra float
	,por2_ve_compra float
	
	--Ultima liq_id
	,ult_liq_id int
	,acp_identificacion varchar(50)
	,acp_nombre varchar(250)

	-- 6-4-2022
	,vpr_tasa_descuento float
	--,vpr_rendimiento_equivalente float
	) as
	
	--(
	begin
		--títulos en portafolio
		INSERT INTO @v_tabla
		SELECT DISTINCT
				BVQ_BACKOFFICE.PORTAFOLIO.POR_CODIGO, 
				EMS_NOMBRE /*(SELECT EMS_NOMBRE FROM BVQ_ADMINISTRACION.EMISOR WHERE (EMS_ID = BVQ_ADMINISTRACION.TITULO_VALOR.TIV_EMISOR) )*/ as EMISOR,
				pais=por2_pais,
				(
					SELECT coalesce(EMS_TIPO_EMISOR,'NO DISPONIBLE') FROM BVQ_ADMINISTRACION.EMISOR
					WHERE EMS_ID = BVQ_ADMINISTRACION.TITULO_VALOR.TIV_EMISOR
				)as SECTOR,
				(
					SELECT ITC_NOMBRE FROM BVQ_ADMINISTRACION.ITEM_CATALOGO
					WHERE ITC_ID = BVQ_ADMINISTRACION.TITULO_VALOR.TIV_TIPO_RENTA
				)as TIPO_RENTA,
				(
					SELECT TVL_NOMBRE FROM BVQ_ADMINISTRACION.TIPO_VALOR
					WHERE TVL_ID = BVQ_ADMINISTRACION.TITULO_VALOR.TIV_TIPO_VALOR
				)as TIPO_VALOR,
				generico=por2_tvl_generico,
				(
					SELECT SBT_NOMBRE FROM BVQ_ADMINISTRACION.SUBTIPO WHERE SBT_ID = BVQ_ADMINISTRACION.TITULO_VALOR.TIV_SUBTIPO
				)as SUBTIPO,
				por2.GRP_ID,
				case TIV_TIPO_RENTA WHEN  v_tipo_renta THEN NULL ELSE
					dbo.fnDias(por2_tfcorte,tiv_fecha_vencimiento,tiv_tipo_base)
					
				end,
				case TIV_TIPO_RENTA WHEN  v_tipo_renta THEN
					NULL
				ELSE
				(
					SELECT ITC_NOMBRE FROM BVQ_ADMINISTRACION.ITEM_CATALOGO
					WHERE ITC_ID = BVQ_ADMINISTRACION.TITULO_VALOR.TIV_TIPO_TASA
				)end as TIPO_TASA,
				BVQ_ADMINISTRACION.TITULO_VALOR.TIV_TIPO_TASA,
				ROUND
				(
					case TIV_TIPO_TASA WHEN  v_tasaFijaId
					THEN ISNULL(BVQ_ADMINISTRACION.TITULO_VALOR.TIV_TASA_INTERES,0)   
					ELSE
						ISNULL
						(
							BVQ_ADMINISTRACION.ObtenerTasaPorIdyFechaFunc
							(
								BVQ_ADMINISTRACION.TITULO_VALOR.TIV_ID
								,BVQ_ADMINISTRACION.TITULO_VALOR.TIV_TIPO_TASA
								,BVQ_BACKOFFICE.fnObtenerFechaInicioCuponActual(Convert(DATETIME,@i_fecha),BVQ_ADMINISTRACION.TITULO_VALOR.TIV_ID)
							),0
						)
						+ISNULL(BVQ_ADMINISTRACION.TITULO_VALOR.TIV_TASA_MARGEN,0)
					END
					,8
				) AS TIV_TASA_INTERES,
				por2.HTP_SALDO_C HTP_SALDO,
				TIV_PRECIO_SPOT = tiv_precio,
				--case TIV_TIPO_RENTA WHEN v_tipo_renta
				--THEN
				--(
				--	isnull(CONVERT(FLOAT, por2.HTP_SALDO_C),0)*
				--	(
				--		isnull
				--		(
				--			CONVERT
				--			(
				--				FLOAT
				--				,BVQ_ADMINISTRACION.ObtenerUltimoPrecioValoracion2
				--				(
				--					@i_fecha
				--					,TITULO_VALOR.TIV_ID
				--					,por2.TPO_ID_C
				--				)
				--			)
				--			,isnull(por2.HTP_PRECIO_COMPRA, 0)
				--		)
				--	)
				--)
				--ELSE
				--(
				--	isnull(CONVERT(FLOAT, por2.HTP_SALDO_C),0)*
				--	(
				--		isnull
				--		(
				--			CONVERT
				--			(
				--				FLOAT
				--				,BVQ_ADMINISTRACION.ObtenerUltimoPrecioValoracion2
				--				(
				--					@i_fecha
				--					,TITULO_VALOR.TIV_ID
				--					,por2.TPO_ID_C
				--				)
				--			)
				--			,isnull(por2.HTP_PRECIO_COMPRA, 0)
				--		)
				--	)
				--)
				--/ 100
				--END as VALOR_EFECTIVO,
				0 as VALOR_EFECTIVO,
				por2.POR_ID,	
						por2.TIV_ID, 
				por2_sal
				TPO_CANTIDAD,
				HT.HTP_ESTADO, 
				BVQ_ADMINISTRACION.TITULO_VALOR.TIV_CODIGO,
				case TIV_TIPO_RENTA WHEN  v_tipo_renta
				THEN NULL
				ELSE isnull(BVQ_ADMINISTRACION.TITULO_VALOR.TIV_RENDIMIENTO, 0) END as TIV_RENDIMIENTO,
				TEA=null, -- a implementar a futuro
				case TIV_TIPO_RENTA WHEN  v_tipo_renta THEN NULL ELSE (0.0) end as INTERES_ACUMULADO,
				case TIV_TIPO_RENTA WHEN  v_tipo_renta THEN NULL ELSE TIV_TASA_MARGEN END,
				case TIV_TIPO_RENTA WHEN  v_tipo_renta
				THEN NULL
				ELSE
					ISNULL(BVQ_ADMINISTRACION.TITULO_VALOR.TIV_TASA_MARGEN,0)
					--+ ISNULL(BVQ_ADMINISTRACION.fnObtenerValorTasaPorTitulo(BVQ_ADMINISTRACION.TITULO_VALOR.TIV_ID),0)
					/*+isnull((
						SELECT top(1)  tas_val.[TVA_VALOR_TASA]
						  FROM [BVQ_ADMINISTRACION].[TASA_VALOR] tas_val
							inner join BVQ_ADMINISTRACION.TIPO_TASA tip_tas on tip_tas.tta_id =tas_val.tta_id
							inner join BVQ_ADMINISTRACION.TITULO_VALOR tit_val on tit_val.TIV_TIPO_TASA = tip_tas.tta_id
							where tit_val.tiv_id = por2.por2_tiv_id --and tas_val.[TVA_FECHA_TASA_VALOR] <= BVQ_ADMINISTRACION.ObtenerFechaSistema()
							order by tas_val.[TVA_FECHA_TASA_VALOR] desc			
					),0)*/
				END AS TIV_TASA_CUPON_REMANENTE,
				MON_NOMBRE,
				TIV_PRECIO_SPOT TPO_PRECIO_INGRESO,
				por2.HTP_CUPON TPO_COBRO_CUPON,
				TITULO_VALOR.TIV_TIPO_RENTA,
				MON_CODIGO_ISO,
				TITULO_VALOR.TIV_PLAZO , 
				TITULO_VALOR.TIV_SUBTIPO,
				TITULO_VALOR.TIV_SECTOR, 
				TITULO_VALOR.TIV_TIPO_VALOR,
				TITULO_VALOR.TIV_MONEDA,
				TITULO_VALOR.TIV_CODIGO_SIC,
				TITULO_VALOR.TIV_CODIGO_GEN_SIC,
				por2.HTP_CUPON,
				ESTADO_REP = (
					SELECT IT.ITC_VALOR
					FROM BVQ_ADMINISTRACION.ITEM_CATALOGO IT
					INNER JOIN BVQ_ADMINISTRACION.CATALOGO CAT
					ON IT.CAT_ID = CAT.CAT_ID AND CAT_CODIGO = 'BCK_EST_POR_REP' AND IT.ITC_CODIGO = 'DISPONIBLE'
				)
				, TPO_CATEGORIA = (
					SELECT IT.ITC_VALOR
					FROM BVQ_ADMINISTRACION.ITEM_CATALOGO IT
					WHERE IT.ITC_ID = por2.HTP_CATEGORIA
				)
				, TIV_FECHA_VENCIMIENTO
				, TIV_FECHA_EMISION
				, CASE WHEN por2.HTP_SALDO_C = 0 THEN 0 ELSE ROUND(b.VALOR_EFECTIVO_HISTORICO/por2.HTP_SALDO_C,4)END PRECIO_PONDERADO
				, ROUND(b.VALOR_EFECTIVO_HISTORICO,4) VALOR_EFECTIVO_A_PRECIO_PONDERADO
				, CASE WHEN TIV_PLAZO_REMANENTE=0
				THEN 0
				ELSE
					ROUND((por2.HTP_SALDO_C-b.VALOR_EFECTIVO_HISTORICO)/TIV_PLAZO_REMANENTE,4)
				END ACUMULADO
				,BVQ_ADMINISTRACION.TITULO_VALOR.TIV_DESMATERIALIZADO as TIV_DESMATERIALIZADO  
				,case when charindex(' id:',por2.htp_numeracion)>0
				then
					left(por2.htp_numeracion,charindex(' id:',por2.htp_numeracion)-1)
				else por2.htp_numeracion end /*por2.HTP_NUMERACION*/ as HTP_NUMERACION
				,CASE WHEN BVQ_ADMINISTRACION.TITULO_VALOR.TIV_DESMATERIALIZADO =1
				THEN 'DESMATERIALIZADO'
				ELSE 'FISICO' END TIV_DESMATERIALIZADO_NOMBRE
				,VALOR_NOMINAL_DENTRO_DE_ACCIONES=
				case when tiv_tipo_renta=153 then
					1
				else
					tiv_valor_nominal
				END
				*
				por2_sal
				,CANTIDAD = 
				case when tiv_tipo_renta=153 then
					1
				else
					por2.HTP_SALDO_C
				END
				,TIV_VALOR_NOMINAL
				,TIV_TIPO_BASE
				,por2.TPO_ID_C
				,coalesce(calif.valor,emical.eca_valor) valor
				,coalesce(cal.cal_nombre_personalizado,cal.cal_nombre,emical.eca_nombre_personalizado,emical.eca_nombre) calificadora
				,
				case when bvq_administracion.fnRiskToInt(calif.valor)>0 and bvq_administracion.fnRiskToInt(por2_calif_compra)>0 then
					case when bvq_administracion.fnRiskToInt(calif.valor)>bvq_administracion.fnRiskToInt(por2_calif_compra)
					then 'Ascendente'
					when bvq_administracion.fnRiskToInt(calif.valor)<bvq_administracion.fnRiskToInt(por2_calif_compra)
					then 'Descendente'
					else 'Estable' end
				else '' end califOrig
				,tba.itc_codigo TIPO_BASE
				,custodio=
				coalesce
				(
					UPPER
					(
						CAST
						(
							(
								SELECT TOP 1 COALESCE(TIV_CAMARA,ETVL_CAMARA) CUSTODIO 
								FROM BVQ_ADMINISTRACION.TITULO_VALOR TIV LEFT JOIN BVQ_ADMINISTRACION.EMISOR_TIPO_VALOR ETVL 
								ON TIV_CODIGO_SIC=ETVL_CODIGO_SIC2 
								WHERE TIV.TIV_ID = BVQ_ADMINISTRACION.TITULO_VALOR.TIV_ID
							) AS VARCHAR(MAX)
						)
					)
					,por2_tpo_custodio,'DECEVALE'
				)
				,por2_rendimiento
				,coalesce(calif.fecha_desde,eca_fecha_resolucion) fecha_resolucion
				,tvl_codigo
				,tvl_grupo_concentracion grc_nombre
				,ems_codigo
				,por2_fecha_compra
				,por2_precio_compra
				,por2_compra*por2_precio_compra/case when tiv_tipo_renta=153 then 100e else 1 end
				,por2_accrual
				,por2_latest_inicio
				,tplazo.itc_nombre tipo_plazo
				,por2_tipo_valoracion
				,por2_sal
				,por2_dias_al_corte
				,por2_prox_capital
				,por2_prox_interes
				,por2_por_nombre
				,por2_sector_general


				,por2_civ_siglas
				,por2_civ_descripcion
				,por2_civ_prefijo_cuenta
				,por2_bde_cta_nombre
				,por2_bde_cta_descripcion

				,porant_sal
				,porant_tiv_precio=coalesce(porant_tiv_precio,case when amortizaUlt.par_valor='SI' then por2.htp_precio_compra end)
				,porant_accrual

				,TITULO_VALOR.TIV_PERIODO_CAPITAL_SEB
				,TITULO_VALOR.TIV_FRECUENCIA_SEB
				
				,PERIODO_INTERES=coalesce(
								rtrim(frec_int.sft_descripcion),
				case when tiv_tipo_renta=154 then '' else 'Al vencimiento' end
				)

				,PERIODO_CAPITAL=coalesce(
								rtrim(frec_cap.sft_descripcion),
				case when tiv_tipo_renta=154 then '' else 'Al vencimiento' end
				)
				
				,vn_orig =
				(
					(
						--null--select [BVQ_BACKOFFICE].[fn_htp_vn_orig] (@i_fecha, por2.htp_tpo_id)
						select SUM(vn_org) from BVQ_BACKOFFICE.htp_vn_orig where htp_tpo_id=por2.htp_tpo_id and htp_fecha_operacion<=@i_fecha
					)*
					(
						case when tiv_tipo_renta=154 then tiv_valor_nominal else 1 end
					)
				)
				,pond_rendimiento
				
				
				
				
				
				
				,por2.max_interes
				,por2.max_comision_bolsa
				,por2.max_comision_casa
				,por2.max_fecha_compra
				,per.nombre
				,porant_duracion_efectiva_anual
				,porant_duracion_modificada_anual
				,ems_codigo_sic2
				,precio_sin_redondear
				,BVQ_ADMINISTRACION.TITULO_VALOR.TIV_TIPO
				,registrado=tivTipo.ITC_CODIGO
				,por2.por2_bolsa
				,por2.por2_numero_bolsa
				,TITULO_VALOR.TIV_CODIGO_BVQ
				,apreciacion=
				+(isnull(por2_valefe,0)-isnull(porant_valefe,0))
				-(isnull(por2_valEfeOper,0)-isnull(porant_valEfeOper,0))
				+(isnull(por2_amortizacion,0)-isnull(porant_amortizacion,0))
				* case when amortizaUlt.par_valor='SI' then porant_tiv_precio/100.0 else 1.0 end

				,case when tiv_tipo_valor=10 then (select top 1 etvl_numero_emision from bvq_administracion.emisor_tipo_valor where etvl_codigo_sic=titulo_valor.tiv_codigo_titulo_sic) else TITULO_VALOR.TIV_NUMERO_EMISION_SEB end
				,case when tiv_tipo_valor=10 then (select top 1 etvl_monto_emision from bvq_administracion.emisor_tipo_valor where etvl_codigo_sic=titulo_valor.tiv_codigo_titulo_sic) else TITULO_VALOR.TIV_MONTO_EMISION end
				,prf_descripcion
				,por2.por2_duracion_efectiva_anual
				,por2.por2_duracion_modificada_anual
				--Columna por_public
				,POR_PUBLIC
				
				--Columnas Banrio, valor_nominal_compra/valor_efectivo_compra
				,por2.pond_precio_compra						
				,por2.sum_ve 	--case when tiv_tipo_renta=153 then por2.sum_ve else por2.por2_sal end
				,sum_ve_compra=	case when tiv_tipo_renta<>v_tipo_renta then 
													CASE WHEN isnull(BVQ_ADMINISTRACION.TITULO_VALOR.tiv_con_restriccion,0)=0 
													THEN por2.por2_sal ELSE isnull(LIQ.LIQ_TOT_OPERACION,por2.por2_sal) END 
								else (	0.0	)	--Se recalcula posteriormente
								end
				--Ultima liq_id
				,por2.ult_liq_id
				,acep.acp_identificacion
				,acep.acp_nombre
				
				--6-4-2022
				,por2.vpr_tasa_descuento
				--,por2.vpr_rendimiento_equivalente

		FROM	BVQ_BACKOFFICE.PORTAFOLIO
				left join BVQ_ADMINISTRACION.PARAMETRO AmortizaUlt on par_codigo='AMORTIZA_ULTPRECIO'
				left join BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HT
				on BVQ_BACKOFFICE.PORTAFOLIO.POR_ID = ht.POR_ID and 1=0
				--join bvq_administracion.grupo_concentracion grc on tvl_grupo_concentracion=grc_id
				left join
				(
					select
					 accrual						por2_accrual
					,valefe							por2_valefe
					,valefeoper						por2_valEfeOper
					,amortizacion					por2_amortizacion
					,itrans							por2_itrans
					,iAmortizacion					por2_iAmortizacion

					,tiv_precio
					,por_id							por2_por_id
					,tiv_id							por2_tiv_id
					,htp_numeracion					por2_htp_numeracion
					,tfcorte						por2_tfcorte
					,fecha_compra					por2_fecha_compra
					,htp_precio_compra				por2_precio_compra
					--,valefeoper					por2_valefeoper
					,htp_compra						por2_compra
					,liq_rendimiento				por2_rendimiento
					--,accrual						por2_accrual
					,latest_inicio					por2_latest_inicio
					,tpo_tipo_valoracion			por2_tipo_valoracion
					,sal							por2_sal
					,dias_al_corte					por2_dias_al_corte
					,prox_capital					por2_prox_capital
					,prox_interes					por2_prox_interes
					,pais							por2_pais
					,por_nombre						por2_por_nombre
					,sector_general					por2_sector_general
					,tvl_generico					por2_tvl_generico
					,tpo_custodio					por2_tpo_custodio
					,tpo_categoria					por2_tpo_categoria
					,civ_siglas						por2_civ_siglas
					,civ_descripcion				por2_civ_descripcion
					,civ_prefijo_cuenta				por2_civ_prefijo_cuenta
					,bde_cta_nombre					por2_bde_cta_nombre
					,bde_cta_descripcion			por2_bde_cta_descripcion
					,cortenum						por2_cortenum
					,vpr_duracion_efectiva_anual 	por2_duracion_efectiva_anual
					,vpr_duracion_modificada_anual	por2_duracion_modificada_anual
					,max_precio_compra
					,max_fecha_compra
					
					,max_interes
					,max_comision_bolsa
					,max_comision_casa
					,pond_rendimiento
					,precio_sin_redondear
					--				,costo_amortizado
					,liq_bolsa						por2_bolsa
					,liq_numero_bolsa				por2_numero_bolsa
					,(select top 1 valor from bvq_administracion.RankedCalificacion where tiv_id=portafoliocorte.tiv_id and fecha_desde<=fecha_compra) por2_calif_compra
					,prf_descripcion
					
					,GRP_ID
					,TPO_COBRO_CUPON 				HTP_CUPON
					,sal 							HTP_SALDO_C
					,HTTPO_ID 						TPO_ID_C
					,HTP_PRECIO_COMPRA
					,TPO_CATEGORIA 					HTP_CATEGORIA
					,HTP_NUMERACION
					,HTTPO_ID 						HTP_TPO_ID
					,TIV_ID
					,POR_ID

					,pond_precio_compra
					,sum_ve
					,ult_liq_id

					--6-4-2022
					,vpr_tasa_descuento
					--,vpr_rendimiento_equivalente
					from bvq_backoffice.portafoliocorte
				) por2
				--on por2_por_id=bvq_backoffice.portafolio.por_id and por2_tiv_id=ht.tiv_id and isnull(por2_htp_numeracion,'')=isnull(ht.htp_numeracion,'') and por2_tpo_categoria=ht.htp_categoria 
				on por2_por_id=portafolio.por_id
				and por2_tfcorte=@i_fecha 
				left join
				(
					select
					accrual							porant_accrual,
					valefe							porant_valefe,
					valefeoper						porant_valEfeOper,
					amortizacion					porant_amortizacion,
					itrans							porant_itrans,
					iAmortizacion					porant_iAmortizacion,
					httpo_id						porant_httpo_id,
					sal								porant_sal,
					precio_sin_redondear			porant_tiv_precio,
					por_id							porant_por_id,
					tiv_id							porant_tiv_id,
					htp_numeracion					porant_htp_numeracion,
					cortenum						porant_cortenum,
					vpr_duracion_efectiva_anual		porant_duracion_efectiva_anual,
					vpr_duracion_modificada_anual	porant_duracion_modificada_anual
					from bvq_backoffice.portafoliocorte
				) porant
				on porant_httpo_id=por2.tpo_id_c
				and porant_cortenum=por2_cortenum-1
	
				join BVQ_ADMINISTRACION.TITULO_VALOR 
				on por2.TIV_ID = BVQ_ADMINISTRACION.TITULO_VALOR.TIV_ID
				join bvq_administracion.tipo_valor tvl on tiv_tipo_valor=tvl.tvl_id
				join bvq_administracion.item_catalogo tba on tiv_tipo_base=tba.itc_id
				INNER JOIN BVQ_ADMINISTRACION.MONEDA MON ON BVQ_ADMINISTRACION.TITULO_VALOR.TIV_MONEDA = MON_ID
				/*left join
				(
					select v_id_estado_port_rev=itc_id
					from bvq_administracion.catalogoitemcatalogo
					where cat_codigo='BCK_ES_TIT_POR' and itc_codigo='R'
				) ic1 on 1=1

				AND  por2.HTP_ESTADO <> v_id_estado_port_rev
				AND isnull( por2.HTP_REPORTADO, 0 )  = 0*/
				left join
				BVQ_ADMINISTRACION.tfRankedCalificacion(@i_fecha) calif 
				join bvq_administracion.calificadoras cal on calif.cal_id=cal.cal_id
				on calif.tiv_id=por2.tiv_id and calif.rownum=1
				left join
				BVQ_ADMINISTRACION.tfRankedCalificacion(@i_fecha) califOrig
				on califOrig.tiv_id=por2.tiv_id and califOrig.rownum=1

				left join
				(
					select row_number() over (partition by emi_id order by eca_fecha_resolucion desc,eca_id desc) r,emi_id,eca_valor
					,cal_nombre eca_nombre
					,cal_nombre_personalizado eca_nombre_personalizado
					,eca_fecha_resolucion
					from bvq_administracion.emisores_calificacion eca
					join bvq_administracion.calificadoras cal on eca.cal_id=cal.cal_id
					where eca_estado=21 and (eca_fecha_resolucion is null or eca_fecha_resolucion<=@i_fecha)
				) emical on (tvl_generico=1 or tiv_tipo_valor in (/*10,*/13)) and emical.emi_id=tiv_emisor and emical.r=1
				left join bvq_administracion.item_catalogo tplazo on tplazo.itc_id=tiv_plazo
				left join
				(
					SELECT v_tasaFija = ITC_NOMBRE, v_tasaFijaId = ITC_ID 
					FROM bvq_administracion.catalogoitemcatalogo
					where ITC_CODIGO = 'FLAT_RATE' AND  CAT_CODIGO = 'BCK_TYPE_RATE'
				) icTasaFija on 1=1
				left join(
					-- EN @v_tipo_renta se almacena el tipo de renta variable
					SELECT v_tipo_renta = ITC_ID
					FROM bvq_administracion.catalogoitemcatalogo WHERE ITC_codigo = 'REN_VARIABLE' AND CAT_CODIGO = 'TIPO_RENTA'
				) icTipoRenta on 1=1
				left join 
				(
						SELECT
						VALOR_EFECTIVO_HISTORICO=(sum(HTP_PRECIO_COMPRA*HTP_COMPRA) over (partition by hpor.por_id,hpor.tiv_id,hpor.htp_cupon,isnull(htp_numeracion,'')))
						/
						case TIV_TIPO_RENTA WHEN  v_tipo_renta THEN 1.0 ELSE 100.0 END,
						R=row_number() over (
							partition by hpor.por_id,hpor.tiv_id,hpor.htp_cupon,isnull(hpor.htp_numeracion,''),hpor.htp_categoria
							order by htp_fecha_operacion desc,htp_id desc
						)
						,HTP_ID
						,tpo_id_c
						
						FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HPOR INNER JOIN BVQ_ADMINISTRACION.TITULO_VALOR TIV ON HPOR.TIV_ID=TIV.TIV_ID
						left join (select v_id_estado_port=itc_id	from bvq_administracion.catalogoitemcatalogo where cat_codigo='BCK_ES_TIT_POR' and itc_codigo='C') ic0 on 1=1
						left join (select v_id_estado_port_rev=itc_id	from bvq_administracion.catalogoitemcatalogo where cat_codigo='BCK_ES_TIT_POR' and itc_codigo='R') ic1 on 1=1
						left join (select v_id_estado_eli=itc_id	from bvq_administracion.catalogoitemcatalogo where cat_codigo='BCK_ES_TIT_POR' and itc_codigo='E') ic2 on 1=1
						left join(
							-- EN @v_tipo_renta se almacena el tipo de renta variable
							SELECT v_tipo_renta = ITC_ID
							FROM bvq_administracion.catalogoitemcatalogo WHERE ITC_codigo = 'REN_VARIABLE' AND CAT_CODIGO = 'TIPO_RENTA'
						) icTipoRenta on 1=1
						WHERE
						(HPOR.POR_ID = @i_idPortfolio or @i_idPortfolio is null) and 
						HPOR.HTP_FECHA_OPERACION <= @i_fecha	and--(datediff(dd, HPOR.HTP_FECHA_OPERACION, @i_fecha) >= 0) and
						ISNULL( HPOR.HTP_REPORTADO , 0)= 0 AND HPOR.HTP_ESTADO not in
						( 
							v_id_estado_port_rev,
							v_id_estado_port,
							v_id_estado_eli
						)
						--and 1=0
				)
				b on /*1=0*/por2.HTP_TPO_ID=b.tpo_id_c
				and b.R=1
				join bvq_administracion.emisor ems on ems_id=tiv_emisor


				
				left join bvq_prevencion.personacomitente per on per.ctc_id=portafolio.ctc_id
				left join bvq_administracion.item_catalogo tivTipo on tivTipo.itc_id=bvq_administracion.titulo_valor.tiv_tipo
				left join bvq_backoffice.seb_frecuencia_titulo frec_cap on frec_cap.sft_valor=bvq_administracion.titulo_valor.TIV_PERIODO_CAPITAL_SEB
				left join bvq_backoffice.seb_frecuencia_titulo frec_int on frec_int.sft_valor=bvq_administracion.titulo_valor.TIV_FRECUENCIA_SEB
				left join bvq_backoffice.liquidacion liq on liq.liq_id=por2.ult_liq_id
				left join bvq_backoffice.aceptante acep on liq.acp_id=acep.acp_id
	WHERE	(por2.POR_ID = @i_idPortfolio or @i_idPortfolio is null)
			--AND
			--por2.HTP_FECHA_OPERACION <= @i_fecha
	union all
	/*
	--efectivo en portafolio
	INSERT INTO @v_tabla*/
	SELECT	POR_CODIGO = '', 
	EMISOR = '',
	PAIS = '',
	SECTOR = '',
	TIPO_RENTA = '',
	TIPO_VALOR = '', 
	GENERICO = null,
	SUBTIPO = '',
	GRP_ID = 0,
	TIV_PLAZO_REMANENTE = 0,
	
	TIPO_TASA = '',
	TIPO_TASA_ID = 0,
	TIV_TASA_INTERES = 0,
	TPO_SALDO = 0,
	TIV_PRECIO_SPOT = 0,
	VALOR_EFECTIVO =  (SELECT TOP 1 VEP.VEP_VALOR_EFECTIVO FROM BVQ_BACKOFFICE.VALOR_EFECTIVO_PORTAFOLIO WHERE POR_ID  = @i_idPortfolio AND  (datediff(dd, VEP_FECHA, @i_fecha) >= 0) ORDER BY VEP_ID DESC),
	POR_ID  = @i_idPortfolio,	
	TIV_ID = 0, 
	TPO_CANTIDAD = 0, 
           	TPO_ESTADO = 0, 
	TIV_CODIGO =  MON.MON_CODIGO_ISO,                       
	   -- TIV_FECHA_VENCIMIENTO = '', 
	TIV_RENDIMIENTO = 0,
	TEA=null,
	(0.0) as INTERES_ACUMULADO,
	 TIV_TASA_MARGEN = 0, 
	TIV_TASA_CUPON_REMANENTE = 0,
	MON_NOMBRE = MON.MON_NOMBRE ,
	TPO_PRECIO_INGRESO = 0,
	TPO_COBRO_CUPON = 0,
	TIV_TIPO_RENTA = '',
	MON_CODIGO_ISO = '',
	TIV_PLAZO  = '', 
	TIV_SUBTIPO = '' ,
	TIV_SECTOR = '', 
	TIV_TIPO_VALOR = '',
	TIV_MONEDA = 0,
	TIV_CODIGO_SIC = null,
	TIV_CODIGO_GEN_SIC=null,
	HTP_CUPON = 0, 
	ESTADO_REP = (SELECT IT.ITC_VALOR FROM BVQ_ADMINISTRACION.ITEM_CATALOGO IT INNER JOIN BVQ_ADMINISTRACION.CATALOGO CAT
	ON IT.CAT_ID = CAT.CAT_ID AND CAT_CODIGO = 'BCK_EST_POR_REP' AND IT.ITC_CODIGO = 'DISPONIBLE')

	-- NIF
	, TPO_CATEGORIA = ''
	-- FIN NIF
	, TIV_FECHA_VENCIMIENTO='1900-1-1'
	, TIV_FECHA_EMISION='1900-1-1'
	, PRECIO_PONDERADO = 0
	, VALOR_EFECTIVO_A_PRECIO_PONDERADO = 0
	, ACUMULADO = 0
	,TIV_DESMATERIALIZADO = 0
	   ,HTP_NUMERACION=''
	,TIV_DESMATERIALIZADO_NOMBRE=''
	,VALOR_NOMINAL_DENTRO_DE_ACCIONES=0
	,CANTIDAD=0
	,TIV_VALOR_NOMINAL=0
	,TIV_TIPO_BASE=0
	,TPO_ID_C=NULL
	,valor=NULL
	,calificadora=NULL
	,califOrig=NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL

	
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL	--por2_sal
	,NULL
	,NULL	--por2_prox_capital
	,NULL	--por2_prox_interes
	,por2_por_nombre=null
	,por2_sector_general=null

	,NULL
	,NULL
	,NULL
	,NULL
	,NULL
	,NULL	-- porant_sal
	,NULL	-- porant_tiv_precio
	,NULL	-- porant_accrual
	
	,TIV_PERIODO_CAPITAL_SEB=NULL
	,TIV_FRECUENCIA_SEB=NULL
	,PERIODO_INTERES=NULL
	,PERIODO_CAPITAL=NULL
	,vn_orig=NULL
	,pond_rendimiento=NULL

	,max_interes=NULL
	,max_comision_bolsa=NULL
	,max_comision_casa=NULL
	,max_fecha_compra=NULL
	,nombre_comitente=NULL
	,porant_duracion_efectiva_anual=NULL
	,porant_duracion_modificada_anual=NULL
	,ems_codigo_sic2=NULL
	,tiv_precio_sin_redondear=NULL
	,TIV_TIPO=NULL
	,registrado=NULL
	,por2_bolsa=NULL
	,por2_numero_bolsa=NULL
	,TIV_CODIGO_BVQ=NULL
	,apreciacion=NULL
	,TIV_NUMERO_EMISION_SEB=NULL
	,TIV_MONTO_EMISION=NULL
	,prf_descripcion=NULL
	,por2_duracion_efectiva_anual=NULL
	,por2_duracion_modificada_anual=NULL

	--Columna por_public
	,POR_PUBLIC

	--Columnas Banrio, por2_compra/por2_ve_compra
	,NULL

	--Columna por2_compra
	,null

	,NULL
	
	--Ultima liq_id
	,NULL
	,NULL
	,NULL
	
	-- 6-4-2022
	,vpr_tasa_descuento=NULL
	--,vpr_rendimiento_equivalente=null

	FROM BVQ_BACKOFFICE.VALOR_EFECTIVO_PORTAFOLIO VEP INNER JOIN BVQ_ADMINISTRACION.MONEDA MON
	ON VEP.MON_ID = MON.MON_ID
	AND VEP_ID = (SELECT  MAX(V.VEP_ID) FROM BVQ_BACKOFFICE.VALOR_EFECTIVO_PORTAFOLIO  V WHERE V.POR_ID = @i_idPortfolio AND  (datediff(dd, V.VEP_FECHA, @i_fecha) >= 0) )
	
	--Columna por_public
	JOIN (select por_public,POR_ID from BVQ_BACKOFFICE.PORTAFOLIO) POR ON POR.POR_ID=VEP.POR_ID
	
	WHERE (VEP.POR_ID = @i_idPortfolio or @i_idPortfolio is null)

	--bb
	--)
	return-- @v_tabla
end
