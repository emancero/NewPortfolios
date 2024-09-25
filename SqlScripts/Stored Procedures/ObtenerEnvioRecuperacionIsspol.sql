CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerEnvioRecuperacionISSPOL]
	@i_fechaInicio DATETIME =NULL,
	@i_fechaFin DATETIME = NULL,
	@i_lga_id INT
AS
BEGIN
	set @i_fechaFin = dateadd(s,-1,dateadd(d,1,@i_fechaFin)) --fin de día
	exec bvq_backoffice.PrepararLiquidezCache @i_lga_id
	exec bvq_backoffice.generarcomprobanteisspol
	SELECT
			distinct ems.EMS_NOMBRE AS 'emisor', 
			tvl.tvl_nombre AS 'titulo', 
			CIS.fecha AS 'fecha',
			nombre=CIS.tpo_numeracion,--SIC.nombre,
			total_debe=sum(debe) over (partition by cis.tpo_numeracion,cis.tiv_id,cis.fecha,cis.htp_fecha_operacion),--ir.creacion_usuario,--INV.total_inversion,
			total_haber=sum(haber) over (partition by cis.tpo_numeracion,cis.tiv_id,cis.fecha,cis.htp_fecha_operacion),--ir.creacion_usuario,--INV.total_inversion,
			estado = (CASE
					when ir.estado=1 or cis.fecha<'20231001' or isr.ISR_ID is not null then 'ENVIADA'
					/*WHEN ir.estado = 0 THEN 'EN PROCESO'
					WHEN ir.estado = 1 THEN 'PROCESADA'*/
					ELSE 'NO ENVIADA'
				END),
			usuario = null,--	  sic.creacion_usuario,
			seleccionado = CONVERT(BIT, 0)
			,CIS.id_inversion inversion
			,id_estado = -1--null--(CASE  when ir.estado IS NULL THEN -1 ELSE ir.estado END)
			,tiv_fecha_vencimiento
			,CIS.idemisor
			,CIS.tiv_id
			,CIS.htp_fecha_operacion
			 ,errores=case when min(id_tipo_papel) over (partition by cis.tpo_numeracion,cis.tiv_id,cis.fecha,cis.htp_fecha_operacion) is null then 'Falta tipo de papel en Siisspolweb, ' else '' end
			 +case when min(imf_sicav) over (partition by cis.tpo_numeracion,cis.tiv_id,cis.fecha,cis.htp_fecha_operacion) is null then 'Falta fondo en Siisspolweb, ' else '' end
			 +case when min(cis_cuenta) over (partition by cis.tpo_numeracion,cis.tiv_id,cis.fecha,cis.htp_fecha_operacion) is null then 'Falta perfil en Sicav, ' else '' end
			 +case when min(id_int_conf_fondo_cuenta) over (partition by cis.tpo_numeracion,cis.tiv_id,cis.fecha,cis.htp_fecha_operacion) is null then 'Falta perfil en Siisspolweb,' else '' end
			 +case when isnull(max(ref.valor) over (partition by cis.tpo_numeracion,cis.tiv_id,cis.fecha,cis.htp_fecha_operacion),0)<=0 then 'Sin referencia' else '' end
			 ,tieneReferencia=case when isnull(max(ref.valor) over (partition by cis.tpo_numeracion,cis.tiv_id,cis.fecha,cis.htp_fecha_operacion),0)>0 then 1 else 0 end
	FROM
			--del0 bvq_backoffice.IsspolAInsertar SIC
			/*left join inversion.r_int_inversion INV 
			join inversion.r_titulo t 
			on t.id_titulo=INV.id_titulo 
			ON (SIC.idEmisor=t.id_emisor
					and (SIC.tiv_fecha_vencimiento=t.fecha_vencimiento or sic.tiv_fecha_vencimiento is null)
					and SIC.id_tipo_papel=t.id_tipo_papel
			)*/
			
			/*del0 INNER JOIN BVQ_BACKOFFICE.ComprobanteIsspol CIS 
			ON SIC.nombre = CIS.tpo_numeracion AND SIC.TIV_ID = CIS.tiv_id*/
			
			bvq_backoffice.IsspolComprobanteRecuperacion cis
			--join bvq_backoffice.titulos_portafolio tpo on cis.tpo_numeracion=tpo.tpo_numeracion --and cis.tiv_id=tpo.tiv_id
			join (select tiv_id,tiv_emisor,tiv_tipo_valor,tiv_fecha_vencimiento from bvq_administracion.titulo_valor) tiv on cis.tiv_id=tiv.tiv_id
			join bvq_administracion.emisor ems on tiv.tiv_emisor=ems.ems_id
			join bvq_administracion.tipo_valor tvl on tvl.tvl_id=tiv.tiv_tipo_valor
			/*del0
			join inversion.r_inversion INV				
				join inversion.r_inversion_titulo it on it.id_inversion = inv.id_inversion								
				join inversion.r_titulo t on it.id_titulo=t.id_titulo
			on t.id_emisor=sic.idemisor and
			t.fecha_vencimiento=sic.tiv_fecha_vencimiento
			*/
			left join [siisspolweb].siisspolweb.[inversion].[int_inversion_recuperacion] ir
			on ir.id_inversion=cis.id_inversion and datediff(d,ir.fecha_recuperacion,CIS.fecha)=0-- between 0 and 20
			left join bvq_backoffice.isspol_recuperacion isr on datediff(hh,isr_fecha,cis.fecha)=0 and isr.ISR_NUMERACION=cis.tpo_numeracion


			/*
			left join inversion.r_int_inversion_recuperacion ir
			on ir.id_inversion=inv.id_inversion and datediff(d,ir.creacion_fecha,CIS.fecha)=0
			join inversion.r_inversion_titulo it
			ON t.id_emisor = SIC.idemisor and
			t.fecha_vencimiento = SIC.tiv_fecha_vencimiento
			and it.id_titulo = t.id_titulo
			inner join inversion.r_inversion i  
			ON it.id_inversion = i.id_inversion 
			*/

			left join (
				select valor=sum(valor) over (partition by tpo_numeracion,fecha,fecha_original),tpo_numeracion,fecha,fecha_original,valord=valor,referencia
				from bvq_backoffice.liquidez_referencias_table
			) ref
			on cis.tpo_numeracion=ref.tpo_numeracion
			and datediff(hh,cis.fecha,ref.fecha)=0
				and cis.ri in ('DIDENT','DIDENT02')
				and round(debe,0)=round(ref.valor,0)

			WHERE CIS.fecha BETWEEN @i_fechaInicio AND @i_fechaFin and oper=1
			and EVP_COBRADO=1

END
