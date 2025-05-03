-- =======================================================================================================================================
-- Author:		Pablo Sanmartin
-- Create date: 20/12/2008
-- Description:	Reversa una liquidación una liquidación
-- Parametros:  
-- Cambios:		JCH: 18-jun-2009: para que inserte los datos del portafolio en el historico 
--				JCH: 18-nov-2009: para saber cuando una orden es de reporto asociada a un portafolio, luego tomar el campo don cantidad para restar el 
--				 el valor efectivo actual a lo que se reversa
--				GCA: 21-abr-2010: Se incluye la variable categoría para NIF´s
--				PSA: 26/05/2014: Detalle liquidación
--				PSA: 13/05/2015: Actualiza estado liquidaciòn
-- =======================================================================================================================================

CREATE PROCEDURE [BVQ_BACKOFFICE].[ReversarLiquidacion]
	 @i_liq_id int
	 ,@i_usr_id int
	 ,@i_fecha datetime
	 ,@o_resul int output 
	 ,@o_com_id int output
	 ,@i_lga_id int		
AS
BEGIN

	SET NOCOUNT ON;	

		DECLARE @v_id_estado int, @v_id_estado_port int,@v_id_estadoPort int, @v_id_estado_portAC int,@v_dli_id int, @v_com_id int;
		DECLARE @v_est_rev_det_cxp int,@v_est_rev_det_cxc int,@v_est_rev_cxp int,@v_est_rev_cxc int, @v_est_orn int
		DECLARE @o_secuencial varchar(50),@tmp_status varchar(2);
		DECLARE @v_monId int, @v_saldo_efectivo float,  @v_estadoLiquidacion int, @v_valor_efectivo FLOAT;
		DECLARE @Error int, @v_id_estadoPortaAct int;
					
		SET @o_resul = -2; --No se puede anular la liquidación
										
		/****************************************************************************		
		Obtiene los estado de reverso para las CxC y CxP					INICIO		
		******************************************************************************/
		EXEC @v_id_estado_portAC = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
		@i_code = N'BCK_ES_TIT_POR',
		@i_status = N'A';
		
		
		EXEC @v_est_rev_det_cxp = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
		@i_code = N'BCK_EST_DET_CXP',
		@i_status = N'RE';
		
		EXEC @v_est_rev_det_cxc = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
		@i_code = N'BCK_EST_DET_CXC',
		@i_status = N'RE';
		
		EXEC @v_est_rev_cxp = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
		@i_code = N'BCK_EST_CXC',
		@i_status = N'R';
		
		EXEC @v_est_rev_cxc = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
		@i_code = N'BCK_EST_CXC',
		@i_status = N'R';
		
		/****************************************************************************		
		Obtiene los estado de reverso para las CxC y CxP					FINAL
		******************************************************************************/
	/*BEGIN TRAN*/
		
		DECLARE @v_categoria int;
		DECLARE @v_port int, @v_reporto int, @v_don_cantidad float
		DECLARE @v_subTipoOrden varchar(50);
		DECLARE @v_orn_id INT;
		DECLARE @v_saldo decimal(38, 2), @v_tivId int ;
		
		SELECT @v_port = ISNULL(ORN.POR_ID, - 1), @v_subTipoOrden = ORD_SUBTIPO.ITC_CODIGO,@v_com_id = LIQ.COM_ID,@v_dli_id = DON.DLI_ID,
			   @v_orn_id = ORN.ORN_ID, @v_reporto =  ORN.CRE_ID, @v_don_cantidad = DON.DLI_CANTIDAD

				-- NIF
				, @v_categoria = LIQ.LIQ_CATEGORIA
				-- FIN NIF

		FROM BVQ_BACKOFFICE.LIQUIDACION AS LIQ INNER JOIN
		BVQ_BACKOFFICE.DETALLE_LIQUIDACION AS DON ON LIQ.DLI_ID = DON.DLI_ID INNER JOIN
		BVQ_BACKOFFICE.ORDEN_NEGOCIACION AS ORN ON DON.ORN_ID = ORN.ORN_ID INNER JOIN
		BVQ_ADMINISTRACION.ITEM_CATALOGO AS ORD_SUBTIPO ON ORN.ORN_SUBTIPO = ORD_SUBTIPO.ITC_ID
		WHERE (LIQ.LIQ_ID = @i_liq_id)
	
		IF(@v_port=-1)
		BEGIN
			SET @o_resul = -1;
		END
		ELSE
		BEGIN
		
			-- GCA: 5-may-2010: Se obtiene si la liquidación fue por reporto o no
			declare @v_esReporto	int
			
			if exists (select 1 from BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO
						where htp_id in (select htp_id from BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
														where liq_id = @i_liq_id))
				set @v_esReporto = 1 -- Sí es una liquidación de reporto de portafolio
			else
				set @v_esReporto = 0 -- No es una liquidación de reporto de portafolio

			IF(@v_subTipoOrden='C')
			BEGIN
				--IF(EXISTS(SELECT 1 FROM BVQ_BACKOFFICE.TITULOS_PORTAFOLIO WHERE  LIQ_ID = @i_liq_id AND TPO_ESTADO = @v_id_estado_portAC))
				IF(EXISTS(SELECT 1 FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO WHERE  LIQ_ID = @i_liq_id AND HTP_ESTADO = @v_id_estado_portAC 

				-- NIF
				AND HTP_CATEGORIA = @v_categoria
				-- FIN NIF

					))
				BEGIN

					EXEC @v_id_estado_port = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
					@i_code = N'BCK_ES_TIT_POR',
					@i_status = N'C';

					--Obtiene el útlimo saldo del histórico  EL saldo del ultimo
					/*SELECT TOP (1) @v_saldo = HTP_SALDO, @v_tivId = TIV_ID FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO WHERE POR_ID = @v_port AND LIQ_ID = @i_liq_id
					AND HTP_ESTADO  = @v_id_estadoPort  AND HTP_REPORTADO = @v_esReporto ORDER BY HTP_ID DESC*/
					
					DECLARE Titulo CURSOR FOR
					SELECT   ISNULL(SUM(HTP_SALDO),0),   TIV_ID
					FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO 
					WHERE POR_ID = @v_port AND LIQ_ID = @i_liq_id AND HTP_REPORTADO = @v_esReporto  AND HTP_ESTADO = @v_id_estado_portAC 

					-- NIF
					AND HTP_CATEGORIA = @v_categoria
					-- FIN NIF

					GROUP BY TIV_ID
					OPEN Titulo
					FETCH NEXT FROM Titulo INTO @v_saldo, @v_tivId
					WHILE @@FETCH_STATUS  = 0
					BEGIN
						IF(@v_saldo IS NULL)
							SET @v_saldo = 0;

						UPDATE [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
						SET --[TPO_SALDO] = [TPO_SALDO] - @v_saldo
						[TPO_CANTIDAD] = [TPO_CANTIDAD] - @v_saldo
						WHERE [POR_ID] = @v_port
						AND [TPO_ESTADO] = @v_id_estado_portAC AND TIV_ID = @v_tivId

						-- NIF
						AND TPO_CATEGORIA = @v_categoria
						-- FIN NIF

						FETCH NEXT FROM Titulo INTO @v_saldo, @v_tivId
					END
					CLOSE Titulo
					DEALLOCATE Titulo

					/*UPDATE BVQ_BACKOFFICE.TITULOS_PORTAFOLIO SET TPO_SALDO = TPO_SALDO - @v_saldo -- AND TPO_ESTADO = @v_id_estado_port
					WHERE LIQ_ID = @i_liq_id AND TPO_ESTADO = @v_id_estado_portAC;*/
					
					EXEC @v_id_estado_port = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
					@i_code = N'BCK_ES_TIT_POR',
					@i_status = N'R';
					
					EXEC @v_estadoLiquidacion = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
					@i_code = N'BCK_EST_LIQUIDACION',
					@i_status = N'E';
				
					WHILE ((SELECT COUNT(*)  FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO H INNER JOIN BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO T
					ON H.HTP_ID = T.HTP_ID AND T.TPR_ESTADO = @v_id_estado_portAC AND H.HTP_ESTADO = @v_id_estado_portAC

					-- NIF
					AND H.HTP_CATEGORIA = T.TPR_CATEGORIA AND H.HTP_CATEGORIA = @v_categoria
					-- FIN NIF

					WHERE LIQ_ID = @i_liq_id) > 0)
					BEGIN
						UPDATE BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO
						SET TPR_ESTADO = @v_id_estado_port
						WHERE TPR_ESTADO = @v_id_estado_portAC
						AND CRE_ID=@v_reporto
					END
					
					UPDATE BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
					SET HTP_FECHA_OPERACION = @i_fecha, HTP_ESTADO = @v_id_estado_port	
					WHERE LIQ_ID = @i_liq_id AND HTP_ESTADO = @v_id_estado_portAC

					-- NIF
					AND HTP_CATEGORIA = @v_categoria
					-- FIN NIF
					
					--crea un nuevo registro en el valor efectivo del portafolio con el nuevo saldo por el reverso de la liquidacion		
					--se comenta por pedido de CC
					/*IF(@v_reporto IS NOT NULL  AND @v_reporto > 0 )
					BEGIN
					    SET @v_monId = ( SELECT  TOP 1 TV.TIV_MONEDA FROM BVQ_BACKOFFICE.TITULOS_PORTAFOLIO TP INNER JOIN BVQ_ADMINISTRACION.TITULO_VALOR TV 
										ON TP.TIV_ID = TV.TIV_ID WHERE  TP.POR_ID =@v_port) --AND TP.LIQ_ID = @i_liq_id  )

					    SET @v_valor_efectivo = (SELECT  TOP 1 VEP_VALOR_EFECTIVO FROM BVQ_BACKOFFICE.VALOR_EFECTIVO_PORTAFOLIO WHERE POR_ID = @v_port ORDER BY VEP_ID DESC)
					    SELECT @v_saldo_efectivo = ISNULL(LIQ_CANTIDAD, 0)	FROM BVQ_BACKOFFICE.LIQUIDACION WHERE LIQ_ID = @i_liq_id and LIQ_ESTADO = @v_estadoLiquidacion
					    -- si es una orden de reporto asociada a un portafolio
					
						--SELECT @v_saldo_efectivo = @v_don_cantidad
						
						IF(@v_valor_efectivo IS NULL)
							SET @v_valor_efectivo = 0
						IF(@v_saldo_efectivo IS NULL)
							SET @v_saldo_efectivo = 0

						INSERT BVQ_BACKOFFICE.VALOR_EFECTIVO_PORTAFOLIO
						(
							POR_ID, VEP_FECHA, MON_ID, VEP_VALOR_EFECTIVO
						)
						VALUES
						(
							@v_port, BVQ_ADMINISTRACION.ObtenerFechaSistema(), @v_monId, (@v_valor_efectivo + @v_saldo_efectivo)
						)
					END*/
					SET @o_resul = 1; 
					--Salen los títulos del portafolio valida en la compra para ejecutar el perfil
					
					SET @Error=@@ERROR
					IF (@Error<>0) GOTO TratarError		
								
				END	
			END		
			ELSE	
			BEGIN		
			
				--Ingresan títulos			
				EXEC @v_id_estadoPort = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
				@i_code = N'BCK_ES_TIT_POR',
				@i_status = N'A';
				
								
				/*insert INTO [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
				SELECT  @i_usr_id, DON.TIV_ID, @v_port,LIQ.LIQ_CANTIDAD, TIV.TIV_PRECIO_SPOT, BVQ_ADMINISTRACION.ObtenerFechaSistema(),
						BVQ_ADMINISTRACION.ObtenerFechaSistema(), @v_id_estadoPort, null, 0, 1, LIQ.LIQ_CANTIDAD,@i_liq_id
				FROM BVQ_BACKOFFICE.LIQUIDACION AS LIQ INNER JOIN
				BVQ_BACKOFFICE.DETALLE_LIQUIDACION AS DON ON LIQ.DLI_ID = DON.DLI_ID INNER JOIN
				BVQ_ADMINISTRACION.TITULO_VALOR AS TIV ON DON.TIV_ID = TIV.TIV_ID AND DON.TIV_ID = TIV.TIV_ID
				WHERE LIQ_ID = @i_liq_id;*/
				DECLARE Titulo CURSOR FOR
				
				/*SELECT TOP (1) @v_saldo = HTP_SALDO, @v_tivId = TIV_ID FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO WHERE POR_ID = @v_port AND LIQ_ID = @i_liq_id
				AND HTP_ESTADO  = @v_id_estadoPort  AND HTP_REPORTADO = @v_esReporto ORDER BY HTP_ID DESC*/


				SELECT   ISNULL(SUM(HTP_SALDO),0),   TIV_ID  FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO 
				WHERE TIV_ID IN (SELECT TIV_ID FROM BVQ_BACKOFFICE.DETALLE_LIQUIDACION WHERE DLI_ID = @v_dli_id) AND
				POR_ID = @v_port AND (LIQ_ID IS NULL OR LIQ_ID <> @i_liq_id) AND ISNULL(HTP_REPORTADO, 0) = @v_esReporto AND HTP_ESTADO = @v_id_estado_portAC 

				-- NIF
				AND HTP_CATEGORIA = @v_categoria
				-- FIN NIF

				GROUP BY TIV_ID

				OPEN Titulo
				FETCH NEXT FROM Titulo INTO @v_saldo, @v_tivId
				WHILE @@FETCH_STATUS  = 0
				BEGIN
					IF(@v_saldo IS NULL)
						SET @v_saldo = 0;

					UPDATE [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
					SET --[TPO_SALDO] = [TPO_SALDO] + @v_saldo,
					 [TPO_CANTIDAD] = [TPO_CANTIDAD] + @v_saldo
					WHERE [POR_ID] = @v_port
					AND [TPO_ESTADO] = @v_id_estado_portAC AND TIV_ID = @v_tivId

					-- NIF
					AND [TPO_CATEGORIA] = @v_categoria
					-- FIN NIF

					FETCH NEXT FROM Titulo INTO @v_saldo, @v_tivId
				END
				CLOSE Titulo
				DEALLOCATE Titulo

				EXEC @v_id_estado_port = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
					@i_code = N'BCK_ES_TIT_POR',
					@i_status = N'R';

				EXEC @v_estadoLiquidacion = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
					@i_code = N'BCK_EST_LIQUIDACION',
					@i_status = N'E';
				
				WHILE ((SELECT COUNT(*)  FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO H INNER JOIN BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO T
				ON H.HTP_ID = T.HTP_ID AND T.TPR_ESTADO = @v_id_estadoPort AND H.HTP_ESTADO = @v_id_estado_portAC

				-- NIF
				AND H.HTP_CATEGORIA = T.TPR_CATEGORIA AND H.HTP_CATEGORIA = @v_categoria
				-- FIN NIF

				WHERE LIQ_ID = @i_liq_id) > 0)
				BEGIN
					UPDATE BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO
					SET TPR_ESTADO = @v_id_estado_port
					WHERE TPR_ESTADO = @v_id_estado_portAC

					-- NIF
					AND	CRE_ID = @v_reporto
					-- FIN NIF

				END

				UPDATE BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
					SET HTP_FECHA_OPERACION = @i_fecha, HTP_ESTADO = @v_id_estado_port	
					WHERE LIQ_ID = @i_liq_id AND HTP_ESTADO = @v_id_estado_portAC	

					-- NIF
					AND HTP_CATEGORIA = @v_categoria
					-- FIN NIF

				--crea un nuevo registro en el valor efectivo del portafolio con el nuevo saldo por el reverso de la liquidacion		
				--se comenata por pedido de CC esta parte del valor efectivo
					
					/*IF(@v_reporto IS NOT NULL  AND @v_reporto > 0 )
					BEGIN 
						SET @v_monId = ( SELECT  TOP 1 TV.TIV_MONEDA FROM BVQ_BACKOFFICE.TITULOS_PORTAFOLIO TP INNER JOIN BVQ_ADMINISTRACION.TITULO_VALOR TV 
											ON TP.TIV_ID = TV.TIV_ID WHERE  TP.POR_ID =@v_port)-- AND TP.LIQ_ID = @i_liq_id  )

						SET @v_valor_efectivo = (SELECT  TOP 1 VEP_VALOR_EFECTIVO FROM BVQ_BACKOFFICE.VALOR_EFECTIVO_PORTAFOLIO WHERE POR_ID = @v_port ORDER BY VEP_ID DESC)
						SELECT @v_saldo_efectivo = ISNULL(LIQ_CANTIDAD, 0)	FROM BVQ_BACKOFFICE.LIQUIDACION WHERE LIQ_ID = @i_liq_id and LIQ_ESTADO = @v_estadoLiquidacion
					-- si es una orden de reporto asociada a un portafolio
					
						--SELECT @v_saldo_efectivo = @v_don_cantidad
						IF(@v_valor_efectivo IS NULL)
							SET @v_valor_efectivo = 0
						IF(@v_saldo_efectivo IS NULL)
							SET @v_saldo_efectivo = 0

						INSERT BVQ_BACKOFFICE.VALOR_EFECTIVO_PORTAFOLIO
						(
							POR_ID, VEP_FECHA, MON_ID, VEP_VALOR_EFECTIVO
						)VALUES
						(
							@v_port, BVQ_ADMINISTRACION.ObtenerFechaSistema(), @v_monId, (@v_valor_efectivo - @v_saldo_efectivo)
						)
					END*/

				--Inserta en la tabla hisorico titulo valor
				/*INSERT INTO BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
				(
					POR_ID,	TIV_ID,	HTP_FECHA_OPERACION, HTP_COMPRA, HTP_PRECIO_COMPRA, HTP_VENTA, HTP_PRECIO_VENTA, HTP_SALDO, LIQ_ID, HTP_ESTADO
				)
				SELECT  @v_port, DON.TIV_ID, BVQ_ADMINISTRACION.ObtenerFechaSistema(), LIQ.LIQ_CANTIDAD, TIV.TIV_PRECIO_SPOT, 0, 0, LIQ.LIQ_CANTIDAD, @i_liq_id, @v_id_estadoPort
				FROM BVQ_BACKOFFICE.LIQUIDACION AS LIQ INNER JOIN
				BVQ_BACKOFFICE.DETALLE_LIQUIDACION AS DON ON LIQ.DLI_ID = DON.DLI_ID INNER JOIN
				BVQ_ADMINISTRACION.TITULO_VALOR AS TIV ON DON.TIV_ID = TIV.TIV_ID AND DON.TIV_ID = TIV.TIV_ID
				WHERE LIQ_ID = @i_liq_id;*/

				SET @Error=@@ERROR
				IF (@Error<>0) GOTO TratarError

				SET @o_resul = 2;
			END
		END

		/****************************************************************************		
		Reversa las cuentas el comprobante de la liquidación					INICIO
		******************************************************************************/
		
		EXEC @o_com_id = [BVQ_BACKOFFICE].[ReversoComprobanteGestionNegocio]
		@i_com_id = @v_com_id, @i_lga_id = @i_lga_id;
		
		--PV 03-10-2018: el reverso debe quedar con la fecha ingresada por el usuario.
		IF EXISTS(SELECT LIQ_FECHA_VALOR FROM BVQ_BACKOFFICE.LIQUIDACION WHERE LIQ_ID = @i_liq_id)
		BEGIN
			EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
			@i_lga_id = @i_lga_id,
			@i_tabla = 'COMPROBANTE_GESTION_NEGOCIO',
			@i_esquema = N'BVQ_BACKOFFICE',
			@i_operacion = N'U',
			@i_subTipo = N'A',
			@i_columIdName = 'COM_ID',
			@i_idAfectado = @o_com_id;

			UPDATE BVQ_BACKOFFICE.COMPROBANTE_GESTION_NEGOCIO
			SET COM_FECHA_APLICACION = @i_fecha
			WHERE COM_ID = @o_com_id

			EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
			@i_lga_id = @i_lga_id,
			@i_tabla = 'COMPROBANTE_GESTION_NEGOCIO',
			@i_esquema = N'BVQ_BACKOFFICE',
			@i_operacion = N'U',
			@i_subTipo = N'N',
			@i_columIdName = 'COM_ID',
			@i_idAfectado = @o_com_id;
		END
		
		SET @Error=@@ERROR
		IF (@Error<>0) GOTO TratarError		
		
		/****************************************************************************		
		Reversa las cuentas el comprobante de la liquidación					FINAL
		******************************************************************************/
		
		
		/****************************************************************************		
		Reversa las cuentas por pagar y por cobrar					INICIO
		******************************************************************************/			
--------------------		
--------------------		UPDATE [BVQ_BACKOFFICE].DETALLE_CUENTAS_POR_COBRAR SET DCC_ESTADO = @v_est_rev_det_cxc WHERE LIQ_ID = @i_liq_id;
--------------------		
--------------------		SET @Error=@@ERROR
--------------------		IF (@Error<>0) GOTO TratarError		
--------------------		
--------------------		UPDATE [BVQ_BACKOFFICE].DETALLE_CUENTAS_POR_PAGAR SET DCP_ESTADO = @v_est_rev_det_cxp  WHERE LIQ_ID = @i_liq_id;		
--------------------		
--------------------		SET @Error=@@ERROR
--------------------		IF (@Error<>0) GOTO TratarError		
--------------------		
--------------------		UPDATE [BVQ_BACKOFFICE].CUENTA_POR_COBRAR SET CXC_ESTADO = @v_est_rev_cxc WHERE (CXC_ID_ORDER = @v_orn_id OR POR_ID = @v_port) AND CXC_ID NOT IN
--------------------		(SELECT CXC_ID FROM BVQ_BACKOFFICE.DETALLE_CUENTAS_POR_COBRAR WHERE DCC_ESTADO<>@v_est_rev_det_cxc GROUP BY CXC_ID)
--------------------		
--------------------		SET @Error=@@ERROR
--------------------		IF (@Error<>0) GOTO TratarError		
--------------------		
--------------------		UPDATE [BVQ_BACKOFFICE].CUENTA_POR_PAGAR SET CXP_ESTADO = @v_est_rev_cxp WHERE (CXP_ID_ORDER = @v_orn_id OR POR_ID = @v_port) AND CXP_ID NOT IN
--------------------		(SELECT CXP_ID FROM BVQ_BACKOFFICE.DETALLE_CUENTAS_POR_pagar WHERE DCP_ESTADO<>@v_est_rev_det_cxp GROUP BY CXP_ID)
--------------------		
--------------------		SET @Error=@@ERROR
--------------------		IF (@Error<>0) GOTO TratarError						                 			
				
		/****************************************************************************		
		Reversa las cuentas por pagar y por cobrar					FINAL
		******************************************************************************/	
		
		/****************************************************************************		
		Actualiza estado de la liquidación y del título					INCIO
		******************************************************************************/	
		
		EXEC @v_id_estado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
		@i_code = N'BCK_EST_LIQUIDACION',
		@i_status = N'E';

			EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
			@i_lga_id = @i_lga_id,
			@i_tabla = 'LIQUIDACION',
			@i_esquema = N'BVQ_BACKOFFICE',
			@i_operacion = N'U',
			@i_subTipo = N'A',
			@i_columIdName = 'LIQ_ID',
			@i_idAfectado = @i_liq_id;

		UPDATE [BVQ_BACKOFFICE].LIQUIDACION
		SET LIQ_ESTADO = @v_id_estado
		WHERE LIQ_ID = @i_liq_id;	
		
		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
			@i_lga_id = @i_lga_id,
			@i_tabla = 'LIQUIDACION',
			@i_esquema = N'BVQ_BACKOFFICE',
			@i_operacion = N'U',
			@i_subTipo = N'N',
			@i_columIdName = 'LIQ_ID',
			@i_idAfectado = @i_liq_id;
		SET @Error=@@ERROR
		IF (@Error<>0) GOTO TratarError		
		
		
		EXEC @v_id_estado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
		@i_code = N'BCK_EST_TIT_ORDEN',
		@i_status = N'E';
		
		SET @Error=@@ERROR
		IF (@Error<>0) GOTO TratarError		
						
	EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
	@i_lga_id = @i_lga_id,
	@i_tabla = 'DETALLE_LIQUIDACION',
	@i_esquema = N'BVQ_BACKOFFICE',
	@i_operacion = N'U',
	@i_subTipo = N'A',
	@i_columIdName = 'DLI_ID',
	@i_idAfectado = @v_dli_id;

		UPDATE [BVQ_BACKOFFICE].DETALLE_LIQUIDACION SET DLI_ESTADO = @v_id_estado WHERE DLI_ID = @v_dli_id;
		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]		
	@i_lga_id = @i_lga_id,
	@i_tabla = 'DETALLE_LIQUIDACION',
	@i_esquema = N'BVQ_BACKOFFICE',
	@i_operacion = N'U',
	@i_subTipo = N'N',
	@i_columIdName = 'DLI_ID',
	@i_idAfectado = @v_dli_id;
	
		SET @Error=@@ERROR
		IF (@Error<>0) GOTO TratarError				
			

			EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
	@i_lga_id = @i_lga_id,
	@i_tabla = 'ORDEN_NEGOCIACION',
	@i_esquema = N'BVQ_BACKOFFICE',
	@i_operacion = N'U',
	@i_subTipo = N'A',
	@i_columIdName = 'ORN_ID',
	@i_idAfectado = @v_orn_id;
	
	
			EXEC @v_id_estado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
	@i_code = N'BCK_EST_TIT_ORDEN',
	@i_status = N'L';

	IF(NOT EXISTS(SELECT 1 FROM [BVQ_BACKOFFICE].DETALLE_LIQUIDACION WHERE DLI_ESTADO = @v_id_estado AND ORN_ID = @v_orn_id))
	begin	set @tmp_status=N'V'	end
	ELSE	
	begin	set @tmp_status=N'PE'	end
	EXEC @v_est_orn = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo @i_code = N'EST_ORDEN',@i_status=@tmp_status;
	
		UPDATE [BVQ_BACKOFFICE].ORDEN_NEGOCIACION SET ORN_ESTADO=@v_est_orn WHERE ORN_ID = @v_orn_id
		/****************************************************************************		
		Actualiza estado de la liquidación y del título					FINAL
		******************************************************************************/	
		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
	@i_lga_id = @i_lga_id,
	@i_tabla = 'ORDEN_NEGOCIACION',
	@i_esquema = N'BVQ_BACKOFFICE',
	@i_operacion = N'N',
	@i_subTipo = N'N',
	@i_columIdName = 'ORN_ID',
	@i_idAfectado = @v_orn_id;		
		
		SET @Error=@@ERROR
		IF (@Error<>0) GOTO TratarError		
		

	--DELETE FROM LIQUIDACION_SUBTITULO WHERE LIQ_ID = @i_liq_id;
	IF(@v_subTipoOrden='C')
	BEGIN
		DELETE FROM [BVQ_BACKOFFICE].[SUBTITULO_PORTAFOLIO] WHERE LIQ_ID = @i_liq_id;
	END
	ELSE
	BEGIN
		UPDATE [BVQ_BACKOFFICE].[SUBTITULO_PORTAFOLIO] SET PSU_ESTADO = 'A' WHERE LIQ_ID = @i_liq_id
	END
	
	UPDATE BVQ_BACKOFFICE.LIQUIDACION SET LIQ_ESTADO_LIQ = 0 WHERE LIQ_ID = @i_liq_id

	SET @Error=@@ERROR
		IF (@Error<>0) GOTO TratarError		

	SET @o_resul = 0;	

		/*COMMIT TRAN;*/
		
	TratarError:
	If @@Error<>0

	BEGIN
		RAISERROR('Error en el reverso de la liquidación', 10, 1)
	END
   
END 

