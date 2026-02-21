CREATE view BVQ_BACKOFFICE.TotalRecuperacionesView as
--with a as(
	SELECT
		 [Tipo de título]=cir.tvl_nombre
		,cir.por_id
		,[Cuenta]=cir.acreedora
		,[Cuenta nombre]=cir.nomAcreedora
		,[Capital]=CASE WHEN cir.rubro in ('amount','amountcxc') THEN cir.monto END
		,[Interés]=CASE WHEN cir.rubro in ('intacc','prov') THEN cir.monto END
		,cir.Fecha
		,Fondo=cir.POR_CODIGO
		,[Numeración]=cir.tpo_numeracion
		,Estado=case when isnull(ipr_es_cxc,0)=0 then 'Vigente' else 'CxC' end
		,Emisor=ems_nombre
		,[Uso de fondos]=case when cir.rubro in ('intacc') then cir.UFO_USO_FONDOS end
		,oper
		,htp_id
		,coalesce(edpi.EDPI_CUENTA+'.'+edpi.EDPI_AUX,cir.deudoraSinAux+'.'+deudoraAux) NumCtaDepNoIdent
		,coalesce(edpi.EDPI_NOM_CUENTA,cir.nomDeudora) CtaDepNoIdent
		,referencias
		,cuenta_bancaria NumCtaDep
		,cuenta_bancaria_descr CtaDep
		,[CapitalNominal]=CASE WHEN cir.rubro in ('valnom') THEN cir.monto END
		,[InteresNominal]=cir.montoSinPerfil
		,cir.rubro
		--EDPI_NOM_CUENTA
	--select *
	FROM BVQ_BACKOFFICE.ComprobanteIsspolRubros cir
	left join
	BVQ_BACKOFFICE.EXCEPCIONES_DEP_POR_IDENTIFICAR edpi
		on edpi.edpi_numeracion=CIr.tpo_numeracion-- and CIr.cuenta='2.1.90.03'
	left join (
		select referencias=dbo.stringagg(refTab.referencia+': '+format(refTab.valor,'c','es-EC'),', ')
		,cuenta_bancaria=max(cb.cuenta)
		,cuenta_bancaria_descr=max(cb.descripcion)
		,tpo_numeracion
		,refFecha=convert(varchar,refTab.fecha,20)
		--,tpo_numeracion,fecha,fecha_original,valord=valor,referencia
		from bvq_backoffice.liquidez_referencias_table refTab
		left join siisspolweb.siisspolweb.banco.masivas_transaccion mt
			join siisspolweb.siisspolweb.banco.masivas_lote ml on ml.id_masivas_lote=mt.id_masivas_lote
			join siisspolweb.siisspolweb.banco.cuenta cb on cb.id_cuenta=ml.id_cuenta_banco
		on mt.id_masivas_transaccion=refTab.idMasivasTransaccion
		where not (tpo_numeracion='ATX-2023-10-25-2' and refTab.valor=14586.25)
		group by tpo_numeracion, convert(varchar,refTab.fecha,20)
	) ref
	on cir.tpo_numeracion=ref.tpo_numeracion
	and convert(varchar,cir.fecha,20)=refFecha
		--and cir.ri in ('DIDENT','DIDENT02')
		--and round(debe,0)=round(ref.valor,0)
	WHERE
	cir.tipo = 'C'
	AND cir.acreedoraSinAux NOT LIKE '2%'
	AND (
		monto IS NOT NULL
		--or montoSinPerfil is not null --feature_intnom
	)
    --AND left(prefijo,1) not in ('D','R')--

	AND deterioro=0--(ipr_es_cxc = 1 or (ipr_es_cxc is null or ipr_es_cxc = 0 ) and deterioro = 0)
	AND (
		cir.en_espera = 1 or cir.fecha<'20240301'
		--or montoSinPerfil is not null --feature_intnom
		)
	AND cir.rubro IN ('AMOUNT', 'amountcxc','INTAcc', 'PROV','valnom'
		--,'intnom' --feature_intnom
	)
--) select sum(interesNominal) from a where fecha between '20240501' and '20240531'
