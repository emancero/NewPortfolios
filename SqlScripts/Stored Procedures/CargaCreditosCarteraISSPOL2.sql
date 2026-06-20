--exec [BVQ_BACKOFFICE].[CargaCreditosCarteraISSPOL2] null
-- =============================================
-- Author:		Edwin Calderón Z.
-- Create date: 14/08/2023
-- Description:	Carga de información de Creditos ISSPOL
-- =============================================
CREATE PROCEDURE [BVQ_BACKOFFICE].[CargaCreditosCarteraISSPOL2]
		@i_lga_id	   INT
AS

	BEGIN
		truncate table [BVQ_BACKOFFICE].[CREDITOS_CARTERA]
		INSERT INTO [BVQ_BACKOFFICE].[CREDITOS_CARTERA]
				(
					[CRC_FECHA_CIERRE],
					[CRC_IDENTIFICACION],
					[CRC_NUMERO_OPERACION],
					[CRC_SALDO_PRESTAMO],
					[CRC_ID_PRODUCTO],
					[CRC_SEGMENTO],
					[CRC_FECHA_OTORGAMIENTO],
					[CRC_MONTO],
					[CRC_FECHA_VENCIMIENTO],
					[CRC_TASA],
					[CRC_ESTADO],
					[CRC_PLAZO],
					[CRC_ID_CUENTA],
					[CRC_DESCRIPCION],
					[CRC_ID]
				)
		exec siisspolweb.siisspolweb.dbo.sp_executesql N'
			SELECT
					fecha_cierre,
					identificacion,
					numero_operacion,
					saldo_prestamo,
					id_producto,
					segmento,
					fecha_otorgamiento,
					monto,
					fecha_vencimiento,
					tasa,
					Estado,
					plazo,
					id_cuenta,
					descripcion,
					0
			FROM
					--isspol.Credito.vis_creditos_cartera
					--habilitar en prod:
					(

						select distinct a.fecha_cierre,
							a.identificacion, 
							--b.nombre_completo,
							--nombre_completo=null,
							a.numero_operacion,	
							a.saldo_prestamo, 
							--id_producto=null,
							c.id_producto,
							--segmento=null,
							d.nombre segmento, 
							--fecha_otorgamiento=null,
							c.fecha_otorgamiento, 
	

							--monto=null,
							c.monto,
							--fecha_vencimiento=null,
							c.fecha_vencimiento,
							--tasa=null,
							c.tasa,
							--Estado=null,
							case a.dias_morosidad 
								when 0 then
								''Vigente''
								else ''Mora''
							end Estado, 
							--plazo=null,
							c.plazo,
							--id_cuenta=null,
							c.id_cuenta, 
							--descripcion=null
							f.descripcion 
						from credito.R84_saldos_2022 a with (nolock)
							--inner join persona.vis_persona_completo b on a.identificacion =b.identificacion
							inner join credito.credito c on a.numero_operacion =c.id_credito 
							inner join credito.segmento d on c.id_segmento =d.id_segmento 
							inner join banco.cuenta f 	on c.id_cuenta =f.id_cuenta
					) fuente
				--din habilitar en prod
			WHERE
			fecha_cierre>''20231231''--isnull((select max(crc_fecha_cierre) from bvq_backoffice.creditos_cartera),0)
					/*(CONVERT(VARCHAR, fecha_cierre, 112) + CONVERT(VARCHAR, identificacion) + CONVERT(VARCHAR, numero_operacion)) NOT IN (SELECT
								(CONVERT(VARCHAR, cc.[CRC_FECHA_CIERRE], 112) + CONVERT(VARCHAR, cc.[CRC_IDENTIFICACION]) + CONVERT(VARCHAR, cc.[CRC_NUMERO_OPERACION]))
						FROM
								BVQ_BACKOFFICE.CREDITOS_CARTERA cc)*/'

	END