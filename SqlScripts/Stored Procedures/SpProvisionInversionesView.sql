CREATE PROCEDURE BVQ_BACKOFFICE.SpProvisionInversionesView
	@i_fechaCorte as datetime,
	@i_lga_id int
AS
BEGIN
	DECLARE @v_fechaCorte datetime
	declare @v_fechaDesde datetime
	declare @v_diasMes as int = 30

	if (month(@i_fechaCorte)=2)
	begin
		set @v_diasMes = 28 --DAY(EOMONTH(@i_fechaCorte))
	end

	
	SET @v_fechaCorte = CONVERT(datetime,Convert(varchar,@i_fechaCorte,106) +' 23:59:59')
	SET @v_fechaDesde = CONVERT(datetime,Convert(varchar,@i_fechaCorte,106) +' 00:00:00')

	delete from corteslist
	insert into corteslist (c,cortenum) select @v_fechaCorte,1
	exec BVQ_BACKOFFICE.GenerarCompraVentaFlujo
    
	
	; with  cte_provision as (
		SELECT 		doc.orden as orden_doc, 
			seg.orden as orden_seg,
			DOC.Codigo as Codigo1,
			seg.por_id as por_id1,
			TITULO = CASE doc.Nombre_Contabilidad WHEN  NULL THEN DOC.NOMBRE 
										WHEN '' THEN doC.NOMBRE 
										ELSE  doc.Nombre_Contabilidad END,
			nombre_etiqueta =
				CASE 
					WHEN COALESCE(doc.etiqueta, '') = '' THEN 'Interes - ' + seg.nombre_contabilidad
					ELSE doc.etiqueta + '-' + seg.nombre_contabilidad
				END

			,SUM(pfc.salNewValNom) DISTRIBUCION
			,sum(
			isnull(
			CASE WHEN pfc.tvl_codigo = 'PCO'  AND TASA = 0 or pfc.tvl_codigo not in ('PCO') and pfc.tiv_subtipo=3 THEN (((CAPITAL - VALEFECTIVO)/PLAZO )  * ( CASE WHEN FECHA_INTERES>HASTA THEN 0
				WHEN FECHA_INTERES<DESDE THEN @v_diasMes --30
				ELSE DATEDIFF(DAY, FECHA_INTERES,HASTA) END))
				ELSE (
					CAPITAL * TASA * ( CASE WHEN FECHA_INTERES>HASTA THEN 0 
					WHEN FECHA_INTERES<DESDE THEN @v_diasMes --30
					ELSE DATEDIFF(DAY, FECHA_INTERES,HASTA) END) /360
				) 
				END
			,0)) AS TOTAL_PROVISION
			FROM (
				select *,
				tiv_tasa_interes/100 as 'TASA',		 
				dbo.fnDias(fecha_compra , tiv_fecha_vencimiento, tiv_tipo_base)
				+case when TVL_DESCRIPCION = 'PAPEL COMERCIAL' AND tiv_tasa_interes = 0
				or tvl_codigo not in ('PCO') and tiv_subtipo=3
				then
						bvq_administracion.fncalcularsiguientediatrabajo(dateadd(d,-1,tiv_fecha_vencimiento),1)-1
				else 0 end
				'PLAZO',		
				0 as 'DIASINTERES',
				0 as 'INTERES',
				(SELECT DATEADD(DAY, 1 - DAY(@v_fechaDesde), @v_fechaDesde)) as 'DESDE',
				(SELECT (CONVERT(datetime,Convert(varchar,EOMONTH(@i_fechaCorte),106) +' 23:59:59'))) as 'HASTA',
				convert(varchar,fecha_compra,106) as 'FECHACOMPRA',		
				coalesce(i.tfl_fecha_inicio_orig2,i.latest_inicio) as 'FECHAULTIMOCUPON',
				FECHA_INTERES = (CASE WHEN fecha_compra BETWEEN (SELECT DATEADD(DAY, 1 - DAY(@v_fechaDesde), @v_fechaDesde))   AND (SELECT EOMONTH(@v_fechaCorte)) and fecha_compra>coalesce(i.tfl_fecha_inicio_orig2,i.latest_inicio) THEN fecha_compra ELSE coalesce(i.tfl_fecha_inicio_orig2,i.latest_inicio) END)

				,convert(varchar,tiv_fecha_vencimiento,106) as 'FECHAVENCIMIENTO'
				,capital=salNewValNom
				,valefectivo=isnull((TPO_COMISION_BOLSA),0) + valEfeOper

				--costo amortizado ---------------------------------------------------------------------------------
				,costoAmortizado=0
				--(
				--		select
				--		valpre=sum(
				--			(cvf.amortizacion+cvf.iamortizacion)/
				--			power
				--			(
				--					1
				--					+
				--					cvf.TIR
				--				,
				--					case when cvf.tiv_tipo_base<>354 then 1 else cvf.tiv_frecuencia end
				--					*
				--					((
				--						dbo.fndias(c,cvf.tfl_fin,cvf.tiv_tipo_base)-
				--						case when month(cvf.c)=2 and day(c) in (28,29) then 30-day(cvf.c) else 0 end --ajuste NASD
				--					)/360.0)
				--			)
				--		)
						--adicional para cálculo de intereses transcurridos
						--+power(1+max(tir),--TIR,
						--			case when i.tiv_tipo_base<>354 then 1 else max(tiv_frecuencia) end
						--			*
						--			((
						--				dbo.fndias(coalesce(i.tfl_fecha_inicio_orig2,i.latest_inicio),tfcorte,i.tiv_tipo_base)-
						--				case when month(coalesce(i.tfl_fecha_inicio_orig2,i.latest_inicio))=2 and day(coalesce(i.tfl_fecha_inicio_orig2,i.latest_inicio)) in (28,29) then 30-day(coalesce(i.tfl_fecha_inicio_orig2,i.latest_inicio)) else 0 end --ajuste NASD
						--			)/360.0)
						--)
				--		from(
				--			select
				--			 tfl_inicio=tfl_fecha_inicio_orig
				--			,tfl_fin=tfl_fecha_vencimiento2

				--			,cvf.tfl_capital
				--			,cvf.htp_fecha_operacion
				--			,cvf.tiv_tipo_base
				--			,cvf.tiv_frecuencia
				--			,cvf.amortizacion
				--			,cvf.iamortizacion

				--			,TIR=case when cvf.tiv_tipo_base<>354 then
				--				cvf.htp_tir
				--			else
				--				isnull(cvf.htp_rendimiento_retorno,cvf.itasa_interes)
				--			end
				--			/100.0
				--			/case when cvf.tfl_capital=0 then 1 else case when cvf.tiv_tipo_base<>354 then 1 else cvf.tiv_frecuencia end end
				--			,c=coalesce(i.tfl_fecha_inicio_orig2,i.latest_inicio)
				--			from 
				--			bvq_backoffice.compraventaflujo
				--			cvf
				--			where cvf.htp_tpo_id=i.httpo_id
				--			and datediff(d,coalesce(i.tfl_fecha_inicio_orig2,i.latest_inicio),tfl_fecha_vencimiento)>0
				--		) cvf where tfl_capital>0-- where tfl_fecha_vencimiento>=c
				--		--valoraba títulos que todavía no estaban comprados
				--		and htp_fecha_operacion<=c
				--)
				--FIN costo amortizado ------------------------------------------------------------------------------------------

				from BVQ_BACKOFFICE.PortafolioCorte i--PortafolioCorte
				where salNewValNom>0

			)pfc
			INNER JOIN BVQ_ADMINISTRACION.TIPO_VALOR tvd
				on tvd.TVL_CODIGO = pfc.tvl_codigo AND tvd.TVL_CODIGO IN ('ACC','BE','CD','CI','CT','DER','CDP','FAC','OBL','OCA','PCO','REP','VCC','PAC','VTP')
			INNER JOIN BVQ_BACKOFFICE.LISTA_ITEMS_CONTABILIDAD DOC
				ON pfc.tvl_codigo  = DOC.CODIGO AND DOC.ESTADO='A' AND DOC.TIPO = 'Documento' 
			inner join BVQ_BACKOFFICE.LISTA_ITEMS_CONTABILIDAD seg
				on seg.nombre = pfc.por_codigo
			where isnull(ipr_es_cxc,0)=0
			GROUP BY doc.orden, seg.orden,DOC.Codigo, seg.por_id, DOC.NOMBRE, doc.etiqueta, seg.nombre_contabilidad,pfc.TVL_CODIGO, DOC.NOMBRE_CONTABILIDAD,tvd.TVL_NOMBRE, pfc.sector_general, pfc.por_codigo, seg.nombre--,htp_numeracion
	  
			  union

		 select doc.orden as orden_doc, 
			seg.orden as orden_seg,
			DOC.Codigo as Codigo1,
			seg.por_id as por_id1,
			TITULO = (CASE doc.Nombre_Contabilidad WHEN  NULL THEN DOC.NOMBRE 
										WHEN '' THEN doC.NOMBRE 
										ELSE  doc.Nombre_Contabilidad END),
			nombre_etiqueta = (
        CASE 
            WHEN COALESCE(doc.etiqueta, '') = '' THEN 'Interes - ' + seg.nombre_contabilidad
            ELSE doc.etiqueta + '-' + seg.nombre_contabilidad
        END
    ),
			DISTRIBUCION = 0,
			PROVISION = 0
			--,null
		 from Sicav.BVQ_BACKOFFICE.LISTA_ITEMS_CONTABILIDAD doc INNER JOIN Sicav.BVQ_BACKOFFICE.LISTA_ITEMS_CONTABILIDAD seg
		 ON seg.estado = doc.estado  AND doc.tipo = 'Documento'  and seg.tipo='Seguro'
		 WHERE seg.estado='A' AND DOC.estado='A'
		 )
		 select orden_doc, orden_seg, Codigo1, por_id1, titulo, nombre_etiqueta,sum(distribucion)  as distribucion, sum(TOTAL_PROVISION) provision--,htp_numeracion
		 into #CTE
		 from cte_provision
		 group by orden_doc, orden_seg, Codigo1, por_id1, titulo, nombre_etiqueta--,htp_numeracion


		SELECT cte.orden_doc, 
		cte.orden_seg,
		(per1.acreedora) as cuenta1,  
		(per2.acreedora) as cuenta2,
		cte.TITULO,
		cte.nombre_etiqueta, 
		cte.distribucion, 
		cte.provision
		FROM #CTE cte
		LEFT JOIN BVQ_BACKOFFICE.PERFILES_ISSPOL per1
		on per1.tipPap = cte.Codigo1 and per1.p_por_id = cte.por_id1 and per1.prefijo='7.1.5.'--acreedora = '7.1.5.90.90'
		LEFT JOIN BVQ_BACKOFFICE.PERFILES_ISSPOL per2
		on per2.tipPap = cte.Codigo1 and per2.p_por_id = cte.por_id1 and per2.prefijo = '7.5.'
		where RTRIM(cte.TITULO) not IN ('ACCIONES', 'CUOTAS DE PARTICIPACIÓN                 ','VALORES DE TITULARIZACIÓN DE PARTICIPACIÓN')
		group by cte.orden_doc, cte.orden_seg, per1.acreedora,  per2.acreedora, per1.acreedoraAux, per2.acreedoraAux, cte.TITULO,cte.nombre_etiqueta, cte.distribucion, cte.provision--,htp_numeracion
		order by orden_doc asc, orden_seg asc 

		select orden, TITULO = (CASE doc.Nombre_Contabilidad WHEN  NULL THEN DOC.NOMBRE 
										WHEN '' THEN doC.NOMBRE 
										ELSE  doc.Nombre_Contabilidad END) 
		 from Sicav.BVQ_BACKOFFICE.LISTA_ITEMS_CONTABILIDAD doc
		 where estado = 'A' and tipo = 'Documento'
		  AND NOT (
            (doc.Nombre_Contabilidad IS NULL OR doc.Nombre_Contabilidad = '')
            AND (
                doc.NOMBRE IN ('ACCIONES', 'CUOTAS DE PARTICIPACIÓN                 ','VALORES DE TITULARIZACIÓN DE PARTICIPACIÓN') OR
             doc.Nombre_Contabilidad IN ('ACCIONES', 'CUOTAS DE PARTICIPACIÓN                 ','VALORES DE TITULARIZACIÓN DE PARTICIPACIÓN')
            )
       )
		 order by orden asc

END
