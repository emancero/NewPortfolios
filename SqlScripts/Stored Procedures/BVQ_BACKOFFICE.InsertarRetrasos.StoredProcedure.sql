-- =============================================
-- Author:		Edwin Calderón
-- Create date: 27/10/2016
-- Description:	Inserta un retraso de portafolio
-- Parametros:  
-- History:		PV 04-01-2018:	se agrega tpo_id, campo requerido de tabla retraso.
-- =============================================
CREATE PROCEDURE [BVQ_BACKOFFICE].[InsertarRetrasos]
	@i_tpoId int
	,@i_fecha_esperada datetime	
	,@i_fecha_cobro datetime	
	,@i_lga_id int		
AS
BEGIN
INSERT INTO [BVQ_BACKOFFICE].[retraso]
           ([retr_tpo_id]
           ,[retr_fecha_esperada]
           ,[retr_fecha_cobro])
     VALUES
           (@i_tpoId
           ,@i_fecha_esperada
           ,@i_fecha_cobro)

	EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
	@i_lga_id = @i_lga_id,
	@i_tabla = 'retraso',
	@i_esquema = N'BVQ_BACKOFFICE',
	@i_operacion = N'I',
	@i_subTipo = N'N',
	@i_columIdName = 'retr_tpo_id',
	@i_idAfectado = @@IDENTITY;

END
