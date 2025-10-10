
--PROVISIÓN:

	--
	,originalProvision			=
						case when evt.es_vencimiento_interes=0 and (tasa_cupon<>0 or tasa_cupon is null) or ipr_es_cxc=1 and fecha>='20240825' then 0 else
							case when coalesce(evp.evp_rendimiento,evt.UFO_RENDIMIENTO) is not null then
								case when evt.tiv_subtipo=3 and tasa_cupon=0 and 1=0 then 0 else coalesce(evp.evp_rendimiento,evt.UFO_RENDIMIENTO) end
							when saldo is not null and tfl_fecha_inicio_orig is not null then
								dbo.CalculateProvision(

	--sp ObtenerDetallePortafolioConLiquidez
					,provision=coalesce(evp_ajuste_provision,originalProvision,0)


			when 'prov' then 
				prov
				+case when hist_fecha_compra>tfl_fecha_inicio_orig then isnull(itrans,0) else 0 end
				+case when oper=0 then itrans else 0 end

--INTERÉS rubros:
			when 'intAcc' then intAcc
				+case when ipr_es_cxc=1 then isnull(ufo_uso_fondos,0) else 0 end

--INTERÉS liqintprov:

					--depósito total capital+interés
					--depósito de interés:
					coalesce(nullif(e.vep_valor_efectivo,0), amount)
					+
					--depósito de capital:
					case when tvl_codigo in ('PCO','FAC') and tasa_cupon=0 and isnull(e.ipr_es_cxc,0)=0 then
						hist_precio_compra/100.0 * htp_compra
					else
						coalesce(capMonto,case when isnull(evp_abono,0)=0 then -montooper else 0 end)
					end
					+case when isnull(evp_abono,0)=1 then isnull(ufo_rendimiento-pr,0) else 0 end
				--fin depósito total capital+interés

				-
				round(
					coalesce(
						EVP_AJUSTE_VALOR_EFECTIVO
						,prEfectivo
						*coalesce(capMonto,case when isnull(evp_abono,0)=0 then -montooper else 0 end)
					)
				,2)
				-
				case when isnull(evp_abono,0)=0 then case when isnull(ipr_es_cxc,0)=0 then -1 else 1 end * isnull(UFO_USO_FONDOS,0) else 0 end
				-case when isnull(evp_abono,0)=0 then pr else 0 end
				-case when tpo_fecha_ingreso>TFL_FECHA_INICIO and htp_tpo_id not in (2268,2269) then ISNULL(itrans,0) else 0 end
