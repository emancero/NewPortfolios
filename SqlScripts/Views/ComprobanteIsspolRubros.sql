create view [BVQ_BACKOFFICE].[ComprobanteIsspolRubros] as
	select monto=
		case rubro
			when 'amount' then amountCosto
			when 'amountcxc' then amountCosto
			when 'prov' then prov
				+case when hist_fecha_compra>tfl_fecha_inicio_orig then isnull(itrans,0) else 0 end
			when 'intAcc' then intAcc
				+case when ipr_es_cxc=1 then isnull(ufo_uso_fondos,0) else 0 end
			when 'valnom' then coalesce(case when e.evp_abono=1 and e.es_vencimiento_interes=0 then e.vep_valor_efectivo end,capMonto,-montooper)
		end
		,forced_por_id=case when p.prefijo='2.1.02.'
			--títulos reclasificados
			and ITRFON.RECLASIFICADO_A=p.p_por_id
		then
			p.p_por_id
		end
		,*
	from bvq_backoffice.LiqIntProv e
	left join bvq_backoffice.isspol_cuenta_requerida icr on 1=0
		--e.tvl_codigo not in ('FAC','PCO') and (es_vencimiento_interes=0 and icr_codigo in ('VALNOM','MONTO') or es_vencimiento_interes=1 and icr_codigo in ('INT','PROV'))
		--or e.tvl_codigo in ('FAC','PCO')
	left join (select tiporen=153,rIdent=1,rAmount=1,rIntacc=1,rProv=1) prePerf on e.tiv_tipo_renta=prePerf.tiporen

	--títulos reclasificados
	left join
	(
		select FON_NUMERACION, ITR.RECLASIFICADO_A from
		BVQ_BACKOFFICE.ISSPOL_TITULOS_RECLASIFICADOS ITR
		join BVQ_BACKOFFICE.FONDO ITRFON on ITR.FON_ID=ITRFON.FON_ID
	) ITRFON
	on ITRFON.FON_NUMERACION=e.tpo_numeracion

	left--xx
	join bvq_backoffice.perfiles_isspol p
	on
		tvl_codigo=tippap
		and (
			e.por_id=p.p_por_id or p.prefijo='2.1.02.'
			--títulos reclasificados
			and ITRFON.RECLASIFICADO_A=p.p_por_id--tpo_numeracion like 'FEC-%'
		)
	cross join (select tipo='D' union select tipo='C') t
	left--xx
	join (
		select vint=0, rpref='7.1.3.','amount' rubro,0 ord ,0 deterioro, 0 rcxc union --único exclusivo para vigentes
		select vint=0, rpref='7.1.2.','amount' rubro,0 ord ,0 deterioro, null rcxc union
		select vint=0, rpref='A7.1.5.','amountcxc' rubro,0 ord ,0 deterioro, 1 rcxc union --uno de dos exclusivos para cxc
		select vint=1, rpref='7.5.','intAcc',1 ,0 deterioro, null rcxc union
		select vint=1, rpref='7.1.5.','prov' rubro,2 ,0 deterioro, null rcxc union
		select vint=0, rpref='7.6.','valnom',3 ,0 deterioro, null rcxc union
		select vint=0, rpref='2.1.02.','amount' rubro,4 ord ,0 deterioro, null rcxc union
		select vint=1, rpref='2.1.02.','intAcc' rubro,4 ord ,0 deterioro, null rcxc union
		select vint=1, rpref='2.1.02.','prov' rubro,4 ord ,0 deterioro, null rcxc union
		select vint=1, rpref='7.1.3.','montooper' rubro,0 ord ,0 deterioro, 0 rcxc union
		select vint=1, rpref='A7.1.5.','amountcxc' rubro,0 ord ,0 deterioro, 1 rcxc union --dos de dos exclusivos para cxc

		--select vint=1, rpref='7.6.','valnom' rubro,3 ord ,0 deterioro, null rcxc union
		select vint=0, rpref='D.7.5.2.','valnom' rubro,0 ord ,1 deterioro, null rcxc union
		select vint=1, rpref='R.7.5.2.','prov' rubro,2 ord ,1 deterioro, null rcxc
	) rub on
	(es_vencimiento_interes=vint /*or tippap in ('PCO','FAC')*/)
	and p.prefijo=rub.rpref
	--empatar con vigente (0 o null) o cxc (1)
	and (rub.rcxc is null or rub.rcxc=isnull(ipr_es_cxc,0) and rub.rcxc=p.cxc)
	and not (rubro='montooper' and montooper<>0 and isnull(evp_abono,0)=0)