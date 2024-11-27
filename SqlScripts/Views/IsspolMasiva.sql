create view BVQ_BACKOFFICE.IsspolMasiva AS
	select a.codigo,a.id_tipo_comprobante,aReferencia=a.referencia,aConvepto=a.concepto,cb_descripcion=cb.descripcion,mt.modifica_equipo
	,dniIdAsiento=dni.id_asiento
	,dniReferencia=dni.referencia
	,dniSec=dni.sec,dni.creacion_usuario,ml.fecha
	,ml.id_banco,id_cuenta_contable,lotAsiento=ml.id_asiento
	,mtObservacion=mt.observacion
	,mtNombre=mt.nombre--m.*,c.*
	--,mt.*--,mt.referencia,mt.nombre,id_asiento,observacion,*
	--select a.id_asiento,dni.*
	from siisspolweb.siisspolweb.banco.masivas_lote ml
	join siisspolweb.siisspolweb.banco.masivas_transaccion mt on mt.id_masivas_lote=ml.id_masivas_lote
	join siisspolweb.siisspolweb.banco.cuenta cb on ml.id_cuenta_banco=cb.id_cuenta
	left join siisspolweb.siisspolweb.banco.masiva_detalle_deposito_noidentif dni on dni.id_masivas_transaccion=mt.id_masivas_transaccion
	left join siisspolweb.siisspolweb.contabilidad.asiento a on a.id_asiento=dni.id_asiento
	left join siisspolweb.siisspolweb.contabilidad.movimiento m on m.id_asiento=a.id_asiento and m.sec=dni.sec
	left join siisspolweb.siisspolweb.contabilidad.cuenta c on c.id_cuenta=m.id_cuenta-- and m.sec=1
	--where --and observacion like 'dep%'
	--and ml.id_masivas_lote>=5110
	--ml.fecha between '20241105' and '20241105' --and mt.nombre like '%agrosylm%'
	--and ml.id_banco=18
	--and a.codigo like 'ivs%'
	--and id_masiva_noidentif is not null
	--and mt.modifica_equipo like 'win-ep72%'
	--order by ml.fecha
