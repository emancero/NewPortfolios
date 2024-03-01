CREATE PROCEDURE BVQ_BACKOFFICE.SpProvisionInversionesView
(
	@i_fechaCorte as datetime,
	@i_lga_id int
)
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
				--nombre_etiqueta = doc.etiqueta + '-'  + seg.nombre_contabilidad
				 nombre_etiqueta = (
        CASE 
            WHEN COALESCE(doc.etiqueta, '') = '' THEN 'Interes - ' + seg.nombre_contabilidad
            ELSE doc.etiqueta + '-' + seg.nombre_contabilidad
        END
    )

				  ,SUM(pfc.sal) DISTRIBUCION
				  ,/*SUM(case when pfc.tvl_codigo in ('FAC','PCO') and pfc.tiv_tipo_base=355 and pfc.latest_inicio=pfc.fecha_compra 
						then datediff(d,pfc.tiv_fecha_vencimiento,pfc.tfcorte) else pfc.dias_al_corte end * 
					CASE WHEN pfc.TVL_CODIGO in ('FAC','PCO','PACTO') 
						THEN (
							case when pfc.TVL_CODIGO in ('PCO') 
								then pfc.sal * pfc.htp_precio_compra/100.0 
								else pfc.valefe end + 
							CASE WHEN pfc.TPO_INTERVINIENTES LIKE 'Capital Ventura%' 
								THEN pfc.TPO_INTERES_TRANSCURRIDO ELSE 0 END
								) * pfc.HTP_RENDIMIENTO/100.0/360.0
					ELSE (pfc.sal-isnull(pfc.TPO_VALNOM_ANTERIOR,0)) * pfc.TIV_TASA_INTERES /100.0/360.0
					END - isnull(pfc.TPO_ABONO_INTERES,0)) TOTAL_PROVISION*/
					/*sum(isnull( sal * tiv_tasa_interes/100.0 * ( CASE WHEN ult_fecha_interes>EOMONTH(@v_fechaCorte) THEN 0 
						WHEN ult_fecha_interes<DATEADD(DAY, 1 - DAY(@v_fechaCorte), @v_fechaCorte) THEN 30
						ELSE DATEDIFF(DAY, ult_fecha_interes,EOMONTH(@v_fechaCorte)) END) /360
					,0)
					) AS TOTAL_PROVISION
					,*/
					sum(
				  isnull( 
				  CASE WHEN pfc.tvl_codigo = 'PCO'  AND TASA = 0 THEN (((CAPITAL - VALEFECTIVO)/PLAZO )  * ( CASE WHEN FECHA_INTERES>HASTA THEN 0 
						WHEN FECHA_INTERES<DESDE THEN @v_diasMes --30
						ELSE DATEDIFF(DAY, FECHA_INTERES,HASTA) END))

						ELSE (
				  CAPITAL * TASA * ( CASE WHEN FECHA_INTERES>HASTA THEN 0 
						WHEN FECHA_INTERES<DESDE THEN @v_diasMes --30
						ELSE DATEDIFF(DAY, FECHA_INTERES,HASTA) END) /360
						) 
						END


				   ,0)) AS TOTAL_PROVISION
				--,htp_numeracion
			  FROM (
					--select *  from BVQ_BACKOFFICE.PortafolioCorte
					select *,
				   tiv_tasa_interes/100 as 'TASA'	,		 
				   dbo.fnDias(fecha_compra , tiv_fecha_vencimiento, tiv_tipo_base) 'PLAZO',		
				   0 as 'DIASINTERES',
				   0 as 'INTERES',
				   (SELECT DATEADD(DAY, 1 - DAY(@v_fechaDesde), @v_fechaDesde)) as 'DESDE',
				   (SELECT (CONVERT(datetime,Convert(varchar,EOMONTH(@i_fechaCorte),106) +' 23:59:59'))) as 'HASTA',
				   convert(varchar,fecha_compra,106) as 'FECHACOMPRA',		
				   tfl_fecha_inicio_orig as 'FECHAULTIMOCUPON',
				   FECHA_INTERES = (CASE WHEN fecha_compra BETWEEN (SELECT DATEADD(DAY, 1 - DAY(@v_fechaDesde), @v_fechaDesde))   AND (SELECT EOMONTH(@v_fechaCorte))  THEN fecha_compra ELSE tfl_fecha_inicio_orig END)

				   ,convert(varchar,tiv_fecha_vencimiento,106) as 'FECHAVENCIMIENTO'
				   ,capital=sal
				   ,valefectivo=valor_efectivo
				   from BVQ_BACKOFFICE.inversionesisspol i--PortafolioCorte
				   join (select tfl_fecha_inicio_orig,tfl_fecha_vencimiento2,htp_tpo_id from bvq_backoffice.EventoPortafolio) e on @i_fechaCorte between tfl_fecha_inicio_orig and tfl_fecha_vencimiento2 and e.htp_tpo_id=i.httpo_id
				   where sal>0

				)pfc INNER JOIN BVQ_ADMINISTRACION.TIPO_VALOR tvd
				on tvd.TVL_CODIGO = pfc.tvl_codigo AND tvd.TVL_CODIGO IN ('ACC','BE','CD','CI','CT','DER','CDP','FAC','OBL','OCA','PCO','REP','VCC','PAC')
				INNER JOIN Sicav.BVQ_BACKOFFICE.LISTA_ITEMS_CONTABILIDAD DOC
				ON pfc.tvl_codigo  = DOC.CODIGO AND DOC.ESTADO='A' AND DOC.TIPO = 'Documento' 
				inner join Sicav.BVQ_BACKOFFICE.LISTA_ITEMS_CONTABILIDAD seg
				on seg.nombre = pfc.por_codigo
				where isnull(ipr_es_cxc,0)=0
			  GROUP BY doc.orden, seg.orden,DOC.Codigo, seg.por_id, DOC.NOMBRE, doc.etiqueta, seg.nombre_contabilidad,pfc.TVL_CODIGO, DOC.NOMBRE_CONTABILIDAD,tvd.TVL_NOMBRE, pfc.sector_general, pfc.por_codigo, seg.nombre--,htp_numeracion
			 -- order by doc.orden
	  
			  union

		 select doc.orden as orden_doc, 
			seg.orden as orden_seg,
			DOC.Codigo as Codigo1,
			seg.por_id as por_id1,
			TITULO = (CASE doc.Nombre_Contabilidad WHEN  NULL THEN DOC.NOMBRE 
										WHEN '' THEN doC.NOMBRE 
										ELSE  doc.Nombre_Contabilidad END),
			--nombre_etiqueta = DOC.ETIQUETA + '-' + seg.Nombre_Contabilidad,
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
		 --order by doc.orden asc, seg.orden asc
		 )
		 select orden_doc, orden_seg, Codigo1, por_id1, titulo, nombre_etiqueta,sum(distribucion)  as distribucion, sum(TOTAL_PROVISION) provision--,htp_numeracion
		 into #CTE
		 from cte_provision
		 group by orden_doc, orden_seg, Codigo1, por_id1, titulo, nombre_etiqueta--,htp_numeracion
		 --order by orden_doc asc, orden_seg asc 


		--SELECT cte.orden_doc, cte.orden_seg, per1.acreedora,  per2.acreedora, cte.TITULO,cte.nombre_etiqueta, cte.distribucion, cte.provision
		SELECT cte.orden_doc, 
		cte.orden_seg, 
		(per1.acreedora) as cuenta1,  
		(per2.acreedora) as cuenta2,
		cte.TITULO,
		cte.nombre_etiqueta, 
		--nombre_etiqueta = ( CASE
		--					 WHEN per1.acreedora IS NULL OR per2.acreedora IS NULL THEN  'Intereses ' + cte.nombre_etiqueta ELSE cte.nombre_etiqueta END),
		cte.distribucion, 
		cte.provision
		--,htp_numeracion
		FROM #CTE cte
		LEFT JOIN BVQ_BACKOFFICE.PERFILES_ISSPOL per1
		on per1.tipPap = cte.Codigo1 and per1.p_por_id = cte.por_id1 and per1.prefijo='7.1.5.'--acreedora = '7.1.5.90.90'
		LEFT JOIN BVQ_BACKOFFICE.PERFILES_ISSPOL per2
		on per2.tipPap = cte.Codigo1 and per2.p_por_id = cte.por_id1 and per2.prefijo = '7.5.'
		--group by cte.orden_doc, cte.orden_seg, per1.acreedora,  per2.acreedora, cte.TITULO,cte.nombre_etiqueta, cte.distribucion, cte.provision
		where RTRIM(cte.TITULO) not IN ('ACCIONES', 'CUOTAS DE PARTICIPACIÓN                 ')
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
                doc.NOMBRE IN ('ACCIONES', 'CUOTAS DE PARTICIPACIÓN                 ') OR
                doc.Nombre_Contabilidad IN ('ACCIONES', 'CUOTAS DE PARTICIPACIÓN                 ')
            )
       )
		 order by orden asc

END