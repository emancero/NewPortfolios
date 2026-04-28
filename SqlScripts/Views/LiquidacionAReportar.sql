create view bvq_backoffice.LiquidacionAReportar as
		select
		 htp_fecha_operacion
		,montooper=sum(
			signo
			*montooper)
		,itrans=sum(itrans)--o sum(TPO_INTERES_TRANSCURRIDO)
		,tpo_numeracion
		,oper=subTrans
		,htp_precio_compra=min(evp.htp_precio_compra)--fecha_operacion
		,tasa_cupon=max(tasa_cupon)
		,liq_rendimiento=max(liq_rendimiento)
		,valorEfectivo=
		sum(
			signo
			*(case when htp_tiene_valnom=1 or htp_tiene_valnom=0 and htp_tpo_id<1500 then

		  --isnull([TPO_INTERES_TRANSCURRIDO],0) + isnull([TPO_COMISION_BOLSA],0)
		  --+ [htp_compra]*[htp_precio_compra]
		  --+
		  coalesce(
			case when tpo_numeracion in ('ATX-2025-04-24','ATX-2025-04-25')
			then valnomCompraAnterior end,[montooper]
		  )
		  *
		  coalesce(
			case when tpo_numeracion in ('ATX-2025-04-24','ATX-2025-04-25')
			then precioCompraAnterior end, [htp_precio_compra]
		  )
		  /case when [tiv_tipo_renta]=153 then 100e else 1e end
	   end)
	   )
	   ,tpo.tiv_id
	   ,fon_id=max(tpo.fon_id)
	   ,esCxc=max(isnull(ipr_es_cxc,0))
	   ,tpo_acta=max(tpo.tpo_acta)
	   ,valor_pago_capital=null
	   ,valor_pago_cupon=null
	   ,Fecha_Ultimo_Pago=null
	   ,Saldo_Valor_Nominal=sum(evp.montooper)  --Activar si es antes -sum(montooper)
	   ,Precio_de_mercado=null
	   ,Valor_Mercado=null
	   ,TPO_MANTIENE_VECTOR_PRECIO=max(convert(int,tpo_mantiene_vector_precio))
	   ,evp_fecha_compra=htp_fecha_operacion
	   ,dividendo_en_efectivo=null
	   ,dividendo_en_acciones=null
	   ,opSec=row_number() over (partition by tpo_numeracion order by htp_fecha_operacion)
	   ,TPO_INTERES_TRANSCURRIDO=null
	   ,TPO_COMISION_BOLSA=null
	   ,INTERES_GANADO_2=null
	   --,evt_fecha
	   --select tfl_fecha_inicio,tfl_fecha_inicio_orig,htp_fecha_operacion,tiv_tipo_base--*
	   --into _temp.pc
		from bvq_backoffice.EventoPortafolio evp
		join bvq_backoffice.titulos_portafolio tpo on tpo.tpo_id=evp.htp_tpo_id
		left join bvq_backoffice.ISSPOL_PROGS ipr on ipr.IPR_NOMBRE_PROG=tpo.tpo_prog
		left join (select valnomCompraAnterior=tpo_cantidad, precioCompraAnterior=tpo_precio_ingreso, tpo_id from BVQ_BACKOFFICE.titulos_portafolio) tpo2 on tpo2.tpo_id=tpo.tpo_id_anterior
		left join(values
			(46,'20140612')
		) errTpoFechaIngreso(errTpoId,errTpoFechaIngreso) on tpo.tpo_id=errTpoId

		--unir con tpo reclasificado si existe
		left join (select tpo_id_nuevo=tpo_id, tpo_id_anterior, tpo_fecha_ingreso from bvq_backoffice.titulos_portafolio) tpoNuevo
			on tpoNuevo.tpo_id_anterior=evp.htp_tpo_id and evp.htp_fecha_operacion=tpoNuevo.tpo_fecha_ingreso

		--determinar subtipo de transacción
		cross apply(select subTrans=case when compra_htp_id=htp_id then 0 when tpo_id_nuevo is not null then 3 end) subTrans
		cross apply(select signo=iif(subTrans=3 and montooper<0,-1,1)) signo -- cambiar de signo si es reclasificación a CxC
		where --montooper>0 and
		subTrans is not null --and htp_fecha_operacion between '20251101' and '2025-11-30T23:59:59'
		--and compra_htp_id=htp_id or tpo_id_anterior is not null)--and tipoTrans not in ('Movimiento')
		--and datediff(d,htp_fecha_operacion,coalesce(errTpoFechaIngreso,tpo_fecha_ingreso))=0
		group by tpo_numeracion
		,oper
		,subTrans
		,htp_fecha_operacion,tpo.tiv_id