create view bvq_backoffice.EventoPortafolio as
	select monto=coalesce(
		cus_monto,
		montooper-isnull(remaining,0)
	)
	,*
	--htp_comision_bolsa
	from bvq_backoffice.EventoPortafolioAprox e
	left join bvq_backoffice.portafolio_vencimiento porv
		on e.oper=1 and porv.porv_tfl_id=e.htp_id and porv.porv_tpo_id=e.htp_tpo_id
	left join(
		select htp_tpo_id rnd,sum(montooper) remaining,max(tfl_capital) cap,min(isnull(def_cobrado,1)) cobrado
		from bvq_backoffice.EventoPortafolioAprox e group by htp_tpo_id
	) d on
		e.htp_tpo_id=d.rnd and
		abs(tfl_capital-tfl_amortizacion)<5e-6 and --!encera saldos cercanos a 0
 		abs(remaining) between 5e-3 and 1e5 and
		d.cap>0 and -- filtra renta variable
		d.cobrado=1 -- filtra defaults
	--EMN: En casos excepcionales el cliente puede colocar un valor personalizado del pago
	left join BVQ_BACKOFFICE.custom_monto cus on cus.cus_tpo_id=e.htp_tpo_id and cus.cus_tfl_id=e.tfl_id
