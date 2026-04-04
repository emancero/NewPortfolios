CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerActivosInmobiliariosISSPOL]
		@i_fecha_corte date, @i_lga_id INT
AS
BEGIN
	SELECT * FROM BVQ_BACKOFFICE.tfObtenerActivosInmobiliariosISSPOL(@i_fecha_corte)
END