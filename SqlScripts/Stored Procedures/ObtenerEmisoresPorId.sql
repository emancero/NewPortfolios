-- =============================================
-- Author:		Jimmy Chuico
-- Create date: 04/Set/2009
-- Description:	Consulta todos de titulos valor activos
-- =============================================
CREATE PROCEDURE [BVQ_ADMINISTRACION].[ObtenerEmisoresPorId]
	@i_id					int,
	@i_lga_id				int
AS
BEGIN
	DECLARE @v_estado int, @v_parEsIsspol VARCHAR(3)
	
	SELECT @v_parEsIsspol = p.PAR_VALOR FROM BVQ_ADMINISTRACION.PARAMETRO p WHERE p.PAR_CODIGO = 'PAR_ISSPOL'
	
	/*EXEC @v_estado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
		@i_code = N'GENSTATUS',
		@i_status = N'A';*/
				
		SELECT E.*
		, IC.ITC_NOMBRE
		,case when EMS_ID>=BVQ_CENTRALIZED_SERVICE.ObtenerConstanteSecuencialCasas() AND @v_parEsIsspol <> 'SI' then 0 else 1 end ES_EDITABLE
		FROM BVQ_ADMINISTRACION.EMISOR E INNER JOIN BVQ_ADMINISTRACION.ITEM_CATALOGO IC
		ON E.EMS_ESTADO =  IC.ITC_ID
		WHERE EMS_ID = @i_id

END