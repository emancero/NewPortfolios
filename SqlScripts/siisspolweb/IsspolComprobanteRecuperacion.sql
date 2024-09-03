CREATE view [BVQ_BACKOFFICE].[IsspolComprobanteRecuperacion] as
			select
			--id_int_conf_fondo_cuenta,id_cuenta,debe,haber,descripcion,

			cis.ri,codigo_configuracion=r.sir_codigo_configuracion,real_codigo_configuracion=f.codigo_configuracion,cis.rubro
			,id_int_conf_fondo_cuenta=max(f.id_int_conf_fondo_cuenta)
			,id_cuenta=max(fi.id_cuenta)/*case when codigo_configuracion<>'DIDENT' or codigo_configuracion is null then fi.id_cuenta end)*/
			, oper,cis.fecha,cis.tpo_numeracion,i.id_inversion
			,debe=sum(debe),haber=sum(haber)
			,tipo_rubro_movimiento=r.SIR_TIPO_RUBRO_MOVIMIENTO
			,cis.tiv_id--cis.*--tiv_id,cis.htp_tpo_id
			,idemisor,pju_identificacion
			--select distinct(cu.id_cuenta),  tp.id_tipo_papel,  cu.descripcion as fondo, t.descripcion as tipoPapel, 'CUXP', 'CUXP'+VCT.tipoCodigo, 'C'
			,tp.id_tipo_papel
			,descripcion=max(b.descripcion)
			,ems.ems_nombre
			,codigo_lista_rubro=max(f.codigo_lista_rubro)--case when codigo_configuracion<>'DIDENT' or codigo_configuracion is null then f.codigo_lista_rubro end--f.codigo_lista_rubro--f.codigo_lista_rubro
			,codigo_papel=tp.codigo
			,cis.tippap
			,ipr.ipr_es_cxc
			,por_id=case when codigo_configuracion<>'DIDENT' or codigo_configuracion is null then tpo.por_id end--tpo.por_id
			/*,i.id_inversion--tiv.tiv_emisor,tiv_subtipo,tpo.tpo_acta,tp.id_tipo_papel,idEmisor,imf_sis--,**/
			,coalesce(edpi.EDPI_CUENTA,cis.cuenta) cis_cuenta
			,coalesce(edpi.EDPI_AUX,cis.aux) cis_aux
			,r.sir_codigo_configuracion
			,rubroOrd = MAX(cis.rubroOrd)
			,tfl_periodo=max(tfl_periodo)
			,htp_fecha_operacion = max(htp_fecha_operacion)
			,deterioro
			,tipo=max(cis.tipo)
			,por_ord=max(por_ord)
			,imf_sicav=max(imf_sicav)
			,EVP_COSTAS_JUDICIALES_REFERENCIA=max(EVP_COSTAS_JUDICIALES_REFERENCIA)
			,EVP_COBRADO=max(EVP_COBRADO)
			from BVQ_BACKOFFICE.Comprobante_Isspol CIS
			--excepción a la cuenta de depósitos por indentificar
			left join BVQ_BACKOFFICE.EXCEPCIONES_DEP_POR_IDENTIFICAR edpi
				on edpi.edpi_numeracion=CIS.tpo_numeracion and CIS.cuenta='2.1.90.03'

			join (select tiv_id,tiv_subtipo,tiv_emisor,tiv_tipo_renta from bvq_administracion.titulo_valor) tiv on cis.tiv_id=tiv.tiv_id

			join bvq_backoffice.titulos_portafolio tpo on cis.htp_tpo_id=tpo.tpo_id
			left join bvq_backoffice.isspol_progs ipr on ipr.ipr_nombre_prog=tpo.tpo_prog
			left join bvq_administracion.isspol_mapa_tipo_papel imtp on imtp.imtp_sicav=cis.tippap--tvl_codigo

			left join [siisspolweb].siisspolweb.inversion.tipo_papel tp on tp.codigo=coalesce(
				case when tvl_codigo='PCO' and tiv_subtipo=3 then 'PCI'
				when tvl_codigo='ACC' and tiv_subtipo=2 then 'APR'
				when tvl_codigo='BE' and tpo_acta like '2[0-9][0-9][0-9]' then 'BG' end,
				imtp_sis,cis.tippap) and tp.estado='A'

			join bvq_administracion.emisor ems on tiv_emisor=ems_id
			left join bvq_administracion.persona_juridica pju on pju.pju_id=ems.pju_id

			left join [siisspolweb].siisspolweb.inversion.vis_emisor_calificacion e on e.identificacion=pju_identificacion
			join bvq_administracion.isspol_mapa_fondos imf on imf.imf_sicav=coalesce(CIS.forced_por_id,tpo.por_id)

			--unión con la inversión
			left join [siisspolweb].siisspolweb.[inversion].[inversion] i				
				join [siisspolweb].siisspolweb.[inversion].[inversion_titulo] it on it.id_inversion = i.id_inversion and it.estado='L'								
				join [siisspolweb].siisspolweb.[inversion].[titulo] t on it.id_titulo=t.id_titulo
			on t.id_emisor=e.idemisor and
			(
				(
						t.fecha_vencimiento=cis.tiv_fecha_vencimiento
					and t.fecha_emision=cis.tiv_fecha_emision
					or (tiv_tipo_renta=154 and datediff(d,cis.fecha_compra,i.fecha)=0 and cis.tippap<>'FI')
					or (cis.tippap='FI' and i.fecha=cis.tiv_fecha_emision)
				)
				or cis.tpo_numeracion='SGE-2023-03-31' and i.id_inversion=175
			) and i.id_inversion not in (229,230,231,233,234,235,246,115)
			--fin unión con la inversión

			join [siisspolweb].siisspolweb.[inversion].[fondo_inversion] fi 
			on fi.id_seguro_tipo = imf.imf_sis--pct.id_seguro_tipo 
			join [siisspolweb].siisspolweb.[banco].[cuenta] b on b.id_cuenta=fi.id_cuenta

			join BVQ_BACKOFFICE.SIISSPOLWEB_RUBROS r
			on (
				   r.sir_codigo_configuracion='inte' and rubro='intAcc' --cis.icr_codigo='INT'--
				or r.sir_codigo_configuracion='rend' and cis.rubro='prov'--icr_codigo='PROV'--cis.rubro='prov'
				--or r.codigo_configuracion='rend' and cis.rubro='amount'--icr_codigo='PROV'--cis.rubro='prov'
				--or r.codigo_configuracion='cuxc' and cis.rubro='valnom'--icr_codigo='PROV'--cis.rubro='prov'
				--or r.codigo_configuracion='cuxp' and cis.rubro='valnom'--icr_codigo='PROV'--cis.rubro='prov'
				or r.sir_codigo_configuracion='valnom' and cis.rubro='valnom' and debe>0
				or r.sir_codigo_configuracion='cvalnom' and cis.rubro='valnom' and haber>0
				or r.sir_codigo_configuracion='valefe' and cis.rubro='amount' and isnull(ipr.ipr_es_cxc,0)=0
				or r.sir_codigo_configuracion='VALEFECXC' and cis.rubro='amountcxc' and ipr.ipr_es_cxc=1
				or r.sir_codigo_configuracion='DETERIOROXC' and cis.rubro='amountcxc' and ipr.ipr_es_cxc=1 and debe>0
				or r.sir_codigo_configuracion='DETERIOROR' and cis.rubro='amountcxc' and ipr.ipr_es_cxc=1 and haber>0 and cis.cuenta like '7.5.2.%'
				or r.sir_codigo_configuracion='DETERIOROIC' and cis.rubro='amount' and ipr.ipr_es_cxc=1 and debe>0
				or r.sir_codigo_configuracion='DETERIOROIR' and cis.rubro='amount' and ipr.ipr_es_cxc=1 and haber>0
				or r.sir_codigo_configuracion='CUXC02' and ipr.ipr_es_cxc=1 and ri='CUXC' and forced_por_id is not null--and cis.tpo_numeracion not like 'FEC-%'-->0
				or r.sir_codigo_configuracion='CUXP02' and ipr.ipr_es_cxc=1 and ri='CUXP' and forced_por_id is not null--and cis.tpo_numeracion not like 'FEC-%'--and haber>0

				or r.sir_codigo_configuracion=ri and not (ri='DIDENT' and edpi_id is not null or forced_por_id is not null) 
				or r.sir_codigo_configuracion='DIDENT02' and edpi_id is not null
				or r.sir_codigo_configuracion='COSTAS' and cis.rubro='COSTAS'--icr_codigo='PROV'--cis.rubro='prov'
			)
			and (cis.cuenta not in ('7.1.5.90.99','7.5.2.04.05','7.5.2.04.09') or r.sir_codigo_configuracion like 'DETERIORO%' or r.sir_codigo_configuracion='inte')
			and not (cis.cuenta like '7.6.%' and r.sir_codigo_configuracion like 'DETERIORO%')
			left join [siisspolweb].siisspolweb.inversion.int_conf_fondo_cuenta f 
			on
			r.sir_codigo_configuracion=f.codigo_configuracion
			and f.id_tipo_papel=tp.id_tipo_papel and f.id_fondo=fi.id_cuenta 
			/*and (
				r.sir_codigo_configuracion not like '%02' and tipo_rubro_movimiento='D' and debe>0 or tipo_rubro_movimiento='C' and haber>0
				or r.sir_codigo_configuracion like '%02' and tipo_rubro_movimiento='C' and debe>0 or tipo_rubro_movimiento='D' and haber>0
			)*/--fi.id_cuenta
			--select ri,rubro,* from bvq_backoffice.comprobanteisspol cis
			where oper=1
			group by
			--and f.codigo_configuracion is not null
			--and cis.fecha='20231129' and cis.tpo_numeracion='CEA-2022-12-27-3'
			--and cis.fecha='20230629' and cis.tpo_numeracion='ABO-2023-06-26-10' and i.id_inversion=225--datediff(m,'20230901',cis.fecha)=0
			cis.ri

			,r.sir_codigo_configuracion--
			
			,f.codigo_configuracion,cis.rubro
			--,f.id_int_conf_fondo_cuenta
			--,fi.id_cuenta
			--,case when codigo_configuracion<>'DIDENT' or codigo_configuracion is null then fi.id_cuenta end
			, oper,cis.fecha,cis.tpo_numeracion,i.id_inversion
			--,debe,haber

			,r.SIR_TIPO_RUBRO_MOVIMIENTO --tipo_rubro_movimiento
			
			,cis.tiv_id--cis.*--tiv_id,cis.htp_tpo_id
			,idemisor,pju_identificacion
			--select distinct(cu.id_cuenta),  tp.id_tipo_papel,  cu.descripcion as fondo, t.descripcion as tipoPapel, 'CUXP', 'CUXP'+VCT.tipoCodigo, 'C'
			,tp.id_tipo_papel
			--,b.descripcion
			,ems.ems_nombre
			,case when codigo_configuracion<>'DIDENT' or codigo_configuracion is null then f.codigo_lista_rubro end--f.codigo_lista_rubro

			,tp.codigo--

			,cis.tippap
			,ipr.ipr_es_cxc
			,case when codigo_configuracion<>'DIDENT' or codigo_configuracion is null then tpo.por_id end--tpo.por_id
			,coalesce(edpi.EDPI_CUENTA,cis.cuenta)
			,coalesce(edpi.EDPI_AUX,cis.aux)
			,deterioro
			,htp_fecha_operacion
			having sum(debe)>0 or sum(haber)>0
			--having cis.tpo_numeracion='EDE-2019-02-26' and cis.fecha='20231020'
