create view BVQ_BACKOFFICE.PagoSB as
	select
		evp.fecha
	,montooper=sum(evp.montooper)
	,itrans=sum(case when evp.es_vencimiento_interes=1 then iamortizacion end)--o sum(itrans)--o sum(TPO_INTERES_TRANSCURRIDO)
	,evp.tpo_numeracion
	,oper
	,htp_precio_compra=min(tpo_precio_ingreso)--evp.htp_precio_compra)--fecha_operacion
	,tasa_cupon=max(tasa_cupon)
	,liq_rendimiento=max(liq_rendimiento)
	,valorEfectivo=sum(prEfectivo*evp.htp_compra)
	/*sum(
		--(case when min_tiene_valnom=1 or min_tiene_valnom=0 and httpo_id<1500 then

		isnull(s.[TPO_INTERES_TRANSCURRIDO],0) + isnull(s.[TPO_COMISION_BOLSA],0)
		--+ [htp_compra]*[htp_precio_compra]
		+
		coalesce(
		case when evp.tpo_numeracion in ('ATX-2025-04-24','ATX-2025-04-25')
		then valnomCompraAnterior end,[montooper]
		)
		*
		coalesce(
		case when evp.tpo_numeracion in ('ATX-2025-04-24','ATX-2025-04-25')
		then precioCompraAnterior end, [htp_precio_compra]
		)
		/case when [tiv_tipo_renta]=153 then 100e else 1e end
	--end)
	)*/
	,tpo.tiv_id
	,fon_id=max(tpo.fon_id)
	,esCxc=convert(bit,max(isnull(convert(int,ipr_es_cxc),0)))
	,tpo_acta=max(tpo.tpo_acta)

	,valor_pago_capital=sum(
		coalesce(
				case when htp_dividendo=1 or es_vencimiento_interes=1 then 0 end
			,
				case when evp.htp_tiene_valnom=0
				then -specialValnom end
			,
				case when evp_abono=1 and es_vencimiento_interes=0 then
					vep_valor_efectivo
				end
			,capMonto
			,-evp.montooper
		)
	)
		
	,valor_pago_cupon=sum(
		evp.valor_pago_cupon
	)+
	sum(
		coalesce(
				case when htp_dividendo=1 or es_vencimiento_interes=1 then 0 end
			,
				case when evp.htp_tiene_valnom=0
				then -specialValnom end
			,
				case when evp_abono=1 and es_vencimiento_interes=0 then
					vep_valor_efectivo
				end
			,capMonto
			,-evp.montooper
		)
	)
	,Fecha_Ultimo_Pago=evp.fecha
	,Saldo_Valor_Nominal=sum(evp.saldo)-- --Activar en el caso de que sea antes: -isnull(sum(case when es_vencimiento_interes=0 then amount end),0)
	,Precio_de_mercado=null
	,Valor_Mercado=null
	--,evt_fecha
	--select tfl_fecha_inicio,tfl_fecha_inicio_orig,htp_fecha_operacion,tiv_tipo_base--*
	--select *
	,TPO_MANTIENE_VECTOR_PRECIO=max(convert(int,tpo_mantiene_vector_precio))
	,evp_fecha_compra=min(case when oper=0 then evp.htp_fecha_operacion end)
	,dividendo_en_efectivo=sum(case when tiv_tipo_renta=154 and es_vencimiento_interes=1 then intAcc end)
	,dividendo_en_acciones=sum(case when tiv_tipo_renta=154 and htp_dividendo=1 then amount end)
	,opSec=1
	,TPO_INTERES_TRANSCURRIDO=null
	,TPO_COMISION_BOLSA=null
	,INTERES_GANADO_2=null
	from bvq_backoffice.LiqIntProv evp
	left join BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO htp on evp.oper=0 and evp.htp_id=htp.htp_id and htp_dividendo=1
		--join (
		--	select r=row_number() over (partition by htp_tpo_id order by htp_fecha_operacion, htp_id), tpo_interes_transcurrido,tpo_comision_bolsa,htp_precio_compra,e.htp_tpo_id
		--	from bvq_backoffice.eventoportafolio e
		--	join bvq_backoffice.titulos_portafolio tpo on e.htp_tpo_id=tpo.tpo_id
		--	where montooper>0
		--) s on s.htp_tpo_id=evp.htp_tpo_id and r=1

	join bvq_backoffice.titulos_portafolio tpo on tpo.tpo_id=evp.htp_tpo_id
	left join (select valnomCompraAnterior=tpo_cantidad, precioCompraAnterior=tpo_precio_ingreso, tpo_id from BVQ_BACKOFFICE.titulos_portafolio) tpo2 on tpo2.tpo_id=tpo.tpo_id_anterior
	where (oper=1 or htp_dividendo=1)
	--and fecha between '20240101' and '20240131'

	group by evp.tpo_numeracion,oper,fecha,tpo.tiv_id--,htp_fecha_operacion