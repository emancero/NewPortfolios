-- =====================================================================
-- Author:		Jimmy Chuico
-- Create date: 28/12/2008
-- Description:	Se ejecuta el vencimiento del reporto
-- Cambios:		GCA: 21-abr-2010: Inclusión de categoría para NIF´s
--				PSA: 16-06-2014 Cambio detalle liquidación
-- =====================================================================

CREATE PROCEDURE [BVQ_BACKOFFICE].[ReliquidarReporto]
	@i_creId	INT
	,@i_lga_id  int
AS
BEGIN

	DECLARE @v_categoria int;

	DECLARE @v_port_id INT, @saldoTit DECIMAL(38,4), @v_cantida_rep decimal(38,4), @v_id_estado int, @v_id_estadoTit_can int, @v_precio float;
	DECLARE @v_id_estado_gar_act INT, @v_tivId int, @v_id_estado_rep_rel int, @v_cant_rest DECIMAL(38,4), @v_compra int, @v_subtipoOrden int;
	DECLARE @v_rentaFija INT, @v_tipoRenta int, @v_cupon bit, @v_htp_id_rest int, @v_tit_port_rep int, @v_liqId int, @v_id_estadoTit_eli int,  @v_identity int;
	DECLARE @v_fechaFinalizacion datetime;
	
	SELECT @v_port_id = POR_ID, @v_cantida_rep = CRE_CANTIDAD, @v_precio = cre_precio_spot
	FROM BVQ_BACKOFFICE.CONTRATO_REPORTO
	WHERE CRE_ID = @i_creId
	
	EXEC @v_id_estado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo    
			@i_code = N'BCK_ES_TIT_POR',    
			@i_status = N'A';
			
	EXEC @v_id_estadoTit_can = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
			@i_code = N'BCK_ES_TIT_POR',
			@i_status = N'C'; --cancelado

	EXEC @v_id_estadoTit_eli = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
			@i_code = N'BCK_ES_TIT_POR',
			@i_status = N'E'; --Eliminado
			
	EXEC @v_id_estado_gar_act = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
						@i_code = N'BCK_GAR_TITULO',
						@i_status = N'A';
						
	EXEC @v_id_estado_rep_rel = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
					@i_code = N'BCK_ESTADOS_REPORTO',
					@i_status = N'RL';
					
	EXEC @v_compra= [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
					@i_code = N'ORD_SUB_TIPO',
					@i_status = N'C';
					
	-- TIPO DE RENTA
	EXEC @v_rentaFija = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
	   @i_code = N'TIPO_RENTA',
	   @i_status = N'REN_FIJA';
	
	SELECT @v_subtipoOrden = ORN_SUBTIPO FROM BVQ_BACKOFFICE.ORDEN_NEGOCIACION WHERE CRE_ID = @i_creId
	
	-- Selecciona la liquidación a la que pertenece el reporto a reliquidar
	SELECT @v_liqId = L.LIQ_ID,@v_fechaFinalizacion=C.CRE_FECHA_FINALIZACION FROM BVQ_BACKOFFICE.CONTRATO_REPORTO C INNER JOIN BVQ_BACKOFFICE.ORDEN_NEGOCIACION O
	ON C.CRE_ID = O.CRE_ID INNER JOIN BVQ_BACKOFFICE.DETALLE_LIQUIDACION DL 
	ON O.ORN_ID = DL.ORN_ID INNER JOIN  BVQ_BACKOFFICE.LIQUIDACION L 
	ON DL.DLI_ID = L.DLI_ID
	WHERE C.CRE_ID = @i_creId

	IF(@v_port_id IS NOT NULL) --si el reporto es por portafolio
	BEGIN
		-- referente a títulos que constan en el portafolio
		DECLARE  Titulo CURSOR FOR
		SELECT distinct tiv_id 

		-- NIF
		, HTP_CATEGORIA
		-- FIN NIF

		from BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO 
		WHERE POR_ID = @v_port_id AND HTP_ESTADO = @v_id_estado AND LIQ_ID = @v_liqId
		OPEN Titulo
		FETCH NEXT FROM Titulo INTO @v_tivId

		-- NIF
		, @v_categoria
		-- FIN NIF
		
		-- while titulos en la liquidacion
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT	@v_tipoRenta = TIV_TIPO_RENTA
			FROM	BVQ_ADMINISTRACION.TITULO_VALOR
			WHERE	TIV_ID = @v_tivId

			IF ( @v_rentaFija = @v_tipoRenta )
				SET @v_cupon = 1
			ELSE
				SET @v_cupon = 0

			SET @saldoTit = (SELECT TOP(1) ISNULL(HTP_SALDO,0)
							FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
							WHERE POR_ID = @v_port_id and  TIV_ID = @v_tivId AND HTP_CUPON = @v_cupon
							AND HTP_ESTADO = @v_id_estado AND ISNULL(HTP_REPORTADO, 0) = 0

							-- NIF
							AND HTP_CATEGORIA = @v_categoria
							-- FIN NIF

							order by HTP_ID  desc)

			IF (@saldoTit  IS NULL)
				SET @saldoTit = 0


			--CONSULTA EL MONTO QUE DEBE REESTABLECER AL PORTAFOLIO
			SELECT @v_cant_rest = SUM(
				ISNULL(
					HTP_SALDO
					--AMORTIZADO
					/ISNULL(
						TFLOP.TFL_CAPITAL/ISNULL(TFLRE.TFL_CAPITAL,0)
						,1
					)
					,0
				)
			)
			FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HT inner join BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO TP
			ON HT.HTP_ID = TP.HTP_ID AND TPR_ESTADO = @v_id_estado

			-- NIF
			AND TP.TPR_CATEGORIA = @v_categoria AND TP.TPR_CATEGORIA = HT.HTP_CATEGORIA
			-- FIN NIF
			
			--AMORTIZADO
			LEFT JOIN BVQ_ADMINISTRACION.TITULO_FLUJO TFLOP
			ON HT.TIV_ID=TFLOP.TIV_ID
			AND HT.HTP_FECHA_OPERACION BETWEEN TFLOP.TFL_FECHA_INICIO AND dateadd(S,-1,TFLOP.TFL_FECHA_VENCIMIENTO)
			LEFT JOIN BVQ_ADMINISTRACION.TITULO_FLUJO TFLRE
			ON HT.TIV_ID=TFLRE.TIV_ID
			AND @v_fechaFinalizacion BETWEEN TFLRE.TFL_FECHA_INICIO AND dateadd(S,-1,TFLRE.TFL_FECHA_VENCIMIENTO)

			WHERE POR_ID = @v_port_id and  HT.TIV_ID = @v_tivId AND HTP_CUPON = @v_cupon  AND HTP_ESTADO = @v_id_estado AND ISNULL(HTP_REPORTADO, 0) = 1 AND TP.CRE_ID = @i_creId
			
			-- si el título tiene cantidad de acciones u obligaciones para devolver al portafolio
			IF(@v_cant_rest IS NULL)
				SET @v_cant_rest = 0
		
			-- si existe htp
			IF exists (	SELECT 1 -- TOP(1) TPO_ID 
						FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO 
						WHERE POR_ID = @v_port_id and TIV_ID = @v_tivId AND HTP_CUPON = @v_cupon  AND HTP_REPORTADO = 0

						-- NIF
						AND HTP_CATEGORIA = @v_categoria
						-- FIN NIF

						)
						--EMN: 21-abr-2020 Si se reliquida reportos de compra por 1era vez para un título
						--entonces no encuentra el título y entraba en el else que no está hecho para compras
						--por eso ahora las reliquidaciones de compra siempre entran en el if
						or @v_subtipoOrden = @v_compra
						
			begin

				--si existe htp y v_cant_rest>0
				IF(@v_cant_rest > 0)
				BEGIN

					IF(@v_subtipoOrden = @v_compra)
						SET @saldoTit = abs(@saldoTit - @v_cant_rest);
					ELSE
						SET @saldoTit = @saldoTit + @v_cant_rest

					UPDATE [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
					SET [TPO_CANTIDAD] = @saldoTit
					WHERE [POR_ID] = @v_port_id
						AND [TIV_ID] = @v_tivId
						AND [TPO_COBRO_CUPON] = @v_cupon --false
						AND [TPO_ESTADO] = @v_id_estado

						-- NIF
						AND TPO_CATEGORIA = @v_categoria
						-- FIN NIF						
						
					EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
						@i_lga_id = @i_lga_id,
						@i_tabla = 'CONTRATO_REPORTO',
						@i_esquema = N'BVQ_BACKOFFICE',
						@i_operacion = N'U',
						@i_subTipo = N'A',
						@i_columIdName = 'CRE_ID',
						@i_idAfectado = @i_creId;

					UPDATE BVQ_BACKOFFICE.CONTRATO_REPORTO 
					SET CRE_ESTADO = @v_id_estado_rep_rel
					WHERE CRE_ID = @i_creId
					
					EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
						@i_lga_id = @i_lga_id,
						@i_tabla = 'CONTRATO_REPORTO',
						@i_esquema = N'BVQ_BACKOFFICE',
						@i_operacion = N'U',
						@i_subTipo = N'N',
						@i_columIdName = 'CRE_ID',
						@i_idAfectado = @i_creId;
				--fin si existe htp y v_cant_rest>0
				END


				-- Para restablecer los de reporto y garantias		
				
				-- PRINT 'NO DEBIO ENTRAR AQUI'
				-- DECLARE @v_identity int
				-- Selecciona el tipo de portafolio reporto para saber si es de garantía, reportado  o reportante
				SELECT top 1  @v_tit_port_rep = TPR_TIPO_REPORTO
				FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO  HP INNER JOIN  BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO TPR 
				ON HP.HTP_ID = TPR.HTP_ID
				WHERE POR_ID = @v_port_id AND HTP_CUPON = @v_cupon	
				AND HP.HTP_ESTADO = @v_id_estado
				AND HP.TIV_ID = @v_tivId AND HTP_REPORTADO = 1
				
				-- si existe htp y v_cant_rest>0
				IF(@v_cant_rest > 0)
				BEGIN
					-- si existe htp y v_cant_rest>0 y v_subtipoorden=v_compra
					IF(@v_subtipoOrden = @v_compra) -- Si es de compra  se debe poner la cantidad y precio de compra  en venta y precio de venta
					BEGIN
						INSERT INTO BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
						(
							[POR_ID]
						   ,[TIV_ID]
						   ,[HTP_FECHA_OPERACION]
						   ,[HTP_COMPRA]
						   ,[HTP_PRECIO_COMPRA]
						   ,[HTP_VENTA]
						   ,[HTP_PRECIO_VENTA]
						   ,[HTP_SALDO]
						   ,[LIQ_ID]
						   ,[HTP_ESTADO]
						   ,[HTP_CUPON]
						   ,[HTP_REPORTADO]

							-- NIF
							, [HTP_CATEGORIA]
							-- FIN NIF
						)
						SELECT TOP (1) @v_port_id, HP.TIV_ID,@v_fechaFinalizacion/*BVQ_ADMINISTRACION.ObtenerFechaSistema()*/,0, 0, @v_cant_rest, 
						@v_precio,	--BVQ_ADMINISTRACION.ObtenerPrecioVector(BVQ_ADMINISTRACION.ObtenerFechaSistema(),HP.TIV_ID), 
						@saldoTit, @v_liqId, HTP_ESTADO, @v_cupon, 1 --23-sep-2020
						, @v_categoria
						FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO  HP INNER JOIN BVQ_BACKOFFICE.TITULOS_PORTAFOLIO TP
						ON HP.POR_ID = TP.POR_ID
						AND HP.HTP_CATEGORIA = TP.TPO_CATEGORIA
						WHERE HP.POR_ID = @v_port_id AND HP.HTP_CUPON = TP.TPO_COBRO_CUPON AND HTP_CUPON = @v_cupon
						AND HP.HTP_ESTADO = @v_id_estado AND HP.TIV_ID = @v_tivId and ISNULL(HP.HTP_REPORTADO, 0) = 0
						AND HP.HTP_CATEGORIA = @v_categoria
						ORDER BY HTP_ID DESC
					--fin si existe htp y v_cant_rest>0 y v_subtipoorden=compra
					END
					--si existe htp y v_cant_rest>0 y v_subtipoorden<>compra
					ELSE
					BEGIN
						INSERT INTO BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
						(
							[POR_ID]
						   ,[TIV_ID]
						   ,[HTP_FECHA_OPERACION]
						   ,[HTP_COMPRA]
						   ,[HTP_PRECIO_COMPRA]
						   ,[HTP_VENTA]
						   ,[HTP_PRECIO_VENTA]
						   ,[HTP_SALDO]
						   ,[LIQ_ID]
						   ,[HTP_ESTADO]
						   ,[HTP_CUPON]
						   ,[HTP_REPORTADO]
							, [HTP_CATEGORIA]
						)

						SELECT TOP (1) @v_port_id, HP.TIV_ID,@v_fechaFinalizacion/*BVQ_ADMINISTRACION.ObtenerFechaSistema()*/,@v_cant_rest, 
						@v_precio,	--BVQ_ADMINISTRACION.ObtenerPrecioVector(BVQ_ADMINISTRACION.ObtenerFechaSistema(),HP.TIV_ID),
						0,0,@saldoTit, @v_liqId, HTP_ESTADO, @v_cupon, 0
						, @v_categoria
						FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO  HP INNER JOIN BVQ_BACKOFFICE.TITULOS_PORTAFOLIO TP
						ON HP.POR_ID = TP.POR_ID
						AND HP.HTP_CATEGORIA = TP.TPO_CATEGORIA
						WHERE HP.POR_ID = @v_port_id AND HP.HTP_CUPON = TP.TPO_COBRO_CUPON AND HTP_CUPON = @v_cupon
						AND HP.HTP_ESTADO = @v_id_estado AND HP.TIV_ID = @v_tivId and ISNULL(HP.HTP_REPORTADO, 0) = 0
						AND HP.HTP_CATEGORIA = @v_categoria
						ORDER BY HTP_ID DESC
					--fin si existe htp y v_cant_rest>0 y v_subtipoorden<>compra
					END
					set @v_identity = @@identity;

					EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
					@i_lga_id = @i_lga_id,
					@i_tabla = 'HISTORICO_TITULOS_PORTAFOLIO',
					@i_esquema = N'BVQ_BACKOFFICE',
					@i_operacion = N'I',
					@i_subTipo = N'N',
					@i_columIdName = 'HTP_ID',
					@i_idAfectado = @@IDENTITY;
					
					-- anula los títulos que están como materia de reporto o garantías
					if not EXISTS (select * from bvq_administracion.parametro where par_codigo='PORTAFOLIOS_02' and par_valor='SI')
						UPDATE BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
						SET HTP_ESTADO = @v_id_estadoTit_can
						WHERE HTP_ESTADO = @v_id_estado AND HTP_ID <> @v_identity
						AND TIV_ID = @v_tivId 
						AND POR_ID = @v_port_id 
						AND LIQ_ID = @v_liqId 
					
					UPDATE BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO
					SET TPR_ESTADO = @v_id_estadoTit_can
					WHERE TPR_ESTADO = @v_id_estado 
					and CRE_ID = @i_creId
					AND HTP_ID IN (SELECT HTP_ID FROM   BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
									WHERE HTP_ESTADO = @v_id_estado  AND TIV_ID = @v_tivId AND HTP_CUPON = @v_cupon AND HTP_REPORTADO = 1
									AND HTP_CATEGORIA = @v_categoria
									)
					--fin si existe htp y v_cant_rest>0					
				END
						
				--fin si existe htp
			END
			--si no existe htp
			ELSE -- EN CASO de ser una reporto, como una orden de compra y no tenga en  el portafolio el titulo que lleva el detalle de la orden
			BEGIN
				/*PRINT 'ENTRO AQUI QUE NO HAY'
				PRINT @v_cant_rest
				PRINT 'LIQ'
				PRINT @v_liqId
				PRINT 'SALDO TITULO'
				print @saldoTit*/
				--si no existe htp y v_cant_rest>0
				IF(@v_cant_rest > 0)
				BEGIN

					IF(@v_subtipoOrden = @v_compra)
						SET @saldoTit = abs(@saldoTit - @v_cant_rest);
					ELSE
						SET @saldoTit = @saldoTit + @v_cant_rest

					UPDATE [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
					SET [TPO_ESTADO] = @v_id_estadoTit_eli
					WHERE [POR_ID] = @v_port_id
						AND [TIV_ID] = @v_tivId
						AND [TPO_COBRO_CUPON] = @v_cupon --false
						AND [TPO_ESTADO] = @v_id_estado

						-- NIF
						AND TPO_CATEGORIA = @v_categoria
						-- FIN NIF						
						
					EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
						@i_lga_id = @i_lga_id,
						@i_tabla = 'CONTRATO_REPORTO',
						@i_esquema = N'BVQ_BACKOFFICE',
						@i_operacion = N'U',
						@i_subTipo = N'A',
						@i_columIdName = 'CRE_ID',
						@i_idAfectado = @i_creId;

					UPDATE BVQ_BACKOFFICE.CONTRATO_REPORTO 
					SET CRE_ESTADO = @v_id_estado_rep_rel
					WHERE CRE_ID = @i_creId
					
					EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
						@i_lga_id = @i_lga_id,
						@i_tabla = 'CONTRATO_REPORTO',
						@i_esquema = N'BVQ_BACKOFFICE',
						@i_operacion = N'U',
						@i_subTipo = N'N',
						@i_columIdName = 'CRE_ID',
						@i_idAfectado = @i_creId;
					

					--Inserta un nuevo registro con el nuevo saldo
					 INSERT INTO BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
						(
							[POR_ID]
						   ,[TIV_ID]
						   ,[HTP_FECHA_OPERACION]
						   ,[HTP_COMPRA]
						   ,[HTP_PRECIO_COMPRA]
						   ,[HTP_VENTA]
						   ,[HTP_PRECIO_VENTA]
						   ,[HTP_SALDO]
						   ,[LIQ_ID]
						   ,[HTP_ESTADO]
						   ,[HTP_CUPON]
						   ,[HTP_REPORTADO]

							-- NIF
							, [HTP_CATEGORIA]
							-- FIN NIF
						)

						SELECT TOP (1) @v_port_id, HP.TIV_ID,@v_fechaFinalizacion/*BVQ_ADMINISTRACION.ObtenerFechaSistema()*/, HTP_COMPRA, HTP_PRECIO_COMPRA,
						@v_cant_rest,HTP_PRECIO_VENTA, abs(HTP_SALDO - @saldoTit), @v_liqId, HTP_ESTADO, @v_cupon, 0

						-- NIF
						, @v_categoria
						-- FIN NIF

						FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO  HP
						
						WHERE HP.POR_ID = @v_port_id AND HTP_CUPON = @v_cupon
						AND HP.HTP_ESTADO = @v_id_estado AND HP.TIV_ID = @v_tivId and ISNULL(HP.HTP_REPORTADO, 0) = 1

						-- NIF
						AND HP.HTP_CATEGORIA = @v_categoria
						-- FIN NIF
					
						ORDER BY HP.HTP_ID DESC

						

						set @v_identity = @@identity;

						EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
						@i_lga_id = @i_lga_id,
						@i_tabla = 'HISTORICO_TITULOS_PORTAFOLIO',
						@i_esquema = N'BVQ_BACKOFFICE',
						@i_operacion = N'I',
						@i_subTipo = N'N',
						@i_columIdName = 'HTP_ID',
						@i_idAfectado = @@IDENTITY;
						
						-- anula los títulos que están como materia de reporto o garantías
						UPDATE BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
						SET HTP_ESTADO = @v_id_estadoTit_can
						WHERE HTP_ESTADO = @v_id_estado AND HTP_ID <> @v_identity
						AND TIV_ID = @v_tivId 
						-- AND HTP_CUPON = @v_cupon 
						AND POR_ID = @v_port_id 
						AND LIQ_ID = @v_liqId 
					
				--fin si no existe htp y v_cant_rest>0
				END
			--fin si no existe htp
			END
			
			/*IF( exists(	select 1 
						from BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HPOR
						where POR_ID = @v_port_id  and ISNULL( HTP_REPORTADO , 0)= 0 
						AND HTP_CUPON = @v_cupon AND  HTP_ESTADO = @v_id_estado AND TIV_ID =  @v_tivId

						-- NIF
						AND HTP_CATEGORIA = @v_categoria
						-- FIN NIF

			 ))
			BEGIN
				PRINT 'NO DEBIO ENTRAR AQUI'
				--DECLARE @v_identity int
				-- Selecciona el tipo de portafolio reporto para saber si es de garantía, reportado  o reportante
				SELECT top 1  @v_tit_port_rep = TPR_TIPO_REPORTO
				FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO  HP INNER JOIN  BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO TPR 
				ON HP.HTP_ID = TPR.HTP_ID
				WHERE POR_ID = @v_port_id AND HTP_CUPON = @v_cupon	
				AND HP.HTP_ESTADO = @v_id_estado
				AND HP.TIV_ID = @v_tivId AND HTP_REPORTADO = 1
				
				-- si el título tiene cantidad de acciones u obligaciones para devolver al portafolio
				IF(@v_cant_rest > 0)
				BEGIN

					INSERT INTO BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
					(
						[POR_ID]
					   ,[TIV_ID]
					   ,[HTP_FECHA_OPERACION]
					   ,[HTP_COMPRA]
					   ,[HTP_PRECIO_COMPRA]
					   ,[HTP_VENTA]
					   ,[HTP_PRECIO_VENTA]
					   ,[HTP_SALDO]
					   ,[LIQ_ID]
					   ,[HTP_ESTADO]
					   ,[HTP_CUPON]
					   ,[HTP_REPORTADO]

						-- NIF
						, [HTP_CATEGORIA]
						-- FIN NIF
					)

					SELECT TOP (1) @v_port_id, HP.TIV_ID,BVQ_ADMINISTRACION.ObtenerFechaSistema(),@v_cant_rest, HTP_PRECIO_COMPRA,
					HTP_VENTA,HTP_PRECIO_VENTA,@saldoTit, HP.LIQ_ID, HTP_ESTADO, @v_cupon, 0

					-- NIF
					, @v_categoria
					-- FIN NIF

					FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO  HP INNER JOIN BVQ_BACKOFFICE.TITULOS_PORTAFOLIO TP
					ON HP.POR_ID = TP.POR_ID

					-- NIF
					AND HP.HTP_CATEGORIA = TP.TPO_CATEGORIA
					-- FIN NIF

					WHERE HP.POR_ID = @v_port_id AND HP.HTP_CUPON = TP.TPO_COBRO_CUPON AND HTP_CUPON = @v_cupon
					AND HP.HTP_ESTADO = @v_id_estado AND HP.TIV_ID = @v_tivId and ISNULL(HP.HTP_REPORTADO, 0) = 0

					-- NIF
					AND HP.HTP_CATEGORIA = @v_categoria
					-- FIN NIF

					set @v_identity = @@identity;

					EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
					@i_lga_id = @i_lga_id,
					@i_tabla = 'HISTORICO_TITULOS_PORTAFOLIO',
					@i_esquema = N'BVQ_BACKOFFICE',
					@i_operacion = N'I',
					@i_subTipo = N'N',
					@i_columIdName = 'HTP_ID',
					@i_idAfectado = @@IDENTITY;
					
					-- anula los títulos que están como materia de reporto o garantías
					UPDATE BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
					SET HTP_ESTADO = @v_id_estadoTit_can
					WHERE HTP_ESTADO = @v_id_estado AND HTP_ID <> @v_identity
					AND TIV_ID = @v_tivId 
					-- AND HTP_CUPON = @v_cupon 
					AND POR_ID = @v_port_id 
					AND LIQ_ID = @v_liqId 

					UPDATE BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO
					SET TPR_ESTADO = @v_id_estadoTit_can
					WHERE TPR_ESTADO = @v_id_estado 
					and CRE_ID = @i_creId
					AND HTP_ID IN (SELECT HTP_ID FROM   BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
									WHERE HTP_ESTADO = @v_id_estado  AND TIV_ID = @v_tivId AND HTP_CUPON = @v_cupon AND HTP_REPORTADO = 1

									-- NIF
									AND HTP_CATEGORIA = @v_categoria
									-- FIN NIF

									)
				END
				
			END
			*/	--ojo poner el caso cuando e una orden de compra
			FETCH NEXT FROM Titulo INTO @v_tivId
			
			 --NIF 
				, @v_categoria
			 --FIN NIF
		--fin while titulos en la liquidacion
		END
		CLOSE Titulo
		DEALLOCATE Titulo
	END
	ELSE
	BEGIN

		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = 'CONTRATO_REPORTO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'U',
		@i_subTipo = N'A',
		@i_columIdName = 'CRE_ID',
		@i_idAfectado =@i_creId ;

			UPDATE BVQ_BACKOFFICE.CONTRATO_REPORTO 
			SET CRE_ESTADO = @v_id_estado_rep_rel
			WHERE CRE_ID = @i_creId

		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = 'CONTRATO_REPORTO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'U',
		@i_subTipo = N'N',
		@i_columIdName = 'CRE_ID',
		@i_idAfectado =@i_creId ;

	END

END