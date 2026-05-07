CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerCreditosCarteraISSPOL]
		@i_fechaCorte	DATETIME,
		@i_lga_id	INT
AS
	BEGIN
		select * from BVQ_BACKOFFICE.CREDITOS_CARTERA 
		where CRC_FECHA_CIERRE = @i_fechaCorte
	END
