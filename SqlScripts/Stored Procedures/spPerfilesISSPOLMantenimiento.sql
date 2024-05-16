
-- =============================================
-- Author:		<Author,Galo Nivelo>
-- Create date: <11/12/2023>
-- Description:	<Sp Consulta para mantenimiento de tabla bvq_backoffice.spPerfilesISSPOLMantenimiento>
-- Parametros: @tipo_transaccion==> 1=consulta, 2=Update, 3=Insert (Nuevo), 4=Eliminar
-- =============================================

CREATE PROCEDURE [BVQ_BACKOFFICE].[spPerfilesISSPOLMantenimiento]
(
	@tipo_transaccion	int,
	@idPerfiles 		Int null,
	@tipPap 			nvarchar(255) NULL,
	@pPorId 			int NULL,
	@prefijo 			varchar(20) NULL,
	@cxc 				int NULL,
	@acreedora 			nvarchar(max) NULL,
	@acreedoraSinAux 	nvarchar(max) NULL,
	@acreedoraAux 		nvarchar(max) NULL,
	@nomAcreedora 		varchar(200) NULL,
	@deudora 			varchar(50) NULL,
	@deudoraSinAux 		varchar(50) NULL,
	@deudoraAux 		varchar(3) NULL,
	@nomDeudora 		varchar(200) NULL,
	@i_lga_id			int,
	@AS_MSJ NVARCHAR(300) out
)
AS


BEGIN

	BEGIN TRY	
		--declare @tipo_transaccion int
		---set @tipo_transaccion =5
		SET @tipo_transaccion = ISNULL(@tipo_transaccion,0)  
	
		---select @tipo_transaccion


		if (@tipo_transaccion=1)    --- Consulta de transacciones
			BEGIN
				set @AS_MSJ = 'Consulta generada exitosamente ';
			END
		ELSE IF (@tipo_transaccion = 2 AND ISNULL( @idPerfiles,0 ) > 0 )  --- Actualización de transacciones
		BEGIN		
			 UPDATE BVQ_BACKOFFICE.PERFILES_isspol
			 SET	tipPap		= @tipPap			
					,p_por_id 	= @pPorId		
					,prefijo	= @prefijo 			
					,cxc		= @cxc				
					,acreedora 	= @acreedora		
					,acreedoraSinAux 	= @acreedoraSinAux
					,acreedoraAux	= @acreedoraAux		
					,nomAcreedora	= @nomAcreedora		
					,deudora		= @deudora 			
					,deudoraSinAux 	= @deudoraSinAux
					,deudoraAux		= @deudoraAux			
					,nomDeudora		= @nomDeudora		
			 WHERE idPerfiles = @idPerfiles

			 SET @AS_MSJ = 'Actualización procesada exitosamente ';
		 
		 
		END
		ELSE IF (@tipo_transaccion=3 AND ISNULL( @idPerfiles,0 )=0)  --- INSERT nuevo registro
		BEGIN
			INSERT INTO [BVQ_BACKOFFICE].[PERFILES_ISSPOL]
					   ([tipPap]
					   ,[p_por_id]
					   ,[prefijo]
					   ,[cxc]
					   ,[acreedora]
					   ,[acreedoraSinAux]
					   ,[acreedoraAux]
					   ,[nomAcreedora]
					   ,[deudora]
					   ,[deudoraSinAux]
					   ,[deudoraAux]
					   ,[nomDeudora]
					   )
				 VALUES
					   (
						@tipPap 			
						,@pPorId 			
						,@prefijo 			
						,@cxc 				
						,@acreedora 			
						,@acreedoraSinAux 	
						,@acreedoraAux 		
						,@nomAcreedora 		
						,@deudora 			
						,@deudoraSinAux 		
						,@deudoraAux 		
						,@nomDeudora 		
						)




			set @AS_MSJ = 'Creación de nuevo registro procesado exitosamente ';

		END
		ELSE IF (@tipo_transaccion=4 AND ISNULL( @idPerfiles,0 )>0)  --- borrado de transacciones
		BEGIN		
			 DELETE FROM BVQ_BACKOFFICE.PERFILES_isspol
			 WHERE idPerfiles = @idPerfiles

			 SET @AS_MSJ = 'Eliminación de registro procesado exitosamente ';
			 
		END
		ELSE
			BEGIN
				SET @AS_MSJ = 'No se ha ejecutado ninguna transacción '
			END

		SELECT
			idPerfiles		
			,tipPap 				
			,p_por_id 			
			,prefijo 			
			,cxc 				
			,acreedora 			
			,acreedoraSinAux 	
			,acreedoraAux 		
			,nomAcreedora 		
			,deudora 			
			,deudoraSinAux 		
			,deudoraAux 			
			,nomDeudora
			,POR_CODIGO
		FROM bvq_backoffice.PERFILES_isspol
		JOIN bvq_backoffice.PORTAFOLIO por on p_por_id=por.por_id



	END TRY
	begin catch
			set @AS_MSJ = ERROR_MESSAGE();
	end catch

END
