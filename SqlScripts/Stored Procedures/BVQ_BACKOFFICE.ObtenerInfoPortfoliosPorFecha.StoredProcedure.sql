-- =============================================
-- Author:			Patricio Villacis
-- Create date:		08/01/2017
-- Description:		Obtiene el detalle de todos los portafolios a una fecha corte
-- Modificacion:    PV:	Se implementa tabla temporal para evitar bloqueos y acelerar respuesta.
-- =============================================

CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerInfoPortfoliosPorFecha]
                @i_fechaCorte datetime,
                @i_lga_id	int

AS
BEGIN
                SET NOCOUNT ON;

                truncate table corteslist
                insert into corteslist values (@i_fechaCorte,1)
                
                exec bvq_administracion.generarcompraventacorte
                exec bvq_administracion.generarvectores
				exec BVQ_ADMINISTRACION.PrepararValoracionLinealCache
				
				declare @v_portfolio_oc int,@v_renta_fija int
				
				select @v_portfolio_oc=ITC_ID from BVQ_ADMINISTRACION.CatalogoItemCatalogo where ITC_CODIGO='OC' and cat_codigo='PORT_TIPO'
				SELECT @v_renta_fija=ITC_ID FROM BVQ_ADMINISTRACION.ITEM_CATALOGO WHERE ITC_CODIGO = 'REN_FIJA'
				
				declare @tbPortafolioCorte table (httpo_id int,por_id int,tiv_id int,tiv_codigo varchar(50),tiv_tipo_valor int,tvl_codigo varchar(20),tvl_generico bit,tiv_fecha_emision datetime,tiv_fecha_vencimiento datetime
												,tiv_tipo_tasa int,tiv_tasa_interes float,tiv_tipo_base int,tiv_tipo_renta int,tiv_valor_nominal float,ems_nombre varchar(200),htp_numeracion varchar(250),sal float,accrual float,tiv_precio float
												,tfcorte datetime,rendimiento float,max_fecha_compra datetime,max_precio_compra float,vpr_tasa_descuento float, fecha_compra datetime, htp_precio_compra float, valefe float
												,htp_compra float, latest_inicio datetime, tpo_tipo_valoracion bit, dias_al_corte int, prox_capital datetime, prox_interes datetime  
                                                ,IPR_ES_CXC bit
                                                ,TPO_FECHA_VEN_CONVENIO	datetime
                                                ,TPO_FECHA_SUSC_CONVENIO	datetime
                                                ,TPO_INTERVINIENTES	varchar(255)
                                                ,TPO_PRECIO_ULTIMA_COMPRA	float
                                                ,TPO_CUPON_VECTOR	float
                                                ,TPO_MANTIENE_VECTOR_PRECIO	bit
                                                ,TPO_ACTA varchar(10)
                                                ,TPO_COMISIONES float
                                                ,TPO_INTERES_TRANSCURRIDO float
												,TPO_COMISION_BOLSA float
												,tpo_recursos varchar(30)
												,TPO_PRECIO_REGISTRO_VALOR_EFECTIVO float
                                                ,TPO_TABLA_AMORTIZACION varchar(40)
                                                ,TIV_EMISOR int
                                                ,TIV_CODIGO_TITULO_SIC varchar(20)
                                                ,TCA_VALOR nvarchar(10)
                                                ,TIV_CODIGO_VECTOR varchar(50)
                                                ,lastValDate datetime
                                                ,fecha_ultima_compra datetime
                                                )
												
				declare @tbPortafolioComitente table (ctc_id int, ctc_inicial_tipo varchar(2), identificacion varchar(25), nombre varchar(max), por_id int, por_codigo varchar(100), por_tipo int, por_tipo_nombre varchar(100)
													,sbp_id int, por_subtipo_nombre varchar(100), por_descripcion varchar(max), por_ord int)
				
				insert into @tbPortafolioCorte
				select	httpo_id,por_id,tiv_id,tiv_codigo,tiv_tipo_valor,tvl_codigo,tvl_generico,tiv_fecha_emision,tiv_fecha_vencimiento,tiv_tipo_tasa,tiv_tasa_interes,tiv_tipo_base,tiv_tipo_renta,tiv_valor_nominal,ems_nombre
						,htp_numeracion,sal,accrual,precio_sin_redondear,tfcorte,coalesce(liq_rendimiento,pond_rendimiento),max_fecha_compra,max_precio_compra,(vpr_tasa_descuento*100.00),fecha_compra,htp_precio_compra
						,valefe,htp_compra,latest_inicio,tpo_tipo_valoracion,dias_al_corte,prox_capital,prox_interes
                        ,IPR_ES_CXC
                        ,null
                        ,null
                        ,null
						,null
                        ,null
                        ,null
                        ,TPO_ACTA
                        ,TPO_COMISIONES
                        ,TPO_INTERES_TRANSCURRIDO
						,TPO_COMISION_BOLSA
						,tpo_recursos
						,TPO_PRECIO_REGISTRO_VALOR_EFECTIVO
                        ,TPO_TABLA_AMORTIZACION
                        ,TIV_EMISOR
                        ,TIV_CODIGO_TITULO_SIC
                        ,TCA_VALOR
                        ,TIV_CODIGO_VECTOR
                        ,lastValDate
                        ,fecha_ultima_compra
				from bvq_backoffice.portafoliocorte

		
				insert into @tbPortafolioComitente
				select por.ctc_id, ctc_inicial_tipo,identificacion,nombre,por_id,por_codigo,por_tipo,tipo.itc_descripcion,por.sbp_id,sbp.sbp_descripcion,por.por_codigo+': '+ctc.nombre,por_ord
				from bvq_prevencion.personacomitente ctc
					inner join bvq_backoffice.portafolio por on ctc.ctc_id=por.ctc_id
					inner join bvq_administracion.item_catalogo tipo on por.por_tipo=tipo.itc_id
					left join bvq_backoffice.subtipo_portafolio sbp on sbp.sbp_id=por.sbp_id
               
                select distinct 				por.nombre as comitente
                                               ,pcorte.ems_nombre
                                               ,tvl.tvl_descripcion
                                               ,rent.itc_descripcion as renta
                                               ,tta.tta_nombre
                                               ,por.por_tipo_nombre
                                               ,por.por_codigo
                                               ,pcorte.tiv_precio
                                               ,pcorte.por_id
                                               ,pcorte.tiv_id
											   ,pcorte.tiv_tasa_interes
											   ,(CASE WHEN pcorte.tiv_tipo_renta  =  @v_renta_fija THEN pcorte.tiv_fecha_emision else NULL end) as tiv_fecha_emision
                                               ,pcorte.tiv_fecha_vencimiento
                                               ,pcorte.htp_numeracion
                                               ,pcorte.tfcorte
                                               ,pcorte.fecha_compra
                                               ,pcorte.htp_precio_compra
                                               ,pcorte.valefe as valefeoper--oper
                                               ,pcorte.htp_compra
                                               ,pcorte.rendimiento as liq_rendimiento
                                               ,pcorte.accrual
                                               ,pcorte.latest_inicio
                                               ,pcorte.tpo_tipo_valoracion
                                               ,pcorte.sal
                                               ,pcorte.dias_al_corte
                                               ,pcorte.prox_capital
                                               ,pcorte.prox_interes

                                               ,por.POR_DESCRIPCION
                                               ,isnull(por.por_subtipo_nombre,'SIN CLASIFICAR') as SBP_DESCRIPCION
                                               
                                               ,VALOR_UNITARIO=case when tiv_tipo_renta=154 then pcorte.tiv_valor_nominal else 1 end
                                               ,VALOR_NOMINAL=
                                                    case when pcorte.tvl_codigo='FI'
                                                        then htp_compra*htp_precio_compra
                                                    else
                                                        sal*
                                                        case when tiv_tipo_renta=154 then pcorte.tiv_valor_nominal
                                                        else 1 end
                                                    end
                                               ,IPR_ES_CXC
                                               ,pcorte.TPO_ACTA
                                               ,VALOR_EFECTIVO=
                                                    pcorte.sal
                                                    --precio
                                                    * (
                                                        coalesce(tpo_precio_registro_valor_efectivo*100.0,pcorte.htp_precio_compra)--tiv_precio
														+case when pcorte.fecha_compra>='20220601' then 1 else 0 end
														*(
															 isnull(TPO_INTERES_TRANSCURRIDO,0)
															+isnull(TPO_COMISIONES,0)
															+isnull(TPO_COMISION_BOLSA,0)
														)/htp_compra*100.0
                                                    )
                                                    / case when tiv_tipo_renta=154 then 1 else 100 end
                                                    --+ isnull(TPO_COMISIONES,0)
                                               ,TIPO_RENTA=case tiv_tipo_renta when 153 then 'Renta fija' when 154 then 'Renta variable' end
                                               ,ESTADO = case when isnull(IPR_ES_CXC,0)=0 then 'Vigente' else 'Cuentas por cobrar' end
                                               /*,VE_AMORTIZADO=isnull([TPO_INTERES_TRANSCURRIDO],0) + isnull([TPO_COMISIONES],0)/
                                                    --+ [htp_compra]
                                                    + sal
                                                    *[htp_precio_compra]/case when [tiv_tipo_renta]=153 then 100e else 1e end*/
                                                ,por.Por_ord
                                                ,httpo_id
												,pcorte.tpo_recursos
												,pcorte.TPO_PRECIO_REGISTRO_VALOR_EFECTIVO
                                                ,pcorte.TPO_TABLA_AMORTIZACION
                                                ,CALIFICACION_DE_RIESGO=coalesce(
                                                     emical.eca_valor
                                                    ,emscal.[ENC_VALOR]
                                                    ,[TCA_VALOR]
                                                    ,'NO DISPONIBLE')
                                                ,PRECIO_DE_HOY=
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
                                                            when [TPO_MANTIENE_VECTOR_PRECIO]=1 or
                                                            isnull([IPR_ES_CXC],0)=0 
                                                            or pcorte.tvl_codigo in ('SWAP') then rtrim([TIV_CODIGO_VECTOR]) end<>''
	                                                        ,
                                                            case when TPO_MANTIENE_VECTOR_PRECIO=1 OR tiv_codigo_vector<>'' then [tiv_precio]/100.0 end
                                                            ,
                                                            pcorte.htp_precio_compra/100.0
	                                                    )
                                                    )
	                                                /
                                                    datediff(d,fecha_ultima_compra,tiv_fecha_vencimiento)
                                               ,INTERES_GANADO=
                                                    case
                                                        when pcorte.tvl_codigo in
                                                            ('FAC','PCO') and
                                                            pcorte.tiv_tipo_base=355 and
                                                            latest_inicio=fecha_compra and ipr_es_cxc=1 then datediff(d,tiv_fecha_vencimiento,tfcorte)
                                                        else pcorte.dias_al_corte
                                                    end
		                                            /360.0 * sal * tiv_tasa_interes/100.0    

                from @tbPortafolioCorte pcorte 
                               join bvq_administracion.tipo_valor tvl on pcorte.tiv_tipo_valor=tvl.tvl_id
							   join @tbPortafolioComitente por on pcorte.por_id=por.por_id
                               join bvq_administracion.item_catalogo rent on pcorte.tiv_tipo_renta=rent.itc_id
                               join bvq_administracion.tipo_tasa tta on pcorte.tiv_tipo_tasa=tta.tta_id
                               left join _temp.prop prop on prop.por_id=por.por_id
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
    
     select row_number() over (partition by eca.enc_numero_corto_emision order BY eca.ENC_FECHA_DESDE  desc,eca.ENC_ID desc) r,enc_numero_corto_emision    
     ,eca.ENC_VALOR 
     ,cal_nombre eca_nombre    
     ,cal_nombre_personalizado eca_nombre_personalizado    
     ,eca.ENC_FECHA_DESDE    
     FROM BVQ_ADMINISTRACION.EMISION_CALIFICACION eca   
     join bvq_administracion.calificadoras cal on eca.CAL_ID=cal.CAL_ID    
     where eca.ENC_ESTADO=21 and (eca.ENC_FECHA_DESDE is null or eca.ENC_FECHA_DESDE<=(select c from corteslist))    
    ) emscal on emscal.enc_numero_corto_emision=pcorte.TIV_CODIGO_TITULO_SIC and emscal.r=1  
    left join BVQ_ADMINISTRACION.TIPO_VALOR_HOMOLOGADO H    
    ON pcorte.tvl_codigo = H.[TVLH_CODIGO]    

                where sal>0 --and prop.por_id is null -- para que no incluya portafolio propio
                order by tvl_descripcion,ems_nombre,fecha_compra
				--and por.por_tipo<>@v_portfolio_oc	-- para ocultar portafolios ocultos
                --order by pcorte.por_codigo,pcorte.tiv_tipo_valor,pcorte.tiv_id
end
