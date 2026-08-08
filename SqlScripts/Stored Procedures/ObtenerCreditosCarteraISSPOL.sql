CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerCreditosCarteraISSPOL]
		@i_fechaCorte	DATETIME,
		@i_lga_id	INT
AS
	BEGIN
		SELECT DISTINCT por_ord,
						CRC_ID_CUENTA,
						ICB_CUENTA_CONTABLE_NOMBRE=fh.descripcion,
						fh.POR_CODIGO,
--						cr.*,
						ID
						,CRC_FECHA_CIERRE
						,CRC_IDENTIFICACION
						,CRC_NUMERO_OPERACION
						,CRC_SALDO_PRESTAMO
						,CRC_ID_PRODUCTO
						,CRC_SEGMENTO
						,CRC_FECHA_OTORGAMIENTO
						,CRC_MONTO
						,CRC_FECHA_VENCIMIENTO
						,CRC_TASA
						,CRC_ESTADO
						,CRC_PLAZO
						,CRC_ID_CUENTA
						,CRC_DESCRIPCION
						,CRC_ID
                        ,[Tipo Afiliación]
                        ,dias_morosidad
						,plazo= right('    '+rtrim(datediff(d,@i_fechacorte,crc_fecha_vencimiento)/360*360),5) +' a '+right('    '+rtrim((datediff(d,@i_fechacorte,crc_fecha_vencimiento) / 360 + 1)*360),5)
        FROM   BVQ_BACKOFFICE.CREDITOS_CARTERA cr
		join bvq_backoffice.fondo_homologacion fh on fh.id_cuenta=crc_id_cuenta
		--	   JOIN bvq_backoffice.isspol_cuentas_contables_de_bancos icb ON cr.crc_id_cuenta = icb.icb_por_id
			   JOIN bvq_backoffice.portafolio por ON fh.por_id = por.por_id
		where	datediff(mm, CRC_FECHA_CIERRE, @i_fechaCorte) = 0
		ORDER BY por_ord
	END
