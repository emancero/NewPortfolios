﻿CREATE view [BVQ_BACKOFFICE].[ComprobanteIsspolRubros] as
	select monto=
		case rubro
			when 'amount' then amountCosto
			when 'prov' then prov
			when 'intAcc' then intAcc
			when 'valnom' then coalesce(capMonto,-montooper)
		end,*
	from bvq_backoffice.LiqIntProv e
	left join bvq_backoffice.isspol_cuenta_requerida icr on 1=0
		--e.tvl_codigo not in ('FAC','PCO') and (es_vencimiento_interes=0 and icr_codigo in ('VALNOM','MONTO') or es_vencimiento_interes=1 and icr_codigo in ('INT','PROV'))
		--or e.tvl_codigo in ('FAC','PCO')
	left join (select tiporen=153,rIdent=1,rAmount=1,rIntacc=1,rProv=1) prePerf on e.tiv_tipo_renta=prePerf.tiporen
	left--xx
	join bvq_backoffice.perfiles_isspol p on
	tvl_codigo=tippap and e.por_id=p.p_por_id --and left(p.prefijo,1) not in ('D','R')

	cross join (select tipo='D' union select tipo='C') t
	left--xx
	join (
		select vint=0, rpref='7.1.3.','amount' rubro,0 ord ,0 deterioro union
		select vint=0, rpref='7.1.2.','amount' rubro,0 ord ,0 deterioro union
		select vint=1, rpref='7.5.','intAcc',1 ,0 deterioro union
		select vint=1, rpref='7.1.5.','prov' rubro,2 ,0 deterioro union
		select vint=0, rpref='7.6.','valnom',3 ,0 deterioro union
		select vint=0, rpref='2.1.02.','amount' rubro,4 ord ,0 deterioro union
		select vint=1, rpref='2.1.02.','intAcc' rubro,4 ord ,0 deterioro union
		select vint=1, rpref='2.1.02.','prov' rubro,4 ord ,0 deterioro
		union select vint=1, rpref='7.1.3.','montooper' rubro,0 ord ,0 deterioro -- PV: Cambio
		union select vint=1, rpref='7.6.','valnom' rubro,3 ord ,0 deterioro -- PV: Cambio
		union select vint=0, rpref='D.7.5.2.','valnom' rubro,0 ord ,1 deterioro -- PV: Cambio
		union select vint=1, rpref='R.7.5.2.','prov' rubro,2 ord ,2 deterioro -- PV: Cambio
	) rub on
	(es_vencimiento_interes=vint or tippap in ('PCO','FAC'))
	and p.prefijo=rub.rpref
	and not (rubro='montooper' and montooper<>0)