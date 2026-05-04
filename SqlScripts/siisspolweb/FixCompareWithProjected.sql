--de script de comparación cuando sum(total_cuota) not grouped by evp_id<>sum(plus)
update evp set evp_valor_efectivo=newVe from bvq_backoffice.evento_portafolio evp
join (
	values(3189,94494.937,188989.87),(3190,567.563,1135,13)
) v(evpId, newVe, oldVe) on v.evpId=evp.evp_id
