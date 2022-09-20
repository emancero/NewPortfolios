-- =====================================================================================================================================
-- Author:  Jimmy Chuico   
-- Create date: 14/Ene/2010
-- Description: Administra la venta de titulos en portafolio, asi como las garantias que se ingresen a este porataolio   
-- Cambios:		GCA: 15-abril-2010: Se agrega la variable categoría para NIF
--				PSA: 29/06/2014 Cambio portafolios
-- ====================================================================================================================================

CREATE PROCEDURE [BVQ_BACKOFFICE].[ActualizarEstadoCuentaPortafolioVenta]
(
	@i_usr_id		int
	,@v_port_id		INT
	,@i_liq_id		INT
	,@v_tit_id		INT
	,@saldoTit		DECIMAL(38, 4)
	,@v_cantidad    DECIMAL(38, 4)
	,@v_precio      DECIMAL(38, 4)
	,@v_cupon		BIT	
	,@v_reporto		INT
	,@i_lga_id		int
)
AS
BEGIN

	DECLARE @v_categoria int;
	DECLARE @v_id_estado int, @v_reportado INT, @v_reportante INT, @v_engarantia INT, @v_htp_id int,  @v_estado_port_rev int;
	DECLARE @v_id_estado_port int, @v_cantidadGarantia DECIMAL(38, 4), @v_tivGarantia INT, @v_precioGarantia DECIMAL(38, 4);
	DECLARE @v_monId int, @v_valor_efectivo float, @v_saldo_efectivo float, @v_id_estado_gar_act int, @v_tit_id1 int; 
	DECLARE  @v_cuponGar bit , @v_rentaFija INT, @v_tipoRenta int;

	EXEC @v_id_estado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo    
		@i_code = N'BCK_ES_TIT_POR',    
		@i_status = N'A'; 

	 EXEC @v_estado_port_rev = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo    
	 @i_code = N'BCK_ES_TIT_POR',    
	 @i_status = N'R';

	 SET @v_tit_id1 =@v_tit_id;

	SELECT @v_categoria = LIQ_CATEGORIA FROM BVQ_BACKOFFICE.LIQUIDACION WHERE LIQ_ID = @i_liq_id;

	 SELECT @v_precio = CRE_PRECIO_SPOT  FROM BVQ_BACKOFFICE.CONTRATO_REPORTO WHERE CRE_ID = @v_reporto
	   
	 SET @v_reportado =  (SELECT IT.ITC_ID FROM BVQ_ADMINISTRACION.ITEM_CATALOGO IT INNER JOIN BVQ_ADMINISTRACION.CATALOGO CAT
					ON IT.CAT_ID = CAT.CAT_ID AND CAT_CODIGO = 'BCK_EST_POR_REP' AND IT.ITC_CODIGO = 'REPORTADO')

	 SET @v_reportante = (SELECT IT.ITC_ID FROM BVQ_ADMINISTRACION.ITEM_CATALOGO IT INNER JOIN BVQ_ADMINISTRACION.CATALOGO CAT
					ON IT.CAT_ID = CAT.CAT_ID AND CAT_CODIGO = 'BCK_EST_POR_REP' AND IT.ITC_CODIGO = 'REPORTANTE')

	 SET @v_engarantia = (SELECT IT.ITC_ID FROM BVQ_ADMINISTRACION.ITEM_CATALOGO IT INNER JOIN BVQ_ADMINISTRACION.CATALOGO CAT
					ON IT.CAT_ID = CAT.CAT_ID AND CAT_CODIGO = 'BCK_EST_POR_REP' AND IT.ITC_CODIGO = 'GARANTIA')  	

   IF EXISTS (SELECT TOP(1) TPO_ID FROM BVQ_BACKOFFICE.TITULOS_PORTAFOLIO
			  WHERE POR_ID = @v_port_id and TIV_ID = @v_tit_id AND TPO_COBRO_CUPON = @v_cupon

		-- NIF
		AND TPO_CATEGORIA = @v_categoria
		-- FIN NIF

		)
   begin

		UPDATE [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
		SET 
		[TPO_CANTIDAD] = @saldoTit
		WHERE [POR_ID] = @v_port_id
		AND [TIV_ID] = @v_tit_id
		AND [TPO_COBRO_CUPON] = @v_cupon
		AND [TPO_ESTADO] = @v_id_estado

		-- NIF
		AND [TPO_CATEGORIA] = @v_categoria
		-- FIN NIF

   end
   else
   begin		
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
	   ,[LIQ_ID]

		-- NIF
		,[TPO_CATEGORIA]
		-- FIN NIF

		)
		VALUES
	   (
		@i_usr_id
	   ,@v_tit_id   
	   ,@v_port_id   
	   ,@v_cantidad
	   ,@v_precio
	   ,BVQ_ADMINISTRACION.ObtenerFechaSistema()
	   ,BVQ_ADMINISTRACION.ObtenerFechaSistema()
	   ,@v_id_estado
	   ,null
	   ,@v_cupon
	   ,1	   
	   ,@i_liq_id

		-- NIF
		,@v_categoria
		-- FIN NIF
		
		)
	   
		EXEC [BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = 'TITULOS_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'I',
		@i_subTipo = N'N',
		@i_columIdName = 'TPO_ID',
		@i_idAfectado = @@IDENTITY;
	  
	END
  
	-- Inserta el  registro por la	diferencia en saldo  entre la diferencia del registro actual y el saldo que viene por reporto
	IF(EXISTS (select 1  FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HPOR WHERE HPOR.POR_ID = @v_port_id  and ISNULL( HPOR.HTP_REPORTADO , 0)= 0 
				AND HTP_CUPON = @v_cupon AND  HTP_ESTADO = @v_id_estado AND TIV_ID =  @v_tit_id 

				-- NIF
				AND HTP_CATEGORIA = @v_categoria
				-- FIN NIF

				))
	BEGIN
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
			, HTP_CATEGORIA
			-- FIN NIF

		)    
		
		SELECT 	POR_ID, TIV_ID ,BVQ_ADMINISTRACION.ObtenerFechaSistema(), 0,0, @v_cantidad , @v_precio,
				HTP_SALDO - @v_cantidad, @i_liq_id,  HTP_ESTADO, HTP_CUPON, 0 

				-- NIF
				,HTP_CATEGORIA
				-- FIN NIF

		FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
		WHERE HTP_ID = (SELECT  MAX(HTP_ID) FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HPOR WHERE HPOR.POR_ID = @v_port_id  and ISNULL( HPOR.HTP_REPORTADO , 0)= 0 
					AND HTP_CUPON = @v_cupon AND  HTP_ESTADO = @v_id_estado AND TIV_ID =  @v_tit_id 

					-- NIF
					AND HTP_CATEGORIA = @v_categoria
					-- FIN NIF

					)

		
		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = 'HISTORICO_TITULOS_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'I',
		@i_subTipo = N'N',
		@i_columIdName = 'HTP_ID',
		@i_idAfectado = @@IDENTITY;
	
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
			    
		)    
		VALUES
		(
			@v_port_id, @v_tit_id ,BVQ_ADMINISTRACION.ObtenerFechaSistema() , 0, 0, @v_cantidad ,@v_precio,
			@v_cantidad, @i_liq_id,  @v_id_estado, @v_cupon, 1
			
			-- NIF
			, @v_categoria
			-- FIN NIF
			
		)

		SET @v_htp_id = @@IDENTITY;
		
		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = 'HISTORICO_TITULOS_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'I',
		@i_subTipo = N'N',
		@i_columIdName = 'HTP_ID',
		@i_idAfectado = @v_htp_id;
		
		
		INSERT INTO BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO
		(
			HTP_ID, TPR_TIPO_REPORTO, TPR_SALDO, TPR_FECHA, TPR_ESTADO, CRE_ID

			-- NIF
			, TPR_CATEGORIA
			-- FIN NIF
			
		)
		VALUES 
		(
			@v_htp_id ,@v_reportado, @v_cantidad ,BVQ_ADMINISTRACION.ObtenerFechaSistema(),  @v_id_estado, @v_reporto 
			, @v_categoria
		)
		
		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = 'TITULOS_PORTAFOLIO_REPORTO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'I',
		@i_subTipo = N'N',
		@i_columIdName = 'TPR_ID',
		@i_idAfectado = @@IDENTITY;

		
	END	
	ELSE
	BEGIN

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
			, HTP_CATEGORIA
			-- FIN NIF
			
		)    
		VALUES(
		@v_port_id, @v_tit_id ,BVQ_ADMINISTRACION.ObtenerFechaSistema() , 0, 0, @v_cantidad ,@v_precio,
		@v_cantidad, @i_liq_id,  @v_id_estado, @v_cupon, 1
		
		-- NIF
		,@v_categoria
		-- FIN NIF
		
		)

		SET @v_htp_id = @@IDENTITY;
		
		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = 'HISTORICO_TITULOS_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'I',
		@i_subTipo = N'N',
		@i_columIdName = 'HTP_ID',
		@i_idAfectado = @v_htp_id;
				
		INSERT INTO BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO
		(
			HTP_ID, TPR_TIPO_REPORTO, TPR_SALDO, TPR_FECHA, TPR_ESTADO, CRE_ID

			-- NIF
			, TPR_CATEGORIA
			-- FIN NIF
			
		)
		VALUES
		(
			@v_htp_id ,@v_reportado, @v_cantidad ,BVQ_ADMINISTRACION.ObtenerFechaSistema(),  @v_id_estado, @v_reporto 
			
			-- NIF
			,@v_categoria
			-- FIN NIF
			
		)
		
		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = 'TITULOS_PORTAFOLIO_REPORTO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'I',
		@i_subTipo = N'N',
		@i_columIdName = 'TPR_ID',
		@i_idAfectado = @@IDENTITY;
	
	END
	--Inserta el nuevo registro con los valores que posee, y como datos de materia de reporto
	--Verifica si al garantia basica del reporto es un titulo

	EXEC @v_id_estado_gar_act = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo    
						@i_code = N'BCK_GAR_TITULO',    
						@i_status = N'A';

	EXEC @v_rentaFija = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo    
	   @i_code = N'TIPO_RENTA',    
	   @i_status = N'REN_FIJA';	

	DECLARE Titulo Cursor for
	select distinct tiv_id from BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
	WHERE POR_ID = @v_port_id AND HTP_ESTADO = @v_id_estado
	OPEN Titulo
	FETCH NEXT FROM Titulo INTO @v_tit_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @v_tipoRenta = TIV_TIPO_RENTA FROM BVQ_ADMINISTRACION.TITULO_VALOR WHERE TIV_ID = @v_tit_id
		IF(@v_rentaFija = @v_tipoRenta )
			SET @v_cuponGar = 1
		ELSE
			SET @v_cuponGar = 0			

		IF(EXISTS( SELECT 1 FROM BVQ_BACKOFFICE.GARANTIA_VALOR WHERE ORG_ID = @v_reporto and TIV_ID = @v_tit_id ))
		BEGIN
			-- UN TITULO PUEDE TENER MAS DE UN REGISTRO EN GARANTIA VALOR DEBIDO A DIFERENCIA DE PRECIOS VECTOR DEL MISMO
			DECLARE GARANTIA CURSOR FOR
			--SELECT @v_cantidadGarantia = GVA_CANTIDAD , @v_tivGarantia = TIV_ID, @v_precioGarantia = GVA_PRECIO FROM BVQ_BACKOFFICE.GARANTIA_VALOR 
			SELECT GVA_CANTIDAD , TIV_ID,  GVA_PRECIO FROM BVQ_BACKOFFICE.GARANTIA_VALOR 
			WHERE ORG_ID = @v_reporto AND TIV_ID = @v_tit_id and GVA_ESTADO = @v_id_estado_gar_act and GVA_CATEGORIA = @v_categoria
			OPEN GARANTIA
			FETCH NEXT FROM GARANTIA INTO @v_cantidadGarantia, @v_tivGarantia, @v_precioGarantia
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
				IF(@v_cantidadGarantia IS  NULL)
					SET @v_cantidadGarantia = 0

				-- el 0 en cupón es porque el titulo garantía se genera por defecto con no aplica cupón
				SET @saldoTit = ( SELECT TOP(1) ISNULL(HTP_SALDO,0)
								FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
								WHERE POR_ID = @v_port_id and  TIV_ID = @v_tit_id AND HTP_CUPON = @v_cuponGar  AND HTP_ESTADO = @v_id_estado AND ISNULL(HTP_REPORTADO, 0) = 0

								-- NIF
								AND HTP_CATEGORIA = @v_categoria
								-- FIN NIF

								order by HTP_ID  desc)

				IF(@saldoTit  IS NULL)
					SET @saldoTit = 0
		
				 SET @saldoTit = abs(@saldoTit - @v_cantidadGarantia);

				if exists (SELECT TOP(1) TPO_ID FROM BVQ_BACKOFFICE.TITULOS_PORTAFOLIO
					WHERE POR_ID = @v_port_id and TIV_ID = @v_tit_id AND TPO_COBRO_CUPON = @v_cuponGar

					-- NIF
					AND TPO_CATEGORIA = @v_categoria
					-- FIN NIF

					)
				begin		
					
					UPDATE [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
					SET 
					[TPO_CANTIDAD] = @saldoTit
					WHERE [POR_ID] = @v_port_id
					AND [TIV_ID] = @v_tit_id
					AND [TPO_COBRO_CUPON] = @v_cuponGar
					AND [TPO_ESTADO] = @v_id_estado

					-- NIF
					AND [TPO_CATEGORIA] = @v_categoria
					-- FIN NIF

				end
				else
				begin

					INSERT INTO [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]    
					(
						[USR_ID] ,[TIV_ID] ,[POR_ID] ,[TPO_CANTIDAD] ,[TPO_PRECIO_INGRESO] ,[TPO_FECHA_INGRESO]    
						,[TPO_FECHA_REGISTRO] ,[TPO_ESTADO] ,[TPO_ULTIMA_REVALUACION] ,[TPO_COBRO_CUPON]    
						,[TPO_CONFIRMA_TITULO]  ,[LIQ_ID]

						-- NIF
						, TPO_CATEGORIA
						-- FIN NIF

					)
					VALUES
					(
						@i_usr_id, @v_tit_id, @v_port_id, @v_cantidadGarantia, @v_precioGarantia, BVQ_ADMINISTRACION.ObtenerFechaSistema() 
						,BVQ_ADMINISTRACION.ObtenerFechaSistema(), @v_id_estado, NULL, @v_cuponGar, 1 , @i_liq_id

						-- NIF
						,@v_categoria
						-- FIN NIF

					)
				   
				   EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
					@i_lga_id = @i_lga_id,
					@i_tabla = 'TITULOS_PORTAFOLIO',
					@i_esquema = N'BVQ_BACKOFFICE',
					@i_operacion = N'I',
					@i_subTipo = N'N',
					@i_columIdName = 'TPO_ID',
					@i_idAfectado = @@IDENTITY;
				  
			   end
				
				-- Inserta el  registro por la	cantida que se ingresa en el titulo de garantia
				--Verifica qeu el titulo de garantia exista en  el historico de titulos portafolio
				IF ( exists (select 1 from BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HPOR where POR_ID = @v_port_id  and ISNULL( HTP_REPORTADO , 0)= 0 
							AND HTP_CUPON = @v_cuponGar AND  HTP_ESTADO = @v_id_estado AND TIV_ID =  @v_tivGarantia 

							-- NIF
							AND HTP_CATEGORIA = @v_categoria
							-- FIN NIF
							
					))

				BEGIN
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
						, HTP_CATEGORIA
						-- FIN NIF	    
						
					)    
					
					SELECT 	@v_port_id, @v_tivGarantia ,BVQ_ADMINISTRACION.ObtenerFechaSistema() ,0, 0, @v_cantidadGarantia ,@v_precioGarantia,
							 @v_cantidadGarantia, @i_liq_id,  HTP_ESTADO, @v_cuponGar, 1 

							-- NIF
							,@v_categoria
							-- FIN NIF

					FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO	
					WHERE HTP_ID = (SELECT  MAX(HTP_ID) FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HPOR 
									WHERE HPOR.POR_ID = @v_port_id  and ISNULL( HPOR.HTP_REPORTADO , 0)= 0 
									AND HTP_CUPON = @v_cuponGar AND  HTP_ESTADO = @v_id_estado AND TIV_ID =  @v_tivGarantia 

									-- NIF
									AND HTP_CATEGORIA = @v_categoria
									-- FIN NIF

									)

					--Inserta el titulo como garantía

					SET @v_htp_id = @@IDENTITY;

					EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
					@i_lga_id = @i_lga_id,
					@i_tabla = 'HISTORICO_TITULOS_PORTAFOLIO',
					@i_esquema = N'BVQ_BACKOFFICE',
					@i_operacion = N'I',
					@i_subTipo = N'N',
					@i_columIdName = 'HTP_ID',
					@i_idAfectado = @v_htp_id;
					
					INSERT INTO BVQ_BACKOFFICE.TITULOS_PORTAFOLIO_REPORTO
					(
						HTP_ID, TPR_TIPO_REPORTO, TPR_SALDO, TPR_FECHA, TPR_ESTADO, CRE_ID

						-- NIF
						, TPR_CATEGORIA
						-- FIN NIF

					)
					VALUES
					(
						@v_htp_id ,@v_engarantia, @v_cantidadGarantia ,BVQ_ADMINISTRACION.ObtenerFechaSistema(),  @v_id_estado , @v_reporto

						-- NIF
						, @v_categoria
						-- FIN NIF
						
					)
					
					EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
					@i_lga_id = @i_lga_id,
					@i_tabla = 'TITULOS_PORTAFOLIO_REPORTO',
					@i_esquema = N'BVQ_BACKOFFICE',
					@i_operacion = N'I',
					@i_subTipo = N'N',
					@i_columIdName = 'TPR_ID',
					@i_idAfectado = @@IDENTITY;

					--inserta otro registro restando a la cantidad actual del titulo la cantidad de la garantia
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
						
					)
				
					
					SELECT 	@v_port_id, @v_tivGarantia ,BVQ_ADMINISTRACION.ObtenerFechaSistema() , 0, 0, @v_cantidadGarantia ,@v_precioGarantia,
							 HTP_SALDO - @v_cantidadGarantia, @i_liq_id,  HTP_ESTADO, @v_cuponGar, 0 

							-- NIF
							, @v_categoria
							-- FIN NIF

					FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO	
					WHERE HTP_ID = (SELECT  MAX(HTP_ID) FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HPOR WHERE HPOR.POR_ID = @v_port_id  and ISNULL( HPOR.HTP_REPORTADO , 0)= 0 
								AND HTP_CUPON = @v_cuponGar AND  HTP_ESTADO = @v_id_estado AND TIV_ID =  @v_tivGarantia 

								-- NIF
								AND HTP_CATEGORIA = @v_categoria
								-- FIN NIF
								
								)
						
					EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
					@i_lga_id = @i_lga_id,
					@i_tabla = 'HISTORICO_TITULOS_PORTAFOLIO',
					@i_esquema = N'BVQ_BACKOFFICE',
					@i_operacion = N'I',
					@i_subTipo = N'N',
					@i_columIdName = 'HTP_ID',
					@i_idAfectado = @@IDENTITY;
					
				END

				FETCH NEXT FROM GARANTIA
			END
			
			CLOSE GARANTIA
			DEALLOCATE GARANTIA
		 END
		 FETCH NEXT FROM Titulo INTO @v_tit_id
	 END
	CLOSE Titulo
	DEALLOCATE Titulo

END
