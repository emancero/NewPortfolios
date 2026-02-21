CREATE procedure [BVQ_BACKOFFICE].[ObtenerSaldoYDetallePortafolio]
	@i_por_id int     
	,@i_fecha datetime=null
	,@i_lga_id int
AS
BEGIN
      SET NOCOUNT ON;
      
      
      DECLARE @v_id_estado INT, @v_id_cancelado int;
	
	if(@i_fecha is null)
	  set @i_fecha=BVQ_ADMINISTRACION.ObtenerFechaSistema();

      EXEC @v_id_estado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
      @i_code = N'BCK_ES_TIT_POR',
      @i_status = N'E';
      
      EXEC @v_id_cancelado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
      @i_code = N'BCK_ES_TIT_POR',
      @i_status = N'C';
      
	  --exec BVQ_BACKOFFICE.GenerarCompraVentaFlujo
	  exec bvq_administracion.GenerarCompraVentaCorte
	  update BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO set htp_tpo_id=tpo_id_c

	--PV: obtiene detalle de titulos portafolio (para master-grid control de ing/egr)
    select * from(
		SELECT 
                        TPO_ID=HTP.HTP_ID,
                        TPOR.TIV_ID, 
                        TPOR.POR_ID, 
                        portafolios02.par_valor,
                        TPO_CANTIDAD=HTP.montooper,
                        case when isnull(HTP.HTP_PRECIO_COMPRA,0)<>0 then HTP.HTP_PRECIO_COMPRA else HTP.HTP_PRECIO_VENTA end AS TPO_PRECIO_INGRESO, 
                        TPO_FECHA_INGRESO=HTP.HTP_FECHA_OPERACION,
                        TPOR.TPO_FECHA_REGISTRO, 
                        TIT.TIV_CODIGO, 
                        TIT.TIV_EMISOR, 
                        TIT.TIV_TIPO_VALOR, 
                        TIT.TIV_TIPO_RENTA, 
                        TIT.TIV_FECHA_VENCIMIENTO, 
                        TIV_RENDIMIENTO=isnull(HTP.htp_rendimiento,0),
                        TIT.TIV_MONEDA, 
                        TIT.TIV_TIPO, 
                        TIT.TIV_ESTADO, 
                        TIT.TIV_VALOR_NOMINAL, 
                        TIT.TIV_VALOR_EFECTIVO, 
                        TIT.TIV_DIAS_PARA_VENCER, 
                        TIT.TIV_TASA_INTERES, 
                        TIT.TIV_TASA_DESCUENTO, 
                        TIT.TIV_SERIE, 
                        TIT.TIV_APLICA_DEBENGO, 
                        TIT.TIV_APLICA_MADURACION, 
                        TIT.TIV_PLAZO, 
                        TIT.TIV_DESMATERIALIZADO, 
                        TIT.TIV_SECTOR, 
                        BVQ_BACKOFFICE.ObtenerBaseTituloDias(TIT.TIV_TIPO_BASE) Plazo_Dias, 
                        TIT.TIV_PRECIO_SPOT, 
                        TIT.TIV_FACTOR_PRES_BURSATIL, 
                        EMISOR.EMS_NOMBRE AS TIV_NOMBRE_EMISOR, 
                        TITULO.TVL_NOMBRE AS TIV_NOMBRE_TITULO, 
                        MON.MON_NOMBRE, '' AS ESTADO, 
                        TPOR.TPO_COBRO_CUPON,TPOR.TPO_CONFIRMA_TITULO, case TPOR.TPO_ESTADO when @v_id_cancelado then 1 else 0 end as TPO_TITULO_CANCELADO, 
						[TPO_SALDO]=tfn.saldo,
							--(select sum(montooper-isnull(remaining,0)) from bvq_backoffice.eventoportafolio where htp_tpo_id=tpo_id and htp_fecha_operacion<=@i_fecha),
                        BVQ_ADMINISTRACION.ITEM_CATALOGO.ITC_CODIGO AS TIPO_RENTA_CODIGO, 
                        case BVQ_ADMINISTRACION.ITEM_CATALOGO.ITC_CODIGO
                             when 'REN_VARIABLE' then (select CT.ITC_DESCRIPCION from [BVQ_ADMINISTRACION].[ITEM_CATALOGO] CT WHERE (CT.ITC_CODIGO = 'NO_APL' ))
                             else (SELECT CT.ITC_DESCRIPCION FROM [BVQ_ADMINISTRACION].[ITEM_CATALOGO] CT WHERE (CT.ITC_ID = TIT.TIV_PLAZO))
                        END AS Plazo, TPOR.TPO_CATEGORIA,
                        TPOR.TPO_PRECIO_SUCIO,TPOR.TPO_PRECIO_SUCIO_VAL,
          TPO_NUMERACION,
                        TPO_RENOVADO_DE,
                        TPO_COMISION_BOLSA,
                        TPO_NUMERACION_2,
                        TPO_COMISION_COMPROMISO,--=0.0,
                        TPO_COMISION_FINANCIAMIENTO,--=0.0,
                        TPO_COMISION_EVALUACION,--=0.0,
                        TPO_PARTICIPACION,--=0.0,
                        TPO_MONTO_EMISION,--=0.0,
                        TPO_OBJETO=FON.FON_ACCIONES_REALIZADAS,
                        TPO_AMORTIZAR_MONTO_TOTAL=null,
                        TPO_SALDO_EN_FILA_ANTERIOR=null,
						HTP_TIR,
						HTP_RENDIMIENTO_RETORNO,
						TPO_OFERTA_ID,
						HTP.htp_tpo_id AS TPO_ID2,
						FON.FON_CVA_ID,
						FON.FON_PROCEDENCIA,
						 
						TPOR.TPO_FECHA_VEN_CONVENIO,
						TPOR.TPO_FECHA_SUSC_CONVENIO,
						TPOR.TPO_INTERVINIENTES,
						TPOR.TPO_INTERES_TRANSCURRIDO,
						TPOR.TPO_PRECIO_ULTIMA_COMPRA,
						TPOR.TPO_CUPON_VECTOR,
						TPOR.TPO_ACTA,
						TPOR.TPO_OTROS_COSTOS,
						TPOR.TPO_COMISIONES,
						TPOR.TPO_ABONO_INTERES,
						TPOR.TPO_VALNOM_ANTERIOR,
						TPOR.TPO_FECHA_ENCARGO,
						TPOR.TPO_RECURSOS,
						HTP.HTP_DIVIDENDO,
						TPOR.TPO_PROG,
                        FON.FON_NUMERO_RESOLUCION
                        FROM BVQ_BACKOFFICE.TITULOS_PORTAFOLIO AS TPOR 
                             INNER JOIN BVQ_ADMINISTRACION.TITULO_VALOR AS TIT ON TPOR.TIV_ID = TIT.TIV_ID 
                             INNER JOIN BVQ_ADMINISTRACION.EMISOR AS EMISOR ON TIT.TIV_EMISOR = EMISOR.EMS_ID 
                             INNER JOIN BVQ_ADMINISTRACION.TIPO_VALOR AS TITULO ON TIT.TIV_TIPO_VALOR = TITULO.TVL_ID 
                             INNER JOIN BVQ_ADMINISTRACION.MONEDA AS MON ON TIT.TIV_MONEDA = MON.MON_ID 
                             INNER JOIN BVQ_ADMINISTRACION.ITEM_CATALOGO ON TIT.TIV_TIPO_RENTA = BVQ_ADMINISTRACION.ITEM_CATALOGO.ITC_ID
                             left join bvq_administracion.parametro portafolios02 on par_codigo='PORTAFOLIOS_02'
                             join BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HTP on HTP.HTP_TPO_ID=TPOR.TPO_ID
							 join [bvq_backoffice].[tfObtenerSaldoTituloPortafolio] (@i_fecha) tfn on htp.htp_tpo_id=tfn.htp_tpo_id
							 left join BVQ_BACKOFFICE.isspol_progs ipr on IPR_NOMBRE_PROG=tpo_prog
							 left join BVQ_BACKOFFICE.FONDO FON ON FON.FON_ID=TPOR.FON_ID
                             WHERE
							(
								TPOR.POR_ID = @i_por_id /*newPors or @i_por_id is null*/
							)
                                         AND
										HTP.HTP_ESTADO<>@v_id_estado 
                                         AND HTP.HTP_ESTADO<>@v_id_cancelado
                                         AND (isnull(TIT.TIV_FECHA_VENCIMIENTO,@i_fecha)>=@i_fecha or ipr_es_cxc=1)
            ) s
	where round(TPO_SALDO,2)>0
    ORDER BY TIV_NOMBRE_EMISOR,TIV_FECHA_VENCIMIENTO
			
	--PV: obtiene saldos de titulos portafolio (para master-grid control de ing/egr)
	select * from(
		SELECT 
		distinct TPOR.por_id/TPOR.por_id* /*newPors  @i_por_id/@i_por_id*/
                        TPOR.TPO_ID as TPO_ID2,
                        TPOR.TIV_ID, 
                        POR_ID=@i_por_id,--TPOR.POR_ID, 
                        TIT.TIV_CODIGO, 
						case when TIT.TIV_TIPO_RENTA=154 then null else TIT.TIV_FECHA_EMISION end as TIV_FECHA_EMISION,
                        case when TIT.TIV_TIPO_RENTA=154 then null else TIT.TIV_FECHA_VENCIMIENTO end as TIV_FECHA_VENCIMIENTO,  
						TIV_DIAS_PARA_VENCER=dbo.fnDias(@i_fecha,tiv_fecha_vencimiento,tiv_tipo_base)
							-case when tiv_tipo_base=354 and month(@i_fecha)=2 and day(@i_fecha) in (28,29) then 30-day(@i_fecha) else 0 end,
                        coalesce(TIT.TIV_SERIE,TIT.TIV_DECRETO,'') TIV_SERIE,  
                        EMISOR.EMS_NOMBRE AS TIV_NOMBRE_EMISOR, 
                        TITULO.TVL_NOMBRE AS TIV_NOMBRE_TITULO, 
                        MON.MON_NOMBRE,
						TPO_SALDO=(select sum(montooper-isnull(remaining,0)) from bvq_backoffice.eventoportafolio e
							--newPors join bvq_backoffice.titulos_portafolio tpo on e.htp_tpo_id=tpo.tpo_id						
							where (
								--newPors según agrupación (complejo)
								--@i_por_id is null and tpo.tpo_numeracion=tpor.tpo_numeracion and tpo.tiv_id=tpor.tiv_id
								--or
								--1=1 and @i_por_id is not null and
								e.htp_tpo_id=tpor.tpo_id
							) and htp_fecha_operacion<=@i_fecha
						),
                        TPO_NUMERACION,
						TPO_RENOVADO_DE,
						(ISNULL(ROUND(CASE WHEN tta.tta_codigo='FLAT_RATE' 
							THEN ISNULL(TIT.TIV_TASA_INTERES,0) 
							ELSE ISNULL(BVQ_ADMINISTRACION.ObtenerTasaPorIdyFechaFunc(TIT.TIV_ID,TIT.TIV_TIPO_TASA,BVQ_BACKOFFICE.fnObtenerFechaInicioCuponActual(Convert(DATETIME,convert(varchar, @i_fecha)),TIT.TIV_ID)),0)
								+ISNULL(TIT.TIV_TASA_MARGEN,0) END,8), 0)
						) AS TIV_TASA_INTERES,
						TIV_RENDIMIENTO=
							--newPors null
							(SELECT TOP 1 isnull(htp_rendimiento,0) FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO R WHERE R.HTP_TPO_ID=TPOR.TPO_ID ORDER BY HTP_FECHA_OPERACION DESC),
						TPO_ID = /*newPors TPO.TPO_ID*/
							(select max(htp_id) from bvq_backoffice.historico_titulos_portafolio where htp_tpo_id=TPOR.TPO_ID),
						 
						TPOR.TPO_FECHA_VEN_CONVENIO,
						TPOR.TPO_FECHA_SUSC_CONVENIO,
						TPOR.TPO_INTERVINIENTES,
						TPOR.TPO_INTERES_TRANSCURRIDO,
						TPOR.TPO_PRECIO_ULTIMA_COMPRA,
						TPOR.TPO_CUPON_VECTOR,
						TPOR.TPO_ACTA,
						TPOR.TPO_OTROS_COSTOS,
						TPOR.TPO_COMISIONES,
						TPOR.TPO_ABONO_INTERES,
						TPOR.TPO_VALNOM_ANTERIOR,
						TPOR.TPO_FECHA_ENCARGO,
						TPOR.TPO_RECURSOS,
						ipr.IPR_ES_CXC

                        FROM BVQ_BACKOFFICE.TITULOS_PORTAFOLIO AS TPOR 
							INNER JOIN BVQ_ADMINISTRACION.TITULO_VALOR AS TIT ON TPOR.TIV_ID = TIT.TIV_ID 
							INNER JOIN BVQ_ADMINISTRACION.TIPO_TASA TTA ON TIT.TIV_TIPO_TASA=TTA.TTA_ID
							INNER JOIN BVQ_ADMINISTRACION.EMISOR AS EMISOR ON TIT.TIV_EMISOR = EMISOR.EMS_ID 
                            INNER JOIN BVQ_ADMINISTRACION.TIPO_VALOR AS TITULO ON TIT.TIV_TIPO_VALOR = TITULO.TVL_ID 
                            INNER JOIN BVQ_ADMINISTRACION.MONEDA AS MON ON TIT.TIV_MONEDA = MON.MON_ID 
                            INNER JOIN BVQ_ADMINISTRACION.ITEM_CATALOGO ON TIT.TIV_TIPO_RENTA = BVQ_ADMINISTRACION.ITEM_CATALOGO.ITC_ID
                            left join BVQ_BACKOFFICE.isspol_progs ipr on IPR_NOMBRE_PROG=tpo_prog
                             WHERE TPOR.POR_ID = @i_por_id
                                         AND
										 TPOR.TPO_ESTADO<>@v_id_estado 
                                         AND TPOR.TPO_ESTADO<>@v_id_cancelado
                                         AND (isnull(TIT.TIV_FECHA_VENCIMIENTO,@i_fecha)>=@i_fecha or ipr_es_cxc=1)
		) as T1
	where round(TPO_SALDO,2)>0
	ORDER BY TIV_NOMBRE_EMISOR,TIV_FECHA_VENCIMIENTO

	--numeración 2
	select SECUENCIAL=MAX(TPO_NUMERACION_2) from BVQ_BACKOFFICE.TITULOS_PORTAFOLIO
end