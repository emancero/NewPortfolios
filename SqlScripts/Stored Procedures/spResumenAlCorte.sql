-- =============================================
-- Author:		Edwin Calderón
-- Create date: 18/04/2024
-- Description:	Para elaborar el reporte de resumen del ISSPOL
-- ============================================= 

CREATE PROCEDURE [BVQ_BACKOFFICE].[spResumenAlCorte]
--declare
  @i_fechaCorte DATETIME = '2025-06-30T23:59:59'
, @i_lga_id INT = NULL
AS

BEGIN
	DELETE FROM corteslist
	INSERT INTO corteslist (c, cortenum)
		SELECT
			@i_fechaCorte
		   ,1
	EXEC BVQ_BACKOFFICE.GenerarCompraVentaFlujo

	DECLARE @tblResumenr TABLE (
		Sector VARCHAR(150)
	   ,Valor FLOAT
	   ,FechaCorte DATETIME
	   ,TipoRenta VARCHAR(100)
	)

	INSERT INTO @tblResumenr
		SELECT
			s.Sector
		   ,Valor = SUM(s.VALOR_NOMINAL)
		   ,@i_fechaCorte
		   ,'FIJA'
		FROM (SELECT
				VALOR_NOMINAL = sal
			   ,VALOR_EFECTIVO =
				CASE
					WHEN [TPO_F1] = (SELECT TOP 1
								kf1
							FROM keyf1
							WHERE natkey LIKE 'MINISTERIO DE FINANZAS|20240620|20160108|%'
							AND kf1 = 339) THEN 377916.44 / 873855.24 * sal
					WHEN [tvl_codigo] IN ('PCO') THEN sal * [htp_precio_compra] / 100.0
					ELSE sal * [tiv_precio] / 100.0
				END
			   ,SECTOR =
				CASE [sector_general]
					WHEN 'SEC_PRI_FIN' THEN sector_detallado--'PRIVADO FINANCIERO Y ECONOMÍA POPULAR SOLIDARIA'
					WHEN 'SEC_PRI_NFIN' THEN 'PRIVADO NO FINANCIERO'
					WHEN 'SEC_PUB_FIN' THEN 'PUBLICO'
					WHEN 'SEC_PUB_NFIN' THEN 'PUBLICO'
				END
			FROM BVQ_BACKOFFICE.PortafolioCorte pc
			JOIN BVQ_BACKOFFICE.PORTAFOLIO port
				ON pc.por_id = port.POR_ID
			LEFT JOIN BVQ_ADMINISTRACION.TIPO_VALOR_HOMOLOGADO H
				ON pc.tvl_codigo = H.[TVLH_CODIGO]
			WHERE sal > 0
			AND ISNULL(IPR_ES_CXC, 0) = 0
			AND tiv_tipo_renta = 153) s
		GROUP BY s.SECTOR

	INSERT INTO @tblResumenr
		SELECT
			'TOTAL_RV'
			,sum(
				case when tvl_codigo='FI' then
					isnull([TPO_INTERES_TRANSCURRIDO],0) + isnull([TPO_COMISION_BOLSA],0) + [htp_compra]*[htp_precio_compra]/case when [tiv_tipo_renta]=153 then 100e else 1e end
				else
					tiv_valor_nominal * sal
				end
			)
		   --,SUM(pc.sal)
		   ,@i_fechaCorte
		   ,'VARIABLE'
		FROM BVQ_BACKOFFICE.PortafolioCorte pc
		JOIN BVQ_BACKOFFICE.PORTAFOLIO port
			ON pc.por_id = port.POR_ID
		LEFT JOIN BVQ_ADMINISTRACION.TIPO_VALOR_HOMOLOGADO H
			ON pc.tvl_codigo = H.[TVLH_CODIGO]
		WHERE sal > 0
		AND ISNULL(IPR_ES_CXC, 0) = 0
		AND tiv_tipo_renta = 154
		UNION
		SELECT
			'TOTAL_AI'
		   ,SUM(/*ai.IMB_VALOR_LIBROS+*/isnull(ai.IMB_VALOR_AVALUO,0))
		   ,@i_fechaCorte
		   ,'INMUEBLE'
		--FROM BVQ_BACKOFFICE.ACTIVOS_INMOBILIARIOS ai
		FROM BVQ_BACKOFFICE.tfObtenerActivosInmobiliariosISSPOL(@i_fechaCorte) ai
		WHERE ai.IMB_VALOR_LIBROS > 0

	SELECT
		Sector=coalesce(Sector,sectorDim)
	   ,Valor=isnull(Valor,0)
	   ,FechaCorte=coalesce(FechaCorte,@i_fechaCorte)
	   ,TipoRenta=coalesce(TipoRenta,TipoRentaDim)
	FROM @tblResumenr t
	full join (values ('ECONOMÍA POPULAR Y SOLIDARIA','FIJA')) v (sectorDim, tipoRentaDim) on Sector=v.sectorDim
END
