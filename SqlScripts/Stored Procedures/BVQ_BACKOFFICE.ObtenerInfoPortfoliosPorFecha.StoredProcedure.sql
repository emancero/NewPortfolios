﻿-- =============================================
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
												,tiv_tipo_tasa int,tiv_tipo_base int,tiv_tipo_renta int,tiv_valor_nominal float,ems_nombre varchar(200),htp_numeracion varchar(250),sal float,accrual float,tiv_precio float
												,tfcorte datetime,rendimiento float,max_fecha_compra datetime,max_precio_compra float,vpr_tasa_descuento float, fecha_compra datetime, htp_precio_compra float, valefe float
												,htp_compra float, latest_inicio datetime, tpo_tipo_valoracion bit, dias_al_corte int, prox_capital datetime, prox_interes datetime  
                                                ,IPR_ES_CXC bit)
												
				declare @tbPortafolioComitente table (ctc_id int, ctc_inicial_tipo varchar(2), identificacion varchar(25), nombre varchar(max), por_id int, por_codigo varchar(100), por_tipo int, por_tipo_nombre varchar(100)
													,sbp_id int, por_subtipo_nombre varchar(100), por_descripcion varchar(max))
				
				insert into @tbPortafolioCorte
				select	httpo_id,por_id,tiv_id,tiv_codigo,tiv_tipo_valor,tvl_codigo,tvl_generico,tiv_fecha_emision,tiv_fecha_vencimiento,tiv_tipo_tasa,tiv_tipo_base,tiv_tipo_renta,tiv_valor_nominal,ems_nombre
						,htp_numeracion,sal,accrual,precio_sin_redondear,tfcorte,coalesce(liq_rendimiento,pond_rendimiento),max_fecha_compra,max_precio_compra,(vpr_tasa_descuento*100.00),fecha_compra,htp_precio_compra
						,valefe,htp_compra,latest_inicio,tpo_tipo_valoracion,dias_al_corte,prox_capital,prox_interes
                        ,IPR_ES_CXC
				from bvq_backoffice.portafoliocorteProg
		
				insert into @tbPortafolioComitente
				select por.ctc_id, ctc_inicial_tipo,identificacion,nombre,por_id,por_codigo,por_tipo,tipo.itc_descripcion,por.sbp_id,sbp.sbp_descripcion,por.por_codigo+': '+ctc.nombre
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
                                               ,VALOR_NOMINAL=sal*case when tiv_tipo_renta=154 then pcorte.tiv_valor_nominal else 1 end
                                               ,IPR_ES_CXC
                from @tbPortafolioCorte pcorte 
                               join bvq_administracion.tipo_valor tvl on pcorte.tiv_tipo_valor=tvl.tvl_id
							   join @tbPortafolioComitente por on pcorte.por_id=por.por_id
                               join bvq_administracion.item_catalogo rent on pcorte.tiv_tipo_renta=rent.itc_id
                               join bvq_administracion.tipo_tasa tta on pcorte.tiv_tipo_tasa=tta.tta_id
                               left join _temp.prop prop on prop.por_id=por.por_id
                where sal>0 --and prop.por_id is null -- para que no incluya portafolio propio
				--and por.por_tipo<>@v_portfolio_oc	-- para ocultar portafolios ocultos
                --order by pcorte.por_codigo,pcorte.tiv_tipo_valor,pcorte.tiv_id
end