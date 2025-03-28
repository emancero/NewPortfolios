-- =============================================
-- Author:		  Edwin Calderón
-- Create date:   18/09/2023
-- Description:	Habilita la edición de un ingreso
--				
-- =============================================
CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerActivosInmobiliariosISSPOL]
		@i_fecha_corte date, @i_lga_id INT
AS
BEGIN
	SELECT * FROM BVQ_BACKOFFICE.tfObtenerActivosInmobiliariosISSPOL(@i_fecha_corte)
END
