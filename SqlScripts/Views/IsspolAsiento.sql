create view BVQ_BACKOFFICE.IsspolAsiento AS
	select a.codigo,a.id_tipo_comprobante,aReferencia=a.referencia,a.concepto,cb.descripcion,mt.modifica_equipo,detAsiento=dni.id_asiento,dni.referencia,dni.sec,dni.creacion_usuario,ml.fecha,ml.id_banco,id_cuenta_contable,lotAsiento=ml.id_asiento,mt.observacion
	--,mt.*--,mt.referencia,mt.nombre,id_asiento,observacion,*
	from siisspolweb.siisspolweb.banco.masivas_lote ml
	right join siisspolweb.siisspolweb.banco.masivas_transaccion mt on mt.id_masivas_lote=ml.id_masivas_lote
	right join siisspolweb.siisspolweb.banco.cuenta cb on ml.id_cuenta_banco=cb.id_cuenta
	right join siisspolweb.siisspolweb.banco.masiva_detalle_deposito_noidentif dni on dni.id_masivas_transaccion=mt.id_masivas_transaccion
	right join siisspolweb.siisspolweb.contabilidad.asiento a on a.id_asiento=dni.id_asiento
