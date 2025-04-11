CREATE view bvq_backoffice.IsspolRentaFijaView as
  select     
 TVL_NOMBRE=TVL_NOMBRE,    
 CUENTA_CONTABLE=CUENTA_CONTABLE,    
 VECTOR_PRECIO=VECTOR_PRECIO,    
 TIPO=TIPO,    
 CUPON=CUPON,    
 PLAZO_PACTADO=PLAZO_PACTADO,    
 FECHA_VENCIMIENTO_CONVENIO_PAGO=FECHA_VENCIMIENTO_CONVENIO_PAGO,    
 FECHA_SUSCRIPCION_CONVENIO_PAGO=FECHA_SUSCRIPCION_CONVENIO_PAGO,    
 FECHA_DE_VENCIMIENTO=FECHA_DE_VENCIMIENTO,    
 DECRETO_EMISOR=DECRETO_EMISOR,    
 INTERVINIENTES=INTERVINIENTES,    
 VALOR_NOMINAL=sum(VALOR_NOMINAL),    
 VALOR_EFECTIVO=sum(VALOR_EFECTIVO),    
 INTERES_TRANSCURRIDO=sum(INTERES_TRANSCURRIDO),    
 PRECIO_DE_HOY=PRECIO_DE_HOY,    
 INTERES_ACUMULADO=sum(INTERES_ACUMULADO),    
 VALOR_DE_MERCADO=sum(VALOR_DE_MERCADO),    
 PCT_DEL_VALOR_DE_MERCADO=sum(PCT_DEL_VALOR_DE_MERCADO),    
 DIAS_POR_VENCER=DIAS_POR_VENCER,    
 FECHA_VALOR_DE_COMPRA=FECHA_VALOR_DE_COMPRA,    
 VALOR_EFECTIVO_HISTORICO=sum(VALOR_EFECTIVO_HISTORICO),    
 YIELD=YIELD,    
 PRECIO=PRECIO,    
 SECTOR=SECTOR,    
 MONTO_EMITIDO=MONTO_EMITIDO,    
 PATRIMONIO=PATRIMONIO,    
 CALIFICADORA_DE_RIESGO=CALIFICADORA_DE_RIESGO,    
 CALIFICACION_DE_RIESGO=CALIFICACION_DE_RIESGO,    
 VALOR_PROVISIONADO=sum(VALOR_PROVISIONADO),    
 FECHA_DE_PAGO_ULTIMO_CUPON=FECHA_DE_PAGO_ULTIMO_CUPON,    
 DIAS_DE_INTERES_GANADO=DIAS_DE_INTERES_GANADO,    
 INTERES_GANADO=sum(INTERES_GANADO),    
 INTERES_AL_VENCIMIENTO_ORIGINAL_=sum(INTERES_AL_VENCIMIENTO_ORIGINAL_),    
 INTERES_POR_DIAS_DE_RETRASO=sum(INTERES_POR_DIAS_DE_RETRASO),    
 PCT_A_AJUSTAR=PCT_A_AJUSTAR,    
 DIAS_POR_VENCER_COMPRA=DIAS_POR_VENCER_COMPRA,    
 PCT_AJUSTE_DIARIO=PCT_AJUSTE_DIARIO,    
 FACTOR_DE_AJUSTE=FACTOR_DE_AJUSTE,    
 CONTROLADOR_SECTOR=CONTROLADOR_SECTOR,    
 CONTROLADOR_POSICION=CONTROLADOR_POSICION,    
 PRECIO_ULTIMA_COMPRA=PRECIO_ULTIMA_COMPRA,    
 FECHA_ULTIMA_COMPRA=FECHA_ULTIMA_COMPRA,    
 --FECHA_ULTIMA_COMPRA = @i_fechaCorte,
 BASE_DIAS_INTERES=BASE_DIAS_INTERES,    
 BASE_TASA_INTERES=BASE_TASA_INTERES,    
 PRECIO2=PRECIO2,    
 CUPON2=CUPON2,    
 CODIGO_TITULO=CODIGO_TITULO,    
 TIPO2=TIPO2,    
 VALORES_RECUPERADOS=sum(VALORES_RECUPERADOS),    
 ACCIONES_REALIZADAS=ACCIONES_REALIZADAS,    
 MANTIENE_VECTOR_PRECIO=MANTIENE_VECTOR_PRECIO,    
 ACP_ID=ACP_ID,    
 PROG=PROG,    
 FKOP=sum(FKOP),    
 ACTA=ACTA,    
 GCXC_NOMBRE=GCXC_NOMBRE,    
 TVL_CODIGO=TVL_CODIGO,    
 EMS_NOMBRE=EMS_NOMBRE,    
 TPO_F1=(case when TPO_DESGLOSAR_F1 = 1 then TPO_F1 end),      
 OTROS_COSTOS=OTROS_COSTOS,    
 COMISIONES=sum(COMISIONES),    
 TPO_PROG=TPO_PROG,    
 RECURSOS=RECURSOS,    
 TIV_VALOR_NOMINAL=TIV_VALOR_NOMINAL,    
 HTP_COMPRA=sum(HTP_COMPRA),    
 ABONO_INTERES=ABONO_INTERES,    
VALNOM_ANTERIOR=VALNOM_ANTERIOR,    
 FECHA_ENCARGO=FECHA_ENCARGO,    
 DIVIDENDOS_EN_ACCIONES=DIVIDENDOS_EN_ACCIONES,    
 asi_emi_codemi=asi_emi_codemi,    
 TPO_ORD=TPO_ORD, 
 GENERICO = s.GENERICO,
 ID_EMISOR = s.ID_EMISOR,
 --POR_SIGLAS = dbo.CLRSortedCssvAgg(POR_SIGLAS)
 por_siglas= (  
        SELECT
		STUFF((SELECT
				'-' + por.por_siglas
			FROM bvq_backoffice.titulos_portafolio p2
			JOIN bvq_backoffice.portafolio por
				ON por.por_id = p2.por_id
			WHERE
				p2.tpo_numeracion = s.htp_numeracion
				AND isnull(case when p2.TPO_DESGLOSAR_F1 = 1 then p2.TPO_F1 end,-1)=isnull(case when s.TPO_DESGLOSAR_F1 = 1 then s.TPO_F1 end,-1)
				--and isnull(p2.tpo_f1,-1)=isnull(s.tpo_f1,-1)
				AND tpo_estado = 352
				AND (min(min_tiene_valnom)=1 or min(min_tiene_valnom)=0 and p2.tpo_id<1500)
			ORDER BY por.por_ord
			FOR XML PATH(''))
		, 1, 1, '') ) ,
  s.htp_numeracion,
  ems_abr,
  s.tiv_id,
  s.tiv_split_de,
  s.tfcorte,
 -- SECTOR_DETALLADO=case when max(SECTOR_GENERAL)='SEC_PRI_FIN' then
	--case when EMS_NOMBRE collate modern_spanish_ci_ai like 'COOPERATIVA DE AHORRO Y CRÉDITO%' THEN 'ECONOMÍA POPULAR Y SOLIDARIA' else 'PRIVADO FINANCIERO' end
	--else SECTOR END
  SECTOR_DETALLADO=max(s.sector_detallado)
  from(
   select    
   TVL_NOMBRE=
        COALESCE(case when TVL_CODIGO='PCO' and tiv_subtipo=4 then 'PCI' end, TVLH_TIPOSC, TVL_CODIGO )
        +case when tiv_split_de is not null and tiv_split_de not in ('0','') then
            '-SUT2'
        when tiv_numero_tramo_sicav is not null then
            '-T'+ltrim(tiv_numero_tramo_sicav)
            +isnull('-S'+nullif(case when len(tiv_serie)<3 then TIV_SERIE end,''),'')
        when tvl_codigo in ('OCA') then
            ''
        else
            isnull('-C'+nullif(case when tiv_serie='UNO' then '1' else TIV_SERIE end,''),'')
        end,
   CUENTA_CONTABLE='7.1.5.90.90',    
   VECTOR_PRECIO = 
   case
    when [TPO_MANTIENE_VECTOR_PRECIO]=1 or
   isnull([IPR_ES_CXC],0)=0 
   or tvl_codigo in ('SWAP') then rtrim([TIV_CODIGO_VECTOR]) end,    
   TIPO=TVL_DESCRIPCION + isnull(' '+TIV_SERIE,''),    
   CUPON=[TIV_TASA_INTERES]/100.0,    
   PLAZO_PACTADO=dbo.fnDiaseu([FECHA_COMPRA],[TIV_FECHA_VENCIMIENTO],TIV_TIPO_BASE)
			+case when TVL_CODIGO = 'PCO' /*AND tiv_tasa_interes = 0*/ then
					bvq_administracion.fncalcularsiguientediatrabajo(dateadd(d,-1,tiv_fecha_vencimiento),1)-1
			else 0 end
   ,
   FECHA_VENCIMIENTO_CONVENIO_PAGO=TPO_FECHA_VEN_CONVENIO,    
   FECHA_SUSCRIPCION_CONVENIO_PAGO=TPO_FECHA_SUSC_CONVENIO,    
   FECHA_DE_VENCIMIENTO=tiv_fecha_vencimiento,    
   DECRETO_EMISOR= 
   case when tvl_codigo='BE' then
        tvl_codigo+' '+isnull(tpo_acta,'')
   else
        replace([EMS_NOMBRE] + isnull('/' + [ACP_NOMBRE],'') collate modern_spanish_ci_ai,'COOPERATIVA DE AHORRO Y CRÉDITO','CAC')
   end,
   --DECRETO_EMISOR= [EMS_NOMBRE] + isnull('/' + [ACP_NOMBRE],''),    
   INTERVINIENTES=TPO_INTERVINIENTES,    
   VALOR_NOMINAL=sal,    
   VALOR_EFECTIVO=case when [TPO_F1]=(select top 1 kf1 from keyf1 where natkey like 'MINISTERIO DE FINANZAS|20240620|20160108|%' and kf1=339) then    
       377916.44/873855.24*sal    
   when[TVL_CODIGO] in ('PCO') then sal*[htp_precio_compra]/100.0 else sal*[TIV_PRECIO]/100.0 end,    
   INTERES_TRANSCURRIDO=[TPO_INTERES_TRANSCURRIDO],    
   PRECIO_DE_HOY=case when tvl_codigo not in ('DER','OBL','PAG') then [TIV_PRECIO]/100.0 else null end,    
   INTERES_ACUMULADO=[dias_al_corte] * case when [TVL_CODIGO] in ('FAC','PCO') then [HTP_RENDIMIENTO] else [TIV_TASA_INTERES] end,    
   VALOR_DE_MERCADO=valefe,    
   PCT_DEL_VALOR_DE_MERCADO=[valefe],    
   DIAS_POR_VENCER=datediff(d,[tfcorte],[tiv_fecha_vencimiento]),    
   FECHA_VALOR_DE_COMPRA=fecha_compra,    
   VALOR_EFECTIVO_HISTORICO=
   case when min_tiene_valnom=1 or min_tiene_valnom=0 and httpo_id<1500 then
	  isnull([TPO_INTERES_TRANSCURRIDO],0) + isnull([TPO_COMISION_BOLSA],0) + [htp_compra]*[htp_precio_compra]/case when [tiv_tipo_renta]=153 then 100e else 1e end
   end,    
   YIELD =
   CASE
        WHEN [TVL_CODIGO] in ('FAC','PCO','OBL','OCA','VCC') THEN [HTP_RENDIMIENTO]
        ELSE [TIV_TASA_INTERES]
   END / 100.0,    
   PRECIO=htp_precio_compra,    
   SECTOR=CASE [sector_general] WHEN 'SEC_PRI_FIN' then 'PRIVADO FINANCIERO Y ECONOMÍA POPULAR SOLIDARIA' WHEN 'SEC_PRI_NFIN' THEN 'PRIVADO NO FINANCIERO' WHEN 'SEC_PUB_FIN' THEN 'PUBLICO' WHEN 'SEC_PUB_NFIN' THEN 'PUBLICO' END,    
   MONTO_EMITIDO= [TIV_MONTO_EMISION],    
   PATRIMONIO=[VBA_PATRIMONIO_TECNICO],    
   CALIFICADORA_DE_RIESGO=coalesce(
		 rtrim(emscal.enc_nombre)+' - '+convert(varchar,emscal.ENC_FECHA_DESDE,103),[CAL_NOMBRE]
		,rtrim(emical.eca_nombre)+' - '+convert(varchar,emical.eca_fecha_resolucion,103)
		,'NO DISPONIBLE'),    

   CALIFICACION_DE_RIESGO=coalesce(emscal.[ENC_VALOR],eca_valor,[TCA_VALOR],'NO DISPONIBLE'),       

   VALOR_PROVISIONADO=case when isnull(ipr_es_cxc,0)=1 then sal*[TIV_PRECIO]/100.0 else 0 end,    
   FECHA_DE_PAGO_ULTIMO_CUPON=latest_inicio,    
   DIAS_DE_INTERES_GANADO=
   case
        when tvl_codigo in
            ('FAC','PCO') and
            pc.tiv_tipo_base=355 and
            latest_inicio=fecha_compra and ipr_es_cxc=1 then datediff(d,tiv_fecha_vencimiento,tfcorte)
            else pc.dias_al_corte
   end,    
   INTERES_GANADO=
        case
            when tvl_codigo in
                ('FAC','PCO') and
                pc.tiv_tipo_base=355 and
                latest_inicio=fecha_compra and ipr_es_cxc=1 then datediff(d,tiv_fecha_vencimiento,tfcorte)
            else pc.dias_al_corte
        end
		/360.0 * sal * tiv_tasa_interes/100.0    
    /*case when tvl_codigo in ('FAC','PCO') and pc.tiv_tipo_base=355 and latest_inicio=fecha_compra then    
     datediff(d,tiv_fecha_vencimiento,tfcorte)    
    else pc.dias_al_corte end    
    *    
    CASE WHEN [TVL_CODIGO] in ('FAC','PCO','PACTO') THEN    
   (case when [TVL_CODIGO] in ('PCO') then sal*[htp_precio_compra]/100.0 else pc.valefe end + CASE WHEN TPO_INTERVINIENTES LIKE 'Capital Ventura%' THEN TPO_INTERES_TRANSCURRIDO ELSE 0 END)    
     *[HTP_RENDIMIENTO]/100.0/360.0    
    ELSE    
     (sal-isnull(TPO_VALNOM_ANTERIOR,0))    
     * [TIV_TASA_INTERES]    
     /100.0/360.0    
    END    
    - isnull(TPO_ABONO_INTERES,0)    */
   ,    
   INTERES_AL_VENCIMIENTO_ORIGINAL_=CASE WHEN [TPO_FECHA_SUSC_CONVENIO] is not null THEN
	[sal]*datediff(d,[FECHA_COMPRA],[TIV_FECHA_VENCIMIENTO])/360.0*CASE WHEN [TVL_CODIGO] in ('FAC','PCO') THEN 0/*[HTP_RENDIMIENTO]*/ ELSE [TIV_TASA_INTERES] END/100.0
	END    
    
    
    
  ,    
   INTERES_POR_DIAS_DE_RETRASO=CASE WHEN [TPO_FECHA_SUSC_CONVENIO] is not null THEN sal*[TIV_PRECIO]/100.0*datediff(d,[TIV_FECHA_VENCIMIENTO],[LATEST_INICIO])/360.0*CASE WHEN [TVL_CODIGO] in ('FAC','PCO') THEN [HTP_RENDIMIENTO] ELSE [TIV_TASA_INTERES] END

/100.0 END,    
   PCT_A_AJUSTAR=case when tvl_codigo not in ('DER','OBL','PAG') then 1-[TPO_PRECIO_ULTIMA_COMPRA] else null end,    
   DIAS_POR_VENCER_COMPRA=case when tvl_codigo not in ('DER','OBL','PAG') then datediff(d,[FECHA_COMPRA],[tiv_fecha_vencimiento]) else null end,    
   PCT_AJUSTE_DIARIO=case when tvl_codigo not in ('DER','OBL','PAG') then (1-[TPO_PRECIO_ULTIMA_COMPRA])/datediff(d,[FECHA_COMPRA],[tiv_fecha_vencimiento]) else null end,    
   FACTOR_DE_AJUSTE=case when tvl_codigo not in ('DER','OBL','PAG') then (1-[TPO_PRECIO_ULTIMA_COMPRA])/datediff(d,[FECHA_COMPRA],[tiv_fecha_vencimiento])*datediff(d,[FECHA_COMPRA],[TFCORTE]) else null end,    
   CONTROLADOR_SECTOR=CASE WHEN [SECTOR_GENERAL]='SEC_PRI_FIN' THEN 1 WHEN [SECTOR_GENERAL]='SEC_PRI_NFIN' THEN 2 WHEN [SECTOR_GENERAL] IN ('SEC_PUB_FIN','SEC_PUB_NFIN') THEN 3 ELSE 0 END,    
   CONTROLADOR_POSICION=CASE    
     WHEN datediff(d,[TFCORTE],[TIV_FECHA_VENCIMIENTO]) IS NULL THEN 0    
     WHEN datediff(d,[TFCORTE],[TIV_FECHA_VENCIMIENTO])<366 THEN 1    
     WHEN datediff(d,[TFCORTE],[TIV_FECHA_VENCIMIENTO])<1096 THEN 2    
     WHEN datediff(d,[TFCORTE],[TIV_FECHA_VENCIMIENTO])<1826 THEN 3    
     WHEN datediff(d,[TFCORTE],[TIV_FECHA_VENCIMIENTO])<3651 THEN 4    
     ELSE 5 END,    
   PRECIO_ULTIMA_COMPRA=TPO_PRECIO_ULTIMA_COMPRA,    
   --FECHA_ULTIMA_COMPRA=case when ipr_es_cxc=0 then tfcorte when tvl_codigo not in ('DER','OBL','PAG') then [fecha_compra] end,    
   
  FECHA_ULTIMA_COMPRA=
   case when isnull(rtrim(tiv_codigo_vector),'')<>'' and datediff(d,tfCorte,tiv_fecha_vencimiento)<=365 then
	lastValDate
   when isnull(rtrim(tiv_codigo_vector),'')='' then [fecha_compra]
   when isnull(rtrim(tiv_codigo_vector),'')<>'' and datediff(d,tfCorte,tiv_fecha_vencimiento)>365 then
	tfcorte
   end,

 BASE_DIAS_INTERES=CASE WHEN    
      [TIV_TIPO_BASE]=354    
      OR    
      isnull([IPR_ES_CXC],0)=0 AND [TVL_CODIGO] in ('CD','CI','PAC')--NOT IN ('PCO')
     THEN '360' WHEN [tiv_tipo_base]=355 THEN'REAL' ELSE '' END,    
   BASE_TASA_INTERES=360,    
   PRECIO2=case when TPO_MANTIENE_VECTOR_PRECIO=1 OR tiv_codigo_vector<>'' then [tiv_precio]/100.0 end,    
   CUPON2=case when tiv_codigo_vector not in ('0','') then [TIV_TASA_INTERES]/100.0 end,    
 CODIGO_TITULO=[TIV_CODIGO_VECTOR],    
   TIPO2=
  case when isnull(ipr_es_cxc,0)=0 then
        COALESCE(TVLH_TIPOSC, TVL_CODIGO ) + isnull(' '+TIV_SERIE,'') + isnull(' '+TPO_ACTA,'')
   else
        case when TPO_MANTIENE_VECTOR_PRECIO=1 OR tiv_codigo_vector<>'' then [TVL_CODIGO] + ' ' + CASE WHEN [tvl_codigo]='swap' THEN [TPO_ACTA] else [TIV_CLASE] END end
   end,    
   VALORES_RECUPERADOS=[htp_compra]-[sal],    
   ACCIONES_REALIZADAS=[TPO_OBJETO],    
   MANTIENE_VECTOR_PRECIO=TPO_MANTIENE_VECTOR_PRECIO,    
   ACP_ID=ACP_ID,    
   PROG=TPO_PROG,    
   FKOP=TPO_FKOP,    
   ACTA=TPO_ACTA,    
   GCXC_NOMBRE=[GCXC_NOMBRE],    
   TVL_CODIGO=[TVL_CODIGO],    
   EMS_NOMBRE=[EMS_NOMBRE],    
   TPO_F1=(case when TPO_DESGLOSAR_F1 = 1 then TPO_F1 end),    
   OTROS_COSTOS=TPO_OTROS_COSTOS,    
   COMISIONES=TPO_COMISION_BOLSA,    
   TPO_PROG=[TPO_PROG],    
   RECURSOS=[TPO_RECURSOS],    
   TIV_VALOR_NOMINAL=[TIV_VALOR_NOMINAL],    
   HTP_COMPRA=[htp_compra],    
ABONO_INTERES=TPO_ABONO_INTERES,    
   VALNOM_ANTERIOR=TPO_VALNOM_ANTERIOR,    
   FECHA_ENCARGO=TPO_FECHA_ENCARGO,    
   DIVIDENDOS_EN_ACCIONES=case when EMS_NOMBRE='RETRATOREC S.A.' and fecha_compra='20170331' then sal end,    
   asi_emi_codemi=asi_emi_codemi,    
   TPO_ORD=TPO_ORD,    
   --POR_SIGLAS = pc.POR_SIGLAS,    
   port.por_ord as orden, pc.htp_numeracion,  
   TIV_SERIE 
   ,TPO_DESGLOSAR_F1 
   ,GENERICO = pc.tvl_generico
   ,ID_EMISOR = pc.tiv_emisor
   ,pc.ems_abr
   ,pc.min_tiene_valnom
   ,pc.tiv_id
   ,pc.tiv_split_de
   ,pc.tfcorte
   ,pc.SECTOR_GENERAL
   ,pc.sector_detallado
   from bvq_backoffice.portafoliocorte pc    
  join BVQ_BACKOFFICE.PORTAFOLIO port on pc.por_id = port.POR_ID  
    left join    
    (    
    
     select row_number() over (partition by emi_id order by eca_fecha_resolucion desc,eca_id desc) r,emi_id    
     ,eca_valor     
     ,cal_nombre eca_nombre    
     ,cal_nombre_personalizado eca_nombre_personalizado    
     ,eca_fecha_resolucion    
     from bvq_administracion.emisores_calificacion eca    
     join bvq_administracion.calificadoras cal on eca.cal_id=cal.cal_id    
     where eca_estado=21 and (eca_fecha_resolucion is null or eca_fecha_resolucion<=(select c from corteslist))    
    ) emical on emical.emi_id=tiv_emisor and emical.r=1--(tvl_generico=1 or tiv_tipo_valor in (/*10,*/13)) and emical.emi_id=tiv_emisor and emical.r=1  
    left join    
    (    
    
     select row_number() over (partition by enc.enc_numero_corto_emision order BY enc.ENC_FECHA_DESDE  desc,enc.ENC_ID desc) r,enc_numero_corto_emision    
     ,enc.ENC_VALOR 
     ,cal_nombre enc_nombre    
     ,cal_nombre_personalizado enc_nombre_personalizado    
     ,enc.ENC_FECHA_DESDE  
     FROM BVQ_ADMINISTRACION.EMISION_CALIFICACION enc   
     join bvq_administracion.calificadoras cal on enc.CAL_ID=cal.CAL_ID    
     where enc.ENC_ESTADO=21 and (enc.ENC_FECHA_DESDE is null or enc.ENC_FECHA_DESDE<=(select c from corteslist))    
    ) emscal on emscal.enc_numero_corto_emision=pc.TIV_CODIGO_TITULO_SIC and emscal.r=1  
    left join BVQ_ADMINISTRACION.TIPO_VALOR_HOMOLOGADO H    
    ON PC.tvl_codigo = H.[TVLH_CODIGO]    
 where sal>0    
   and    
   isnull(IPR_ES_CXC,0)=0    
   and    
   TIV_TIPO_RENTA=153 
   --ORDER BY TVL_CODIGO,EMS_NOMBRE,TIV_FECHA_VENCIMIENTO    
  ) s    
  group by  TVL_NOMBRE,CUENTA_CONTABLE,VECTOR_PRECIO,TIPO,CUPON,PLAZO_PACTADO,FECHA_VENCIMIENTO_CONVENIO_PAGO,FECHA_SUSCRIPCION_CONVENIO_PAGO    
  ,FECHA_DE_VENCIMIENTO,DECRETO_EMISOR,INTERVINIENTES,PRECIO_DE_HOY,DIAS_POR_VENCER,FECHA_VALOR_DE_COMPRA,YIELD,PRECIO,SECTOR,MONTO_EMITIDO,PATRIMONIO    
  ,CALIFICADORA_DE_RIESGO,CALIFICACION_DE_RIESGO,FECHA_DE_PAGO_ULTIMO_CUPON,DIAS_DE_INTERES_GANADO,PCT_A_AJUSTAR,DIAS_POR_VENCER_COMPRA,PCT_AJUSTE_DIARIO    
  ,FACTOR_DE_AJUSTE,CONTROLADOR_SECTOR,CONTROLADOR_POSICION,PRECIO_ULTIMA_COMPRA,FECHA_ULTIMA_COMPRA,BASE_DIAS_INTERES,BASE_TASA_INTERES,PRECIO2    
  ,CUPON2,CODIGO_TITULO,TIPO2,ACCIONES_REALIZADAS,MANTIENE_VECTOR_PRECIO,ACP_ID,PROG,ACTA,GCXC_NOMBRE,TVL_CODIGO,EMS_NOMBRE,OTROS_COSTOS,TPO_PROG,RECURSOS    
  ,TIV_VALOR_NOMINAL,ABONO_INTERES,VALNOM_ANTERIOR,FECHA_ENCARGO,DIVIDENDOS_EN_ACCIONES,asi_emi_codemi,TPO_ORD,GENERICO,s.ID_EMISOR,htp_numeracion
  ,(case when TPO_DESGLOSAR_F1 = 1 then TPO_F1 end)
  ,ems_abr,s.tiv_id,s.tiv_split_de,s.tfcorte
