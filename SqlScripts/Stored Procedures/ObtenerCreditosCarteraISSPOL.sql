CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerCreditosCarteraISSPOL]
		@i_fechaCorte	DATETIME,
		@i_lga_id	INT
AS
	BEGIN
		SELECT DISTINCT por_ord,
						CRC_ID_CUENTA,
						ICB_CUENTA_CONTABLE_NOMBRE,
						POR_CODIGO,
						cr.*,
						plazo= right('    '+rtrim(datediff(d,@i_fechacorte,crc_fecha_vencimiento)/360*360),5) +' a '+right('    '+rtrim((datediff(d,@i_fechacorte,crc_fecha_vencimiento) / 360 + 1)*360),5)
		FROM   BVQ_BACKOFFICE.CREDITOS_CARTERA cr
			   JOIN bvq_backoffice.isspol_cuentas_contables_de_bancos icb ON cr.crc_id_cuenta = icb.icb_por_id
			   JOIN bvq_backoffice.portafolio por ON icb.icb_por_id = por.por_id
		where	datediff(mm, CRC_FECHA_CIERRE, @i_fechaCorte) = 0
		ORDER BY por_ord
	END
