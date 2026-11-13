create view BVQ_BACKOFFICE.PAIColocacionesView as
		SELECT
			v.montoOper
				+isnull(htp_comision_bolsa,0)
				-isnull(lip_retencion,0)
			AS saldo,
			pcp.PCP_NOMBRE AS fondo,
			--v.tvl_nombre AS tipo_valor,
			pcpVal.PCP_NOMBRE AS tipo_inversion,
			'Colocaciones' AS grupo
		FROM bvq_backoffice.ObtenerDetallePortafolioConLiquidezView v
			LEFT JOIN BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO pcpo
				ON pcpo.POR_ID = v.por_id
			LEFT JOIN BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO pcp
				ON pcp.PCP_ID = pcpo.PCP_ID

			--Unir con tipo de valor
			LEFT JOIN BVQ_BACKOFFICE.PAI_CODIGO_TIPO_VALOR pctv
				JOIN BVQ_ADMINISTRACION.TIPO_VALOR tvl on pctv.TVL_ID=tvl.TVL_ID
			ON tvl.tvl_codigo=v.tvl_codigo
			LEFT JOIN BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO pcpVal
				ON pcpVal.PCP_ID = pctv.PCP_ID

		WHERE ISNULL(v.IPR_ES_CXC, 0) = 0
			AND v.oper = 0
			AND v.compra_htp_id = v.htp_id