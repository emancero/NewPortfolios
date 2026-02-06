CREATE view BVQ_BACKOFFICE.EstructuraIsspolView as
	select
	 Interes_Acumulado=evp.itrans
	,[Vector_Precio]=tiv_codigo_vector
	,[Fecha_Vencimiento]=tiv.TIV_FECHA_VENCIMIENTO
	--,[Valor nominal]=valor_nominal
	,[Fecha_Compra]=htp_fecha_operacion--fecha_valor_de_compra

	,[TIPO_ID_EMISOR]='R'
	,[ID_EMISOR]=pju.pju_identificacion
	,[Codigo_Instrumento]=bvq_administracion.GetIdentifierCode(
		 tiv_codigo_vector
		,tiv_codigo_isin)
	,[Tipo_Instrumento]=TVS.TVS_CODIGO
	,[id_Instrumento]=case bvq_administracion.GetIdentifierCode(tiv_codigo_vector,TIV_CODIGO_ISIN)
		when '07' then rtrim(TIV_CODIGO_VECTOR)
		when '01' then TIV_CODIGO_ISIN
		when '00' then ''
	 end
	,[Bolsa_Valores]=case opc_procedencia when 'G' then 'Y' else opc_procedencia end
	,[Fecha_Emision]=tiv.TIV_FECHA_EMISION
	,[Tipo_Tasa]=case when tiv.tiv_tipo_renta=153 then
		case
		when tiv.tiv_subtipo=3 then 'C'
		when tiv.tiv_tipo_tasa=365 then 'F'
		else 'V'
		end
	 end
	,[Base_Tasa_Interes]=case when tiv.tiv_tipo_renta=153 then
		iif(tiv.tiv_tipo_base=354,1,2)
	 end

	 
	,[Tasa_Nominal]=case when tiv.tiv_tipo_renta=153 then
		case when tiv.tiv_tipo_tasa=365 then tiv.tiv_tasa_interes
		else tiv.tiv_tasa_margen + bvq_administracion.fnObtenerValorTasaPorTituloYFecha(tiv.tiv_id,evp.htp_fecha_operacion)
		end
	 end
	,[Valor_Nominal]=evp.montooper * case when tiv.tiv_tipo_renta=154 then coalesce(VNU_VALOR,tiv.[TIV_VALOR_NOMINAL]) end
	,[Precio_Compra]=evp.htp_precio_compra
	,[Valor_Efectivo_Libros]=evp.valorEfectivo
	,[Plazo_Inicial]=dbo.fnDias(evp.htp_fecha_operacion,tiv.tiv_fecha_vencimiento,tiv.tiv_tipo_base)

	,Calificadora_Riesgo_Emision=csm.CSM_CODIGO
		--coalesce(
		-- rtrim(emscal.enc_nombre)+' - '+convert(varchar,emscal.ENC_FECHA_DESDE,103)
		--,[TCA_NOMBRE]--CAL_NOMBRE
		--,rtrim(emical.eca_nombre)+' - '+convert(varchar,emical.eca_fecha_resolucion,103)
		--,'NO DISPONIBLE')
	,Calificacion_Riesgo_Emision=coalesce(
		emscal.[ENC_VALOR]
		,eca_valor
		,[TCA_VALOR]
		,'NO DISPONIBLE')
	,[Fecha_Ultima_Calificacion]=coalesce(
		 emscal.ENC_FECHA_DESDE
		,tcacal.TCA_FECHA_DESDE
		,emical.eca_fecha_resolucion
		,'')
	,[Numero_Acciones]=case when tiv.tiv_tipo_renta=154 then evp.montooper end
	,[Valor_Accion]=case when tiv.tiv_tipo_renta=154 then coalesce(VNU_VALOR,tiv.[TIV_VALOR_NOMINAL]) end
	,[Precio_Mercado]=
		case when oper=-1 then
			precio_de_mercado
		else
			(select top 1 precio_de_mercado from BVQ_BACKOFFICE.VALORACION_SB v where v.tiv_id=tiv.tiv_id and v.htp_fecha_operacion=evp.htp_fecha_operacion)
		end
	,[Valor_Mercado]=
		case when oper=-1 then
			Valor_Mercado
		else 
			(select top 1 Valor_Mercado from BVQ_BACKOFFICE.VALORACION_SB v where v.tiv_id=tiv.tiv_id and v.htp_fecha_operacion=evp.htp_fecha_operacion)
		end
	,[Fecha_Precio_Mercado]=evp.htp_fecha_operacion--case when tiv.tiv_tipo_renta=153 and datediff(d,evp.htp_fecha_operacion,tiv.tiv_fecha_vencimiento)<=365 and tiv.tiv_subtipo not in (3) and esCxc=0 then
		--ult_valoracion
	--end 
	--sp_helptext 'bvq_administracion.prepararvaloracionlinealcache'
	,[Fondo_Inversion]=null
	
	,[Periodo_Amortizacion_codigo]=case when tiv.tiv_id in (7891) or tiv.tiv_id between 7906 and 7912 then null else p.codigo end
	,[Periodo_Amortizacion]=case when tiv.tiv_id in (7891) or tiv.tiv_id between 7906 and 7912 then 'ND - 2 periodos' else p.nombre end
	,[Periodicidad_Cupon_codigo]=p.codigo
	,[Periodicidad_Cupon]=p.nombre
	,[Casa_de_Valores_codigo]=CVA_CODIGO_SB--sbCod
	,[Casa_Valores]=opc.PJU_RAZON_SOCIAL
	,[Tipo_Id_Custodio]=case opc_Via when 0 then 'R' when 1 then 'R' end
	,numero_resolucion=FON_NUMERO_RESOLUCION
	,[Resolucion_Decreto]=case when tiv.tiv_tipo_valor=3 then evp.tpo_acta else tiv_numero_supercias end
	,[Nro_de_Inscripcion_Decreto]=null
	,[Inscripcion_CPMV]=tiv_numero_rmv
	,Id_Custodio=case opc_Via when 0 then '0991283765001' when 1 then '1760002600001' end

	,[Numero_liquidacion]=coalesce(fon.FON_NUMERO_LIQUIDACION,fon.FON_NUMLIQ_TEMP)
	,[Tipo_transaccion]=case oper when 0 then 'L' when 1 then 'P' when -1 then 'V' end
	,[Fecha_transaccion]=htp_fecha_operacion
	,[Dias_transcurridos]=dbo.fnDias(tfl.TFL_FECHA_INICIO,evp.htp_fecha_operacion,tiv.TIV_TIPO_BASE)
	,[Dias_por_vencer]=dbo.fnDias(evp.htp_fecha_operacion,tfl.TFL_FECHA_VENCIMIENTO,tiv.TIV_TIPO_BASE)
	,[Fuente_Cotizacion]='Q'
	,[Yield]=case when tiv.TIV_FECHA_VENCIMIENTO<dateadd(yy,1,evp.htp_fecha_operacion) /*porque se pide que la inversión sea menor a un año*/
		and
		round(tasa_cupon,2)=0 --por que se pide que sean solo papeles con cupón 0
		or 1=1
		then liq_rendimiento end
	,oper
	,esCxc
	,valor_pago_capital
	,valor_pago_cupon
	,Fecha_Ultimo_Pago
	,Saldo_Valor_Nominal
	,tiv.tiv_tipo_renta
	,[Pago_dividendo_en_acciones]=0
	,[Pago_dividendo_efectivo]=0
	,evp.FON_ID
	--,fovf=convert(datetime,case when datediff(d,evp.htp_fecha_operacion,tiv.tiv_fecha_vencimiento)<=365 and tiv.tiv_subtipo not in (3) then ult_valoracion else htp_fecha_operacion end)
	from
	(
	--drop table _temp.pc
		select
		 htp_fecha_operacion
		,montooper=sum(montooper)
		,itrans=sum(itrans)--o sum(TPO_INTERES_TRANSCURRIDO)
		,tpo_numeracion
		,oper
		,htp_precio_compra=min(evp.htp_precio_compra)--fecha_operacion
		,tasa_cupon=max(tasa_cupon)
		,liq_rendimiento=max(liq_rendimiento)
		,valorEfectivo=
		sum(
			--(case when min_tiene_valnom=1 or min_tiene_valnom=0 and httpo_id<1500 then

		  isnull([TPO_INTERES_TRANSCURRIDO],0) + isnull([TPO_COMISION_BOLSA],0)
		  --+ [htp_compra]*[htp_precio_compra]
		  +
		  coalesce(
			case when tpo_numeracion in ('ATX-2025-04-24','ATX-2025-04-25')
			then valnomCompraAnterior end,[montooper]
		  )
		  *
		  coalesce(
			case when tpo_numeracion in ('ATX-2025-04-24','ATX-2025-04-25')
			then precioCompraAnterior end, [htp_precio_compra]
		  )
		  /case when [tiv_tipo_renta]=153 then 100e else 1e end
	   --end)
	   )
	   ,tpo.tiv_id
	   ,fon_id=max(tpo.fon_id)
	   ,esCxc=max(isnull(ipr_es_cxc,0))
	   ,tpo_acta=max(tpo.tpo_acta)
	   ,valor_pago_capital=null
	   ,valor_pago_cupon=null
	   ,Fecha_Ultimo_Pago=null
	   ,Saldo_Valor_Nominal=sum(evp.saldo)
	   ,Precio_de_mercado=null
	   ,Valor_Mercado=null
	   ,TPO_MANTIENE_VECTOR_PRECIO=max(convert(int,tpo_mantiene_vector_precio))
	   ,evp_fecha_compra=htp_fecha_operacion
	   ,dividendo_en_efectivo=null
	   --,evt_fecha
	   --select tfl_fecha_inicio,tfl_fecha_inicio_orig,htp_fecha_operacion,tiv_tipo_base--*
	   --into _temp.pc
		from bvq_backoffice.EventoPortafolio evp
		join bvq_backoffice.titulos_portafolio tpo on tpo.tpo_id=evp.htp_tpo_id
		left join bvq_backoffice.ISSPOL_PROGS ipr on ipr.IPR_NOMBRE_PROG=tpo.tpo_prog
		left join (select valnomCompraAnterior=tpo_cantidad, precioCompraAnterior=tpo_precio_ingreso, tpo_id from BVQ_BACKOFFICE.titulos_portafolio) tpo2 on tpo2.tpo_id=tpo.tpo_id_anterior
		where montooper>0 and oper=0 --and htp_fecha_operacion between '20251101' and '2025-11-30T23:59:59'
		group by tpo_numeracion,oper,htp_fecha_operacion,tpo.tiv_id
		--having 1=0
		union all

		select
		 evp.fecha
		,montooper=sum(evp.montooper)
		,itrans=sum(itrans)--o sum(TPO_INTERES_TRANSCURRIDO)
		,evp.tpo_numeracion
		,oper
		,htp_precio_compra=min(tpo_precio_ingreso)--evp.htp_precio_compra)--fecha_operacion
		,tasa_cupon=max(tasa_cupon)
		,liq_rendimiento=max(liq_rendimiento)
		,valorEfectivo=sum(prEfectivo*evp.htp_compra)
		/*sum(
			--(case when min_tiene_valnom=1 or min_tiene_valnom=0 and httpo_id<1500 then

		  isnull(s.[TPO_INTERES_TRANSCURRIDO],0) + isnull(s.[TPO_COMISION_BOLSA],0)
		  --+ [htp_compra]*[htp_precio_compra]
		  +
		  coalesce(
			case when evp.tpo_numeracion in ('ATX-2025-04-24','ATX-2025-04-25')
			then valnomCompraAnterior end,[montooper]
		  )
		  *
		  coalesce(
			case when evp.tpo_numeracion in ('ATX-2025-04-24','ATX-2025-04-25')
			then precioCompraAnterior end, [htp_precio_compra]
		  )
		  /case when [tiv_tipo_renta]=153 then 100e else 1e end
	   --end)
	   )*/
	   ,tpo.tiv_id
	   ,fon_id=max(tpo.fon_id)
	   ,esCxc=convert(bit,max(isnull(convert(int,ipr_es_cxc),0)))
	   ,tpo_acta=max(tpo.tpo_acta)




	   ,valor_pago_capital=sum(
			case when isnull(htp_dividendo,0)=0 and es_vencimiento_interes=0 then
				case when evp_abono=1 then vep_valor_efectivo else amount end
			end
		)

	   ,valor_pago_cupon=sum(
			case when tiv_tipo_renta<>154 and es_vencimiento_interes=1 then
				case when evp_abono=1 then isnull(prEfectivo*capMonto,0)+vep_valor_efectivo-isnull(capMonto,0) else amount end
			end
		)
	   ,Fecha_Ultimo_Pago=evp.fecha
	   ,Saldo_Valor_Nominal=sum(evp.saldo)-isnull(sum(case when es_vencimiento_interes=0 then amount end),0)
	   ,Precio_de_mercado=null
	   ,Valor_Mercado=null
	   --,evt_fecha
	   --select tfl_fecha_inicio,tfl_fecha_inicio_orig,htp_fecha_operacion,tiv_tipo_base--*
		--select *
	   ,TPO_MANTIENE_VECTOR_PRECIO=max(convert(int,tpo_mantiene_vector_precio))
	   ,evp_fecha_compra=min(case when oper=0 then evp.htp_fecha_operacion end)
	   ,dividendo_en_efectivo=sum(case when tiv_tipo_renta=154 and es_vencimiento_interes=1 then amount end)
		from bvq_backoffice.LiqIntProv evp
		left join BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO htp on evp.oper=0 and evp.htp_id=htp.htp_id and htp_dividendo=1
			--join (
			--	select r=row_number() over (partition by htp_tpo_id order by htp_fecha_operacion, htp_id), tpo_interes_transcurrido,tpo_comision_bolsa,htp_precio_compra,e.htp_tpo_id
			--	from bvq_backoffice.eventoportafolio e
			--	join bvq_backoffice.titulos_portafolio tpo on e.htp_tpo_id=tpo.tpo_id
			--	where montooper>0
			--) s on s.htp_tpo_id=evp.htp_tpo_id and r=1

		join bvq_backoffice.titulos_portafolio tpo on tpo.tpo_id=evp.htp_tpo_id
		left join (select valnomCompraAnterior=tpo_cantidad, precioCompraAnterior=tpo_precio_ingreso, tpo_id from BVQ_BACKOFFICE.titulos_portafolio) tpo2 on tpo2.tpo_id=tpo.tpo_id_anterior
		where oper=1 or htp_dividendo=1
		--and fecha between '20251101' and '20251130'

		group by evp.tpo_numeracion,oper,fecha,tpo.tiv_id--,htp_fecha_operacion
		--having 1=0
		union all
		--select * from _temp.pc
		--drop table _temp.pc
		select
		 htp_fecha_operacion--=tfcorte
		,montooper--=sum(sal)
		,itrans--=sum(itrans)
		,tpo_numeracion--=htp_numeracion
		,oper--=-1
		,htp_precio_compra--=max(precio_de_hoy)
		,tasa_cupon--=max(tiv_tasa_interes)
		,liq_rendimiento--=max(htp_rendimiento)
		,valorEfectivo--=sum(valEfeOper)
		,tiv_id
		,fon_id--=max(tpo.fon_id)
	    ,esCxc--=max(isnull(ipr_es_cxc,0))
		,tpo_acta--=max(pc.tpo_acta)
	    ,valor_pago_capital--=null
	    ,valor_pago_cupon--=null
		,Fecha_Ultimo_Pago--=null
		,Saldo_Valor_Nominal--=sum(sal)
		,Precio_de_mercado--=sum(PRECIO_DE_HOY)
		,Valor_Mercado
		,TPO_MANTIENE_VECTOR_PRECIO--=max(convert(int,pc.TPO_MANTIENE_VECTOR_PRECIO))
		,evp_fecha_compra--=min(pc.fecha_compra)
		,dividendo_en_efectivo=null
		from BVQ_BACKOFFICE.VALORACION_SB--_temp.valoracionSB
		--from bvq_backoffice.portafolioCortePrcInt pc
		--join bvq_backoffice.titulos_portafolio tpo on pc.httpo_id=tpo.tpo_id
		--where sal>0
		--group by htp_numeracion,tfcorte,pc.tiv_id
	) evp-- on evp.tpo_numeracion=tpo.tpo_numeracion
	
	
	
	--from
	--_temp.pc evp
	join bvq_administracion.titulo_valor tiv on tiv.tiv_id=evp.tiv_id
	join bvq_administracion.tipo_valor tvl on tvl.tvl_id=tiv.tiv_tipo_valor
	join bvq_administracion.TituloValorUltVal2 tivVal on tivVal.tiv_id=tiv.tiv_id
	join bvq_administracion.emisor ems on tiv.tiv_emisor=ems.ems_id
	left join bvq_administracion.PERSONA_JURIDICA pju on pju.pju_id=ems.pju_id
	join bvq_backoffice.fondo fon on fon.fon_id=evp.fon_id
	--número de resolución isspol
	--left join
	--	siisspolweb.siisspolweb.inversion.inversion i
	--	join siisspolweb.siisspolweb.inversion.int_inversion ii on ii.id_inversion=i.id_inversion
	--on fon.FON_ID_INT_INVERSION=ii.id_int_inversion
	--fin número resolución isspol

	--left join [192.168.2.225].isspoljun2025.dbo.aru_opecer opc
	--	join [192.168.2.225].isspoljun2025.dbo.aru_comven cve on cve.aru_cve_anoope=aru_opc_anoope and aru_cve_numope=aru_opc_NumOpe and aru_cve_Procedencia=aru_opc_Procedencia and aru_cve_estcomven=1
	--	join [192.168.2.225].isspoljun2025.dbo.asi_casval csv on csv.asi_csv_CodCasVal=aru_cve_CodCasVal
	--	left join _temp.casvalMap csvm on asi_csv_nomcasval=slcName collate modern_spanish_ci_as
	left join (
		--select CVA_CODIGO_SB,PJU_RAZON_SOCIAL,OPC_NUM_OPE,OPC_ANO_OPE,OPC_PROCEDENCIA,OPC_VIA
		--from _temp.opc
		--_temp.opc
		--select CVA_CODIGO_SB='',PJU_RAZON_SOCIAL='',OPC_NUM_OPE='',OPC_ANO_OPE='',OPC_PROCEDENCIA='',OPC_VIA=''
		select CVA_CODIGO_SB,PJU_RAZON_SOCIAL,OPC_NUM_OPE,OPC_ANO_OPE,OPC_PROCEDENCIA,OPC_VIA
		--into _temp.opc
		from 
		BVQ_BACKOFFICE.OPERACIONES_CERRADAS OPC
		left join bvq_administracion.casa_valores cva on opc.OPC_ABR_CAS_VAL=CVA.CVA_SIGLAS
		left join bvq_administracion.PERSONA_JURIDICA cvapju on cvapju.pju_id=cva.pju_id
	) opc
	--on aru_opc_numope =coalesce(fon.FON_NUMERO_LIQUIDACION,fon.FON_NUMLIQ_TEMP) and oper<>-1
	--and year(evp.htp_fecha_operacion)=year(aru_opc_fchval)
	--and aru_opc_Procedencia=fon.FON_PROCEDENCIA collate modern_spanish_ci_as-- and 1=0
	on OPC_NUM_OPE =coalesce(fon.FON_NUMERO_LIQUIDACION,fon.FON_NUMLIQ_TEMP) and oper<>-1
	and year(evp.htp_fecha_operacion)=OPC_ANO_OPE--year(OPC_FCH_VAL)
	and OPC_PROCEDENCIA=fon.FON_PROCEDENCIA collate modern_spanish_ci_as-- and 1=0
	left join bvq_administracion.TIPO_VALOR_SB tvs on TVS.TVS_TVL_ID=tiv.TIV_TIPO_VALOR
	left join bvq_administracion.periodicidadSB p on (tiv.tiv_tipo_base=354 and p.frec=tiv.tiv_frecuencia or tiv.tiv_tipo_base=355 and p.codigo='VC')-- and oper<>-1
--
    left join    
    (    
		select
		 isnull(lead(eca_fecha_resolucion) over (partition by emi_id order by eca_fecha_resolucion desc,eca_id desc),'99991231') eca_fecha_hasta
		,emi_id    
		,eca_valor     
		,cal_nombre eca_nombre    
		,cal_nombre_personalizado eca_nombre_personalizado    
		,eca_fecha_resolucion
		,eca.cal_id eca_cal_id
		from bvq_administracion.emisores_calificacion eca    
		join bvq_administracion.calificadoras cal on eca.cal_id=cal.cal_id    
		where eca_estado=21 --and (eca_fecha_resolucion is null or eca_fecha_resolucion<=(select c from corteslist))    
    ) emical on emical.emi_id=tiv_emisor and evp.htp_fecha_operacion>=isnull(eca_fecha_resolucion,0) and evp.htp_fecha_operacion<eca_fecha_hasta--emical.r=1--(tvl_generico=1 or tiv_tipo_valor in (/*10,*/13)) and emical.emi_id=tiv_emisor and emical.r=1  
    left join    
    (    
		select
		 isnull(lead(ENC_FECHA_DESDE) over (partition by enc.enc_numero_corto_emision order BY enc.ENC_FECHA_DESDE,enc.ENC_ID),'99991231') ENC_FECHA_HASTA
		,enc_numero_corto_emision
		,enc.ENC_VALOR 
		,cal_nombre enc_nombre    
		,cal_nombre_personalizado enc_nombre_personalizado    
		,enc.ENC_FECHA_DESDE  
		,enc.cal_id enc_cal_id
		FROM BVQ_ADMINISTRACION.EMISION_CALIFICACION enc   
		join bvq_administracion.calificadoras cal on enc.CAL_ID=cal.CAL_ID    
		where enc.ENC_ESTADO=21--and (enc.ENC_FECHA_DESDE is null or enc.ENC_FECHA_DESDE<=(select c from corteslist))    
    ) emscal on emscal.enc_numero_corto_emision=tiv.TIV_CODIGO_TITULO_SIC and evp.htp_fecha_operacion>=isnull(enc_fecha_desde,0) and evp.htp_fecha_operacion<enc_fecha_hasta--emscal.r=1  
	left join (
		select
		 isnull(lead(TCA_FECHA_DESDE) over (partition by tiv_id order by tca_fecha_desde,tca_id),'99991231') TCA_FECHA_HASTA
		,tiv_id
		,tca_valor
		,cal_nombre tca_nombre
		,CAL_NOMBRE_PERSONALIZADO tca_nombre_personalizado
		,TCA_FECHA_DESDE
		,tca.cal_id tca_cal_id
		from bvq_administracion.titulos_calificacion tca
		join bvq_administracion.calificadoras cal on tca.cal_id=cal.cal_id   
		where tca.TCA_ESTADO=21 --AND (TCA.TCA_FECHA_DESDE is null or tca.TCA_FECHA_DESDE<=FECHA_VALOR_DE_COMPRA)
	) tcacal on tcacal.tiv_id=tiv.tiv_id and evp.htp_fecha_operacion>=tca_fecha_desde and evp.htp_fecha_operacion<tca_fecha_hasta--tcacal.r=1  
	left join bvq_administracion.CALIFICADORA_SB_MAP csm on csm.csm_cal_id=coalesce(emscal.enc_cal_id,tcacal.tca_cal_id,emical.eca_cal_id)
	left join bvq_administracion.TituloFlujoCapital tfl
	on tiv.tiv_id=tfl.tiv_id and evp.htp_fecha_operacion>=isnull(tfl.tfl_fecha_inicio,0) and evp.htp_fecha_operacion<tfl.tfl_fecha_vencimiento
--
	left join BVQ_BACKOFFICE.VALOR_NOMINAL_UNITARIO VNU
	ON VNU.TIV_ID=tiv.TIV_ID and evp.htp_fecha_operacion>=VNU.VNU_FECHA_INICIO and evp.htp_fecha_operacion<VNU.VNU_FECHA_FIN
	--where not (oper=1 and isnull(valor_pago_cupon,0)<0.005 and isnull(valor_pago_capital,0)<0.005)