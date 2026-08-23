--pseudocode to clarify the logic for latest_inicio
FECHA_PAGO_ULTIMO_CUPON=latest_inicio
latest_inicio
	=case when 1=1 and ultimoPagoInteres.fcup_fecha_original is not null
	then
		ultimoPagoInteres.fcup_fecha_original
	--when para portafolio vigente, o los tpo_id_anterior conocidos
	when isnull(ipr_es_cxc,0)=0 and ev.tfl_fecha_inicio_orig2 is not null or htp.tpo_id_anterior in (1516,213,215,222) then
		case when fecha_ultimo_pago>tfl_fecha_inicio_orig2 or htp.tpo_id_anterior in (1516)
		--casi nunca va entrar en este then
		then
			fecha_ultimo_pago
		--pero casi siempre va entrar en este else para portafolio vigente
		else
			coalesce(
				fechaUltimoPagoEnEvp   --casi nunca va a entrar en este caso, solo entra si tpo_id actual es 2545 o 2546 (215,222 en tpo_id_anterior)
				,tfl_fecha_inicio_orig2--casi siempre va a entrar en este caso para portafolio vigente
			)
		end
	else
		latest_inicio
	end


--tfl_fecha_inicio_orig2 --casi siempre va a entrar en este caso para portafolio vigente como se vio anteriormente
	left join (
		select ncorte=cl.c,tfl_fecha_inicio_orig2=min(tfl_fecha_inicio_orig),tfl_fecha_vencimiento2=max(tfl_fecha_vencimiento2),htp_tpo_id2=htp_tpo_id
		from bvq_backoffice.EventoPortafolioAprox e
		cross join bvq_backoffice.IGNORAR_RETR_NO_INGRESADO_ESTE_MES irn--retr_no_ingresado_este_mes es 0 en el único registro de esta tabla
		join corteslist cl on cl.c >= tfl_fecha_inicio_orig and cl.c<=case when irn_ignorar=1 and retr_no_ingresado_este_mes=1 then fecha_vencimiento_original
		else--siempre va por este else, es decir en portafolio vigente casi siempre cae en este caso
			--En EventoPortafolioAprox tfl_fecha_vencimiento2 considera el retraso de interés
			tfl_fecha_vencimiento2
		end
		and e.htp_id<>8829100001533
		where htp_tiene_valnom=1
		group by htp_tpo_id,cl.c
	) ev on htp.c=ncorte and (
		--para el portafolio vigente siempre toma tfl_fecha_vencimiento2 excepto para 2487, 2545, 2546
		ev.htp_tpo_id2=htp.tpo_id and isnull(progs.ipr_es_cxc,0)=0 and htp.tpo_id not in (2487,2545,2546)
		--también hace lo mismo para los títulos con tengan un tpo_id anterior pero que el tpo_id actual no sea 2486,2545,2546
		or ev.htp_tpo_id2=htp.tpo_id_anterior and htp.tpo_id in (2487,2545,2546)
	)

--ultimoPagoInteres
	outer apply (
		select top 1 FCUP_FECHA_ORIGINAL from bvq_backoffice.fecha_ultimo_cupon
		where fcup_tpo_id=tpo_id and fcup_desde<=htp.c
		order by fcup_desde desc
	) ultimoPagoInteres

--fecha_ultimo_pago
	,fecha_ultimo_pago=(
		select max(evp_fecha_original)
		from bvq_backoffice.evento_portafolio e
		join bvq_backoffice.retraso retr on 
		evp_tpo_id=retr_tpo_id
		and evt_fecha>=retr_fecha_esperada
		and evt_fecha<c
		and es_vencimiento_interes=1
		--solo aplica si tpo_id_anterior o tpo_id actual son 1516
		join (select xtpo_id=1516) x on x.xtpo_id in (max(tpo.tpo_id_anterior),htp_tpo_id)
		where evp_tpo_id in (max(tpo.tpo_id_anterior),htp_tpo_id)
		and isnull(e.evp_observaciones,'')<>'Reclasificación'
		and c>='20251031'
	)
/*
tpo_id_anterior	tpo_id
213	2487
1516	2488
215	2545
222	2546
*/
select * from bvq_backoffice.titulos_portafolio where tpo_id_anterior in (213,215,222,1516)--

--epv
	,fechaUltimoPagoEnEvp=
	--solo aplica si tpo_id_actual es 2545 o 2546
	case when htp_tpo_id in (2545,2546) then
	(
	--select count(*),sum(checksum(*)%10000) from bvq_backoffice.eventoportafoliocorte-- where htp_tpo_id=2546
	--1508	-201823

		select top 1
		--evt_fecha
		evp_fecha_valor_interes
		from
		--bvq_backoffice.evento_portafolio evp
		(
			select
			evp_fecha_valor_interes=coalesce(evp_fecha_valor_interes,evt_fecha),--notar este coalesce!
			evp.* from bvq_backoffice.evento_portafolio evp
			left join (
				values
				 (7932,'20260329')
				,(7931,'20260323')
			) v(evp_id,evp_fecha_valor_interes)
			on v.evp_id=evp.evp_id
			where isnull(evp.evp_observaciones,'')<>'Reclasificación'
		) evp
		where evp_tpo_id=max(tpo_id_anterior) and evt_fecha<=c order by evt_fecha desc
	)
	else
		max(case when oper=1 and htp_tpo_id in (2487) then coalesce(convert(date,evt_fecha),htp_fecha_operacion) end)
	end
