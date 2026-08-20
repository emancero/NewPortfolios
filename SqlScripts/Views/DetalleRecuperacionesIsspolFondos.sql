CREATE VIEW BVQ_BACKOFFICE.DetalleRecuperacionesIsspolFondos
AS
select
		evp.tiv_tipo_renta as tipo_renta,
		MAX(
			CASE itcsector.itc_valor
				WHEN 'Público - No Financiero' THEN 'Público'
				WHEN 'Privado - No Financiero' THEN 'Privado no Financ.'
				WHEN 'Privado - Financiero'    THEN 'Privado Financiero'
				ELSE itcsector.itc_valor
			END
		) AS sector,
		tvl_nombre,
		max(coalesce(tpo.TPO_FECHA_COMPRA_ANTERIOR, evp.fecha_compra)) AS fecha_compra,
		max(evp.tiv_fecha_vencimiento) as fecha_vencimiento,
		max(ems.EMS_NOMBRE) as nombre,
		saldo_valor_nominal=--max(evp.saldo),--cap.movCapital),--sum(evp.saldo),
		(
			select
				sum(
					--montooper
					coalesce(
						-evp_valor_efectivo,
						--case when HTP_TIENE_VALNOM=1 then montooper end
						montooperOld
					)
					--+isnull(-evp_valor_efectivo,0)
					-isnull(remaining,0)
				)
			from bvq_backoffice.eventoportafolio saldoTpo
			where coalesce(evt_fecha, htp_fecha_operacion)<e.evt_Fecha and saldoTpo.htp_tpo_id=evp.htp_tpo_id
			group by saldoTpo.htp_tpo_id
		),

		--saldo_valor_nominal=(select sal from _temp.portafoliocorte pc where pc.httpo_id=max(evp.htp_tpo_id)),
		rendimiento=max(evp.liq_rendimiento),
		plazo_cupon=max(evp.dias_cupon),
		capital=sum(CASE WHEN evp.rubro in ('amount','amountcxc') and deterioro=0 THEN evp.monto END),
		iamortizacion = sum(CASE WHEN evp.rubro in ('intacc','prov') and deterioro=0 THEN evp.monto END),
		prov = sum(CASE WHEN evp.rubro in ('prov') and deterioro=0 THEN evp.monto END),
		--pago_total=sum(case when evp.es_vencimiento_interes=0 then amount else 0 end)+sum(isnull(case when evp.es_vencimiento_interes=1 then evp.iAmortizacion end,0)),
		observaciones = MAX(evpo.evp_observaciones),
		fecha_pago=fecha,
		fecha_de_vencimiento_flujo=max(evp.fecha_original),
		acciones_judiciales=CONCAT('Realizó el pago del flujo No. ', ' ', tfl_periodo),
		max(iif(isnull(ipr_es_cxc,0)=1,'Otras cuentas por cobrar',case when evp.tiv_tipo_renta=153 then 'Inversiones de Renta Fija' else 'Inversiones de Renta Variable' end)) as primer_nivel,
		max(iif(tvl_codigo in ('OBL','BE','VCC','OCA'),'Con cupón de capital e interés','Al vencimiento capital e interés')) as tipo_flujo,
		evp.tiv_tipo_renta, ems.EMS_NOMBRE, por_codigo, evp.tpo_numeracion,oper,fecha,tpo.tiv_id,--,htp_fecha_operacion
		deterioro=max(deterioro),
		tvl_codigo,
		tpo.por_id,
		evp.htp_tpo_id
		from bvq_backoffice.comprobanteisspolrubros evp--LiqIntProv evp--
		--cross apply(
		--	select sum(amount) movCapital from bvq_backoffice.evtTemp e
		--	where e.htp_tpo_id=evp.htp_tpo_id and e.fecha<evp.fecha
		--) cap
			--cross apply(
		--	select movCapital=sum(coalesce(-evp_valor_efectivo,montooper))
		--	from bvq_backoffice.eventoPortafolio e
		--	where coalesce(evt_fecha,htp_fecha_operacion)<fecha
		--	and e.htp_tpo_id=evp.htp_tpo_id
		--) cap
		--bvq_backoffice.ObtenerDetallePortafolioConLiquidezView evp
			--join (
			--	select r=row_number() over (partition by htp_tpo_id order by htp_fecha_operacion, htp_id), tpo_interes_transcurrido,tpo_comision_bolsa,htp_precio_compra,e.htp_tpo_id
			--	from bvq_backoffice.eventoportafolio e
			--	join bvq_backoffice.titulos_portafolio tpo on e.htp_tpo_id=tpo.tpo_id
			--	where montooper>0
			--) s on s.htp_tpo_id=evp.htp_tpo_id and r=1
 
		join bvq_backoffice.titulos_portafolio tpo on tpo.tpo_id=evp.htp_tpo_id
		join bvq_administracion.titulo_valor tiv on tpo.TIV_ID=tiv.TIV_ID
		join BVQ_ADMINISTRACION.emisor ems on tiv.tiv_emisor=ems.ems_id
		join bvq_administracion.ITEM_CATALOGO itcsector on ems.EMS_SECTOR=itcsector.ITC_ID
		left join (select valnomCompraAnterior=tpo_cantidad, precioCompraAnterior=tpo_precio_ingreso, tpo_id from BVQ_BACKOFFICE.titulos_portafolio) tpo2 on tpo2.tpo_id=tpo.tpo_id_anterior
		left join bvq_backoffice.evento_portafolio evpo on evpo.evp_id = evp.evp_id
		where oper=1
		and evp.tipo='C'
		and evp.acreedoraSinAux not like '2%'
		and monto is not null
		--and deterioro=0
		and (
			evp.en_espera=1 or evp.fecha<'20240301'
		)
		AND evp.rubro IN ('AMOUNT', 'amountcxc','INTAcc', 'PROV','valnom')
		--and fecha between '20251201' and '20251231'
 
		group by evp.tiv_tipo_renta, tvl_nombre, ems.EMS_NOMBRE, por_codigo, evp.tpo_numeracion,oper,fecha,tpo.tiv_id,tvl_codigo, tpo.por_id, tfl_periodo, evp.htp_tpo_id--,htp_fecha_operacion
