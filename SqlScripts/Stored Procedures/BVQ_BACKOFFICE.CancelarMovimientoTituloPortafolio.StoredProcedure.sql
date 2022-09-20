-- ==========================================================================================
-- Author:		Patricio Villacis G
-- Create date: 08-02-2018
-- Description:	Cancela el movimiento de un título portafolio
-- Parametros:  
-- Cambios:		
-- ==========================================================================================


CREATE PROCEDURE [BVQ_BACKOFFICE].[CancelarMovimientoTituloPortafolio]
	 @i_htp_id int
	,@i_lga_id int		
AS
BEGIN

	SET NOCOUNT ON;	

	DECLARE @v_id_estado int;
	
	EXEC @v_id_estado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
	@i_code = N'BCK_ES_TIT_POR',
	@i_status = N'E';

	EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = N'HISTORICO_TITULOS_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'U',
		@i_subTipo = N'A',
		@i_columIdName = N'HTP_ID',
		@i_idAfectado = @i_htp_id;
		
	UPDATE BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
	SET --HTP_FECHA_OPERACION = BVQ_ADMINISTRACION.ObtenerFechaSistema(),
		HTP_ESTADO = @v_id_estado
	WHERE HTP_ID = @i_htp_id

    EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = N'HISTORICO_TITULOS_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'U',
		@i_subTipo = N'N',
		@i_columIdName = N'HTP_ID',
		@i_idAfectado = @i_htp_id;
END
go
