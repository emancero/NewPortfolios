alter view BVQ_BACKOFFICE.TotalRecuperacionesView as
	SELECT
		 [Tipo de título]=cir.tvl_nombre
		--,cir.por_id
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
		,coalesce(edpi.EDPI_CUENTA,cir.deudoraSinAux) depSinAux
		,coalesce(edpi.EDPI_AUX,cir.deudoraAux) depAux
		,coalesce(edpi.EDPI_NOM_CUENTA,cir.nomDeudora) depNombre
		,referencias
	FROM BVQ_BACKOFFICE.ComprobanteIsspolRubros cir
	left join
	BVQ_BACKOFFICE.EXCEPCIONES_DEP_POR_IDENTIFICAR edpi
		on edpi.edpi_numeracion=CIr.tpo_numeracion-- and CIr.cuenta='2.1.90.03'
	left join (
		select referencias=dbo.stringagg(referencia+': '+format(valor,'c','es-EC'),'; ')
		,tpo_numeracion
		,refFecha=convert(varchar,refTab.fecha,20)
		--,tpo_numeracion,fecha,fecha_original,valord=valor,referencia
		from bvq_backoffice.liquidez_referencias_table refTab
		where not (tpo_numeracion='ATX-2023-10-25-2' and valor=14586.25)
		group by tpo_numeracion, convert(varchar,refTab.fecha,20)
	) ref
	on cir.tpo_numeracion=ref.tpo_numeracion
	and convert(varchar,cir.fecha,20)=refFecha
		--and cir.ri in ('DIDENT','DIDENT02')
		--and round(debe,0)=round(ref.valor,0)
	WHERE
	cir.tipo = 'C'
	AND cir.acreedoraSinAux NOT LIKE '2%'
	AND monto IS NOT NULL
    --AND left(prefijo,1) not in ('D','R')--
	AND deterioro=0--(ipr_es_cxc = 1 or (ipr_es_cxc is null or ipr_es_cxc = 0 ) and deterioro = 0)
	AND (cir.en_espera = 1 or cir.fecha<'20240301')
	AND cir.rubro IN ('AMOUNT', 'amountcxc','INTAcc', 'PROV')