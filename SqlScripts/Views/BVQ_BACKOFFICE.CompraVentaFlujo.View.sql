create view bvq_backoffice.CompraVentaFlujo as
	select 
	*
	--,vencimiento=case when def_int_cobrado is null then tfl_fecha_vencimiento2 else null end
	--,amortizacion=case when isnull(tpo_redondear_amortizacion,1)=1 then round(orig*tfl_amortizacion,5) else round(orig*tfl_capital,5)-round(orig*tfl_capital_1,5) end
	--	*isnull(def_cobrado,1)
	--,iAmortizacion=   round(orig*tfl_capital*iTasa_interes*dias_cupon/(base_denominador*100),3)
	--	*isnull(def_cobrado,1)--*case when def_cobrado is not null then isnull(def_exacto,0) else 1 end

	,amortizacion2=case when isnull(tpo_redondear_amortizacion,1)=1 then round(orig*tfl_amortizacion,2) else round(orig*tfl_capital,2)-round(orig*tfl_capital_1,2) end
		*def_cobrado_2
	,iAmortizacion2=round(orig*tfl_capital*iTasa_interes*dias_cupon/(base_denominador*100),3)
		*def_cobrado_2--*case when def_cobrado is not null then isnull(def_exacto,0) else 1 end

	,allIAmortizacion=round(orig*tfl_capital*iTasa_interes*dias_cupon/(base_denominador*100),3)
	from bvq_backoffice.compra_venta_flujo
