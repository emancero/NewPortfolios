create view BVQ_BACKOFFICE.TotalRecuperacionesView as
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
	FROM BVQ_BACKOFFICE.ComprobanteIsspolRubros cir
	WHERE cir.rubro IN ('AMOUNT', 'amountcxc','INTAcc', 'PROV')
	AND monto IS NOT NULL
	AND cir.acreedoraSinAux NOT LIKE '2%'
	AND cir.tipo = 'C'
	AND (cir.en_espera = 1 or cir.fecha<'20240301')
    --AND left(prefijo,1) not in ('D','R')--
	AND deterioro=0--(ipr_es_cxc = 1 or (ipr_es_cxc is null or ipr_es_cxc = 0 ) and deterioro = 0)