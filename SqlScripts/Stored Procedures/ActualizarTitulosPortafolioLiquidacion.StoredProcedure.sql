-- =================================================================================================
-- Author:  Pablo Sanmartin
-- Create date: 20/12/2008
-- Description: Inserta una liquidación
-- Parametros:
-- MODIFICACION: JIMMY CHUICO 06/17/2009 para que inserte los datos del portafolio en el histórico
--				 JCH: 04/08/2009 Para que actualice los datos del efectivo de un  portafolio
--				 GCA: 28-oct-2009:  Se deja en la tabla TITULOS_PORTAFOLIO un solo registro por tiv_id, por_id, cupon y tpo_estado
--				 para tener un solo registro por titulo portafolio con el saldo real
--				 JCH: 11/Ene/2010, separación de funcionalidades para facilitar el mantenimiento
--				 GCA: 15-abr-2010: Se agrega la variable categoría para NIF
--				 PSA: 16/Feb/2014	Actualizar el portafolio
--				 PSA:	20/06/2014	Portafolio, detalle liquidación.
--				 PVG: 23-07-2018 se registra TIR y rendimiento de retorno para costo amortizado 
-- =================================================================================================

CREATE PROCEDURE [BVQ_BACKOFFICE].[ActualizarTitulosPortafolioLiquidacion]
  @i_liq_id int
  ,@i_don_id int
  ,@i_tir float=0
  ,@i_returnRend float=0
  ,@i_usr_id int
  ,@i_lga_id int
AS
BEGIN
	 SET NOCOUNT ON;

	 DECLARE @v_categoria int;
	 DECLARE @v_id_estado int, @v_tit_id int, @v_port_id int, @v_cupon int, @v_id_estado_port int;
	 DECLARE @v_monId int, @v_valor_efectivo float, @v_saldo_efectivo float, @v_reporto int, @v_isreporto bit, @v_don_cantidad float, @v_saldo_reportado float;
	 DECLARE @o_secuencial varchar(50), @v_reportante int, @v_reportado int,  @v_htp_id int, @v_engarantia int;
	 DECLARE @Error int;
	 DECLARE @v_cantidad float,@v_precio float, @v_rend_liq float, @v_total_cms float;
	 DECLARE @v_fecha_valor datetime;
	 DECLARE @v_subTipoCodigo varchar(50);
	 declare @saldoTit as float, @v_estado_port_rev int, @v_cantidadGarantia decimal(38,2), @v_tivGarantia int, @v_precioGarantia decimal (38,2);

	 EXEC @v_id_estado_port = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
	 @i_code = N'BCK_ES_TIT_POR',
	 @i_status = N'C';

	 EXEC @v_estado_port_rev = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
	 @i_code = N'BCK_ES_TIT_POR',
	 @i_status = N'R';

	 SET @v_reportado =  (SELECT IT.ITC_ID FROM BVQ_ADMINISTRACION.ITEM_CATALOGO IT INNER JOIN BVQ_ADMINISTRACION.CATALOGO CAT
					ON IT.CAT_ID = CAT.CAT_ID AND CAT_CODIGO = 'BCK_EST_POR_REP' AND IT.ITC_CODIGO = 'REPORTADO')

	 SET @v_reportante = (SELECT IT.ITC_ID FROM BVQ_ADMINISTRACION.ITEM_CATALOGO IT INNER JOIN BVQ_ADMINISTRACION.CATALOGO CAT
					ON IT.CAT_ID = CAT.CAT_ID AND CAT_CODIGO = 'BCK_EST_POR_REP' AND IT.ITC_CODIGO = 'REPORTANTE') 
	     
	 SELECT
		@v_cantidad = LIQ_CANTIDAD,
		@v_precio = LIQ_PRECIO,
		@v_rend_liq = LIQ_RENDIMIENTO,
		@v_fecha_valor = convert(datetime,CONVERT(date,LIQ_FECHA_VALOR))+convert(datetime,CONVERT(time,LIQ_HORA_NEGOCIACION)),
		@v_total_cms = LIQ_TOT_COMISION
		-- NIF 
		,@v_categoria = LIQ_CATEGORIA
		-- FIN NIF
	 FROM BVQ_BACKOFFICE.LIQUIDACION WHERE LIQ_ID = @i_liq_id;

	 --print 'titulo: ' + convert(varchar(10), isnull(@v_tit_id, 0) )

	 --INSERTA EL TÍTULO AL PORTAFOLIO
	declare @v_reportante_tiv_id int;

	SELECT @v_tit_id = DLI.TIV_ID,
			@v_port_id = ISNULL(ORN.POR_ID,-1),
			@v_subTipoCodigo = SUBTIPO.ITC_CODIGO,
			@v_reporto = ORN.CRE_ID,
			@v_don_cantidad = isnull(CRE_CANTIDAD,DLI_CANTIDAD),
			@v_cupon = CASE TIV_TIPO_RENTA WHEN 153 /*CASE  DLI.DLI_CUPON  WHEN 
	(SELECT ITC.ITC_ID FROM BVQ_ADMINISTRACION.CATALOGO CAT INNER JOIN BVQ_ADMINISTRACION.ITEM_CATALOGO ITC ON CAT.CAT_ID = ITC.CAT_ID
	AND CAT.CAT_CODIGO = 'BCK_CUPON' AND ITC.ITC_CODIGO = 'SI')*/ THEN 1 ELSE 0 END
			,@v_reportante_tiv_id = CRE.CRE_REPORTANTE_TIV_ID
	FROM BVQ_BACKOFFICE.DETALLE_LIQUIDACION AS DLI INNER JOIN
		BVQ_BACKOFFICE.ORDEN_NEGOCIACION AS ORN ON DLI.ORN_ID = ORN.ORN_ID INNER JOIN
		BVQ_ADMINISTRACION.ITEM_CATALOGO AS SUBTIPO ON ORN.ORN_SUBTIPO = SUBTIPO.ITC_ID LEFT JOIN
		BVQ_BACKOFFICE.CONTRATO_REPORTO CRE ON ORN.CRE_ID=CRE.CRE_ID JOIN
		BVQ_ADMINISTRACION.TITULO_VALOR TIV ON DLI.TIV_ID=TIV.TIV_ID
	WHERE (DLI.DLI_ID = @i_don_id)
	 
	IF EXISTS
			(
				SELECT  TOP (1) HTP_SALDO FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO WHERE POR_ID = @v_port_id and  TIV_ID = @v_tit_id  
				AND HTP_CUPON = @v_cupon AND HTP_ESTADO != @v_estado_port_rev 

				-- NIF 
				AND HTP_CATEGORIA = @v_categoria
				-- FIN NIF

				AND ISNULL(HTP_REPORTADO, 0) = 0  order by  HTP_ID desc
			)

				SET @saldoTit = (	SELECT TOP(1) ISNULL(htp_saldo_c,0) 
									FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO 
									WHERE	POR_ID = @v_port_id and 
											TIV_ID = @v_tit_id and 
											HTP_CUPON = @v_cupon and 
											HTP_ESTADO != @v_estado_port_rev and 
											
											-- NIF
											HTP_CATEGORIA = @v_categoria and
											-- END IF

											ISNULL(HTP_REPORTADO, 0) = 0   order by HTP_ID  desc)
	ELSE
		SET @saldoTit = 0;

	 -- verifica que la orden venga desde reporto asociada a un portafolio y trabaja con la cantidad nominal de la orden de reporto y no con la columna liq_cantidad
	 IF(@v_reporto IS NOT NULL AND @v_reporto > 0)
	 begin
		SET @v_isreporto = 1
		set @v_cantidad  = @v_don_cantidad
	 end
	 ELSE
	 BEGIN
     	SET @v_isreporto = 0
	 END

	IF(@v_port_id<> -1)
	BEGIN

	   EXEC @v_id_estado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
	   @i_code = N'BCK_ES_TIT_POR',
	   @i_status = N'A';

	  IF (@v_subTipoCodigo='C')
	  -- begin si es compra
	  BEGIN
		   SET @saldoTit = @saldoTit + @v_cantidad;
		   
		   IF (@v_isreporto = 1)-- es una orden qeu viene de reporto de un portafolio
		   --begin si es reporto y si es compra
		   BEGIN								
				EXEC [BVQ_BACKOFFICE].[ActualizarEstadoCuentaPortafolioCompra] @i_usr_id, @v_port_id, @i_liq_id, @v_tit_id, @saldoTit, @v_cantidad, @v_precio, @v_cupon, @v_reporto, @i_lga_id
				
				--insertar título del reportante al portafolio
				if @v_reportante_tiv_id is not null
					exec BVQ_BACKOFFICE.InsertarTituloPortafolio
					  @i_usr_id, @v_reportante_tiv_id, @v_port_id, @v_cantidad, 100.0
					 ,@v_fecha_valor
					 ,@v_cupon
					 ,1
					 ,0
					 ,0
					 ,''
					 ,@v_categoria
					 ,NULL
					 ,NULL
					 ,NULL
					 ,NULL
					 ,0
					 ,0
					 ,NULL
					 ,NULL
					 ,NULL
					 ,NULL
					 
					 ,NULL
					 ,NULL
					 
					 ,NULL
					 ,NULL
					 ,NULL
					 ,@i_lga_id
				update htp set liq_id=@i_liq_id from BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO htp
				where TIV_ID=@v_reportante_tiv_id
				 
		   END
		   ELSE
			--begin si no es reporto y si es compra
		   BEGIN
				/*IF exists	(
					SELECT TOP(1)
					TPO_ID FROM BVQ_BACKOFFICE.TITULOS_PORTAFOLIO
					WHERE POR_ID = @v_port_id and TIV_ID = @v_tit_id AND TPO_COBRO_CUPON = @v_cupon

					-- NIF
					AND TPO_CATEGORIA = @v_categoria
					-- FIN NIF
				)
				-- begin si existe titulos_portafolio y si no es reporto y si es compra
				BEGIN
					UPDATE [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
					SET --[TPO_SALDO] = [TPO_SALDO] + @v_cantidad,
					[TPO_CANTIDAD] = [TPO_SALDO] + @v_cantidad
					WHERE [POR_ID] = @v_port_id
					AND [TIV_ID] = @v_tit_id
					AND [TPO_COBRO_CUPON] = @v_cupon
					AND [TPO_ESTADO] = @v_id_estado

					-- NIF
					AND [TPO_CATEGORIA] = @v_categoria
					-- FIN NIF

				END
				-- end si existe titulos_portafolio y si no es reporto y si es compra
				ELSE*/
				-- begin si no existe titulos_portafolio y si no es reporto y si es compra
				BEGIN

					INSERT INTO [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
					([USR_ID]
					,[TIV_ID]
					,[POR_ID]
					,[TPO_CANTIDAD]
					,[TPO_PRECIO_INGRESO]
					,[TPO_FECHA_INGRESO]
					,[TPO_FECHA_REGISTRO]
					,[TPO_ESTADO]
					,[TPO_ULTIMA_REVALUACION]
					,[TPO_COBRO_CUPON]
					,[TPO_CONFIRMA_TITULO]
					--,[TPO_SALDO]
					,[LIQ_ID]

					-- NIF
					,[TPO_CATEGORIA]
					-- FIN NIF
					,TPO_NUMERACION
					)
					select
					@i_usr_id
					,@v_tit_id
					,@v_port_id
					,@v_cantidad
					,@v_precio
					,@v_fecha_valor
					,BVQ_ADMINISTRACION.ObtenerFechaSistema()
					,@v_id_estado
					,null
					,@v_cupon
					,1
					--,@saldoTit
					,@i_liq_id

					-- NIF
					,@v_categoria
					-- FIN NIF
					,lsp_codigo
					from bvq_backoffice.liquidacion liq left join bvq_backoffice.liquidacion_subtitulo lsp on lsp.liq_id=liq.liq_id
					left join bvq_backoffice.titulos_portafolio tpo on tpo.por_id=@v_port_id and tpo.tiv_id=@v_tit_id and isnull(tpo_numeracion,'')=isnull(lsp_codigo,'') and tpo_estado=352
					where liq.liq_id=@i_liq_id and tpo.tpo_id is null
					
					EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
					@i_lga_id = @i_lga_id,
					@i_tabla = 'TITULOS_PORTAFOLIO',
					@i_esquema = N'BVQ_BACKOFFICE',
					@i_operacion = N'I',
					@i_subTipo = N'N',
					@i_columIdName = 'TPO_ID',
					@i_idAfectado = @@IDENTITY;

				END
				-- end si no existe titulos portafolio y si no es reporto y si es compra				
					--INSERTA UN REGISTRO POR LA DIFERNCIA DEL REGISTRO ANTERIOR
				INSERT INTO BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO    
				(    
					POR_ID,	TIV_ID, HTP_FECHA_OPERACION, HTP_COMPRA,
					HTP_PRECIO_COMPRA, HTP_VENTA,HTP_PRECIO_VENTA,     
					HTP_SALDO,LIQ_ID,HTP_ESTADO, HTP_CUPON, HTP_REPORTADO 

					-- NIF
					,HTP_CATEGORIA
					-- FIN NIF
					,HTP_NUMERACION
					,htp_rendimiento
					,htp_comision_bolsa
					,htp_tir
					,htp_rendimiento_retorno
				)
				select
					 @v_port_id ,@v_tit_id ,@v_fecha_valor ,coalesce(lsp_valor_nominal,@v_cantidad)
					,@v_precio,0,0,@saldoTit
					,@i_liq_id ,@v_id_estado,@v_cupon,0

					-- NIF
					,@v_categoria
					-- FIN NIF
					,lsp_codigo
					,@v_rend_liq
					,@v_total_cms
					,@i_tir
					,@i_returnRend
				from bvq_backoffice.liquidacion liq left join bvq_backoffice.liquidacion_subtitulo lsp
				on lsp.liq_id=liq.liq_id where liq.liq_id=@i_liq_id

				if exists(select * from bvq_administracion.parametro where par_codigo='SEPARAR_EN_COMPRAS' and par_valor='SI')
					update bvq_backoffice.historico_titulos_portafolio set htp_numeracion=htp_numeracion + ' id:' + rtrim(scope_identity()) where htp_id=scope_identity()
				
				EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
				@i_lga_id = @i_lga_id,
				@i_tabla = 'HISTORICO_TITULOS_PORTAFOLIO',
				@i_esquema = N'BVQ_BACKOFFICE',
				@i_operacion = N'I',
				@i_subTipo = N'N',
				@i_columIdName = 'HTP_ID',
				@i_idAfectado = @@IDENTITY;
				--end si NO existe historico_titulos_portafolio y si NO es reporto y si es compra
			END
			--end si NO es reporto y si es compra
	  END
	  --end si es compra
	  ELSE 
	  --begin si es venta
	  BEGIN    
		   declare @tpoId as int;  
		   EXEC @v_id_estado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo    
		   @i_code = N'BCK_ES_TIT_POR',    
		   @i_status = N'A';  
		
		   SET @saldoTit = abs(@saldoTit - @v_cantidad);
		    
		   IF(@v_cantidad > 0)
		   --begin si es venta y cantidad>0
		   BEGIN
				IF(@v_isreporto = 1) -- es una orden que viene de reporto de un portafolio		
				--begin si es venta y cantidad>0 y es reporto
				BEGIN
					select @i_usr_id, @v_port_id, @i_liq_id, @v_tit_id, @saldoTit, @v_cantidad,@v_precio,@v_cupon, @v_reporto, @i_lga_id
					EXEC [BVQ_BACKOFFICE].[ActualizarEstadoCuentaPortafolioVenta] @i_usr_id, @v_port_id, @i_liq_id, @v_tit_id, @saldoTit, @v_cantidad,@v_precio,@v_cupon, @v_reporto, @i_lga_id
					
				END
				--end si es venta y cantidad>0 y es reporto
				ELSE
				--begin si es venta y cantidad>0 y NO es reporto
				BEGIN	
					
					/*if exists (SELECT TOP(1) TPO_ID FROM BVQ_BACKOFFICE.TITULOS_PORTAFOLIO
								WHERE POR_ID = @v_port_id and TIV_ID = @v_tit_id AND TPO_COBRO_CUPON = @v_cupon
						
								-- NIF
								AND TPO_CATEGORIA = @v_categoria
								-- FIN NIF
								)
					--begin si es venta y cantidad>0 y NO es reporto y existe titulos_portafolio
					BEGIN

									UPDATE [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
									SET --[TPO_SALDO] =[TPO_SALDO] - @v_cantidad,
									[TPO_CANTIDAD] = [TPO_SALDO] - @v_cantidad
									WHERE [POR_ID] = @v_port_id
									AND [TIV_ID] = @v_tit_id
									AND [TPO_COBRO_CUPON] = @v_cupon
									AND [TPO_ESTADO] = @v_id_estado

									-- NIF
									AND [TPO_CATEGORIA] = @v_categoria
									-- FIN NIF
					END
					--end si es venta y cantidad>0 y NO es reporto y existe titulos_portafolio
					ELSE*/
					--begin si es venta y cantidad>0 y NO es reporto y NO existe titulos_portafolio
					BEGIN
						INSERT INTO [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
						([USR_ID]
						,[TIV_ID]
						,[POR_ID]
						,[TPO_CANTIDAD]
						,[TPO_PRECIO_INGRESO]
						,[TPO_FECHA_INGRESO]
						,[TPO_FECHA_REGISTRO]
						,[TPO_ESTADO]
						,[TPO_ULTIMA_REVALUACION]
						,[TPO_COBRO_CUPON]
						,[TPO_CONFIRMA_TITULO]
						--,[TPO_SALDO]
						,[LIQ_ID]

						-- NIF
						,[TPO_CATEGORIA]
						-- FIN NIF
						,TPO_NUMERACION
						)
						select
						@i_usr_id
						,@v_tit_id
						,@v_port_id
						,@v_cantidad
						,@v_precio
						,@v_fecha_valor
						,BVQ_ADMINISTRACION.ObtenerFechaSistema()
						,@v_id_estado
						,null
						,@v_cupon
						,1
						--,@saldoTit
						,@i_liq_id

						-- NIF
						,@v_categoria
						,lsp_codigo
						from bvq_backoffice.liquidacion liq left join bvq_backoffice.liquidacion_subtitulo lsp on lsp.liq_id=liq.liq_id
						left join bvq_backoffice.titulos_portafolio tpo on tpo.por_id=@v_port_id and tpo.tiv_id=@v_tit_id and isnull(tpo_numeracion,'')=isnull(lsp_codigo,'') and tpo_estado=352
						where liq.liq_id=@i_liq_id and tpo.tpo_id is null

						
						EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
							@i_lga_id = @i_lga_id,
							@i_tabla = 'TITULOS_PORTAFOLIO',
							@i_esquema = N'BVQ_BACKOFFICE',
							@i_operacion = N'I',
							@i_subTipo = N'N',
							@i_columIdName = 'TPO_ID',
							@i_idAfectado = @@IDENTITY;
					END
					--end si es venta y cantidad>0 y NO es reporto y NO existe titulos_portafolio

					IF(@v_isreporto = 0)
					BEGIN
						SET @v_don_cantidad =  @saldoTit;
					END
					
					-- Inserta el  registro por la	cantida que se ingresa en el titulo de garantia
					-- Verifica que el titulo de garantia exista en  el historico de titulos portafolio
					IF ( exists (select 1 from BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HPOR where POR_ID = @v_port_id  and ISNULL( HTP_REPORTADO , 0)= 0 
								AND HTP_CUPON = @v_cupon AND  HTP_ESTADO = @v_id_estado AND TIV_ID =  @v_tit_id 

								-- NIF
								AND HTP_CATEGORIA = @v_categoria
								--FIN NIF

								))
					--begin si es venta y cantidad>0 y NO es reporto y existe historico_titulos_portafolio
					BEGIN

						--Inserta el valor final total de la cantidad de los titulos qeu estnen reporto y garantia
						INSERT INTO BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO    
						(    
							 POR_ID,    
							 TIV_ID,    
							 HTP_FECHA_OPERACION,    
							 HTP_COMPRA,     
							 HTP_PRECIO_COMPRA ,     
							 HTP_VENTA,     
							 HTP_PRECIO_VENTA,     
							 HTP_SALDO,    
							 LIQ_ID,    
							 HTP_ESTADO,
							 HTP_CUPON,
							 HTP_REPORTADO

							-- NIF
							,HTP_CATEGORIA
							-- FIN NIF
							,HTP_NUMERACION
							,htp_rendimiento
							,htp_comision_bolsa
							,htp_tir
							,htp_rendimiento_retorno
						)    
						select
							  @v_port_id    
							 ,@v_tit_id     
							 ,@v_fecha_valor    
							 ,0    
							 ,0    
							 ,coalesce(lsp_valor_nominal,@v_cantidad)
							 ,@v_precio    
							 ,@saldoTit
							 ,@i_liq_id    
							 ,@v_id_estado
							 ,@v_cupon
							 ,0

							-- NIF
							,@v_categoria
							-- END NIF
							,lsp_codigo
							,@v_rend_liq
							,@v_total_cms
							,@i_tir
							,@i_returnRend
							
						from bvq_backoffice.liquidacion liq left join bvq_backoffice.liquidacion_subtitulo lsp
						on lsp.liq_id=liq.liq_id where liq.liq_id=@i_liq_id
						
						
						EXEC [BVQ_SEGURIDAD].[RegistrarAuditoria]
							@i_lga_id = @i_lga_id,
							@i_tabla = 'HISTORICO_TITULOS_PORTAFOLIO',
							@i_esquema = N'BVQ_BACKOFFICE',
							@i_operacion = N'I',
							@i_subTipo = N'N',
							@i_columIdName = 'HTP_ID',
							@i_idAfectado = @@IDENTITY;
						
					END
					--end si es venta y cantidad>0 y NO es reporto y existe historico_titulos_portafolio
			 		ELSE

					--begin si es venta y cantidad>0 y NO es reporto y NO existe historico_titulos_portafolio
					BEGIN
						--Inserta el valor final total de la cantidad de los titulos qeu estnen reporto y garantia
						INSERT INTO BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO    
						(    
							POR_ID,    
							TIV_ID,    
							HTP_FECHA_OPERACION,    
							HTP_COMPRA,     
							HTP_PRECIO_COMPRA ,     
							HTP_VENTA,     
							HTP_PRECIO_VENTA,     
							HTP_SALDO,    
							LIQ_ID,    
							HTP_ESTADO,
							HTP_CUPON,
							HTP_REPORTADO

							-- NIF
							,HTP_CATEGORIA
							-- END NIF
							,HTP_NUMERACION
							,htp_rendimiento
							,htp_comision_bolsa
							,htp_tir
							,htp_rendimiento_retorno
						)
						select
							  @v_port_id
							 ,@v_tit_id
							 ,@v_fecha_valor
							 ,0
							 ,0
							 ,coalesce(lsp_valor_nominal,@v_cantidad)
							 ,@v_precio
							 ,@v_cantidad
							 ,@i_liq_id
							 ,@v_id_estado
							 ,@v_cupon
							 ,0

							-- NIF
							,@v_categoria
							-- END NIF
							,lsp_codigo
							,@v_rend_liq
							,@v_total_cms
							,@i_tir
							,@i_returnRend
						from bvq_backoffice.liquidacion liq left join bvq_backoffice.liquidacion_subtitulo lsp
						on lsp.liq_id=liq.liq_id where liq.liq_id=@i_liq_id
						
						
						
						EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
							@i_lga_id = @i_lga_id,
							@i_tabla = 'HISTORICO_TITULOS_PORTAFOLIO',
							@i_esquema = N'BVQ_BACKOFFICE',
							@i_operacion = N'I',
							@i_subTipo = N'N',
							@i_columIdName = 'HTP_ID',
							@i_idAfectado = @@IDENTITY;
					END
					--end si es venta y cantidad>0 y NO es reporto y NO existe historico_titulos_portafolio
				END
				--end si es venta y cantidad>0 y NO es reporto
							
		 END
		 --end si es venta y cantidad>0
	  END
	  --end si es venta
	END
  
	/*********************************	
	Actualiza títulos portafolio
	**************/   
	IF (@v_subTipoCodigo='C')
	BEGIN
		IF(@v_port_id>0)
		BEGIN 
			declare @v_tpo_id int
			SELECT @v_tpo_id = TPO_ID FROM BVQ_BACKOFFICE.TITULOS_PORTAFOLIO WHERE POR_ID = @v_port_id and TIV_ID = @v_tit_id AND TPO_COBRO_CUPON = @v_cupon AND TPO_CATEGORIA = @v_categoria

			IF(@v_tpo_id>0)
			BEGIN 
				UPDATE BVQ_BACKOFFICE.LIQUIDACION_SUBTITULO SET TPO_ID = @v_tpo_id WHERE LIQ_ID=@i_liq_id
				INSERT INTO SUBTITULO_PORTAFOLIO (
					POR_ID,LIQ_ID,TPO_ID,DON_ID,LSP_CODIGO,LSP_VALOR_NOMINAL,LSP_IS_LIQ,USR_ID,PSU_ESTADO
				) (SELECT
					POR_ID,LIQ_ID,TPO_ID,DON_ID,LSP_CODIGO,LSP_VALOR_NOMINAL,LSP_IS_LIQ,USR_ID,'A'
				FROM BVQ_BACKOFFICE.LIQUIDACION_SUBTITULO WHERE LIQ_ID = @i_liq_id)		
			END
		END
	END
	BEGIN
		IF(@v_port_id>0)
		BEGIN
			--V=Vendido
			UPDATE SUBTITULO_PORTAFOLIO SET PSU_ESTADO = 'V' WHERE PSU_ID IN (SELECT PSU_ID FROM BVQ_BACKOFFICE.LIQUIDACION_SUBTITULO WHERE LIQ_ID=@i_liq_id)
		END
	END
	if (@v_port_id<>-1)
	begin
		if exists(select * from bvq_administracion.parametro where par_codigo='SEPARAR_EN_COMPRAS' and par_valor='SI')
		begin
			exec bvq_backoffice.GenerarCompraVentaPortafolio
			exec bvq_administracion.GenerarTituloFlujoComun
			exec bvq_administracion.GenerarTasaValorCompact
			exec bvq_backoffice.GenerarCompraVentaFlujo
			update htp set htp_tpo_id=tpo_id_c from bvq_backoffice.historico_titulos_portafolio htp where tpo_id_c<>htp_tpo_id or htp_tpo_id is null and tpo_id_c is not null
			update htp set htp_numeracion=isnull(htp.htp_numeracion,'')+' id:'+rtrim(htp.htp_id)
			/*from bvq_backoffice.historico_titulos_portafolio htp
			join bvq_administracion.titulo_valor tiv on htp.tiv_id=tiv.tiv_id
			where htp_compra>0 and tiv_fecha_vencimiento is not null*/
			from bvq_backoffice.grupocompras htp
			where charindex(' id:',htp.htp_numeracion)=0 and htp.htp_fecha_operacion>'2016-09-01T23:59:59'

			exec _temp.refreshtpo
			update htp set htp_tpo_id=tpo_id1 from bvq_backoffice.duptpos d join bvq_backoffice.historico_titulos_portafolio htp on htp.htp_id=htp_id0
			update htp set htp_tpo_id=tpo_id_c from bvq_backoffice.historico_titulos_portafolio htp where tpo_id_c<>htp_tpo_id or htp_tpo_id is null and tpo_id_c is not null
			delete tpo from bvq_backoffice.titulos_portafolio tpo left join bvq_backoffice.historico_titulos_portafolio htp on tpo_id_c=tpo_id where tpo_id_c is null

			update htp set compra_htp_id=compra.htp_id from bvq_backoffice.historico_titulos_portafolio htp join
			bvq_backoffice.historico_titulos_portafolio compra
			join bvq_administracion.titulo_valor tiv on compra.tiv_id=tiv.tiv_id
			on htp.htp_tpo_id=compra.htp_tpo_id and compra.htp_estado=352 and compra.htp_compra>0 and tiv_fecha_vencimiento is not null
		end
		exec _temp.refreshtpo
	end
END