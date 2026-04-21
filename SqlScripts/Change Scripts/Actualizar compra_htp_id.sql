update htp set compra_htp_id=primeraCompra.htp_id
from bvq_backoffice.historico_titulos_portafolio htp
join bvq_backoffice.SecuenciaCompra primeraCompra
	on primeraCompra.htp_tpo_id=htp.htp_tpo_id and primeraCompra.sec=1