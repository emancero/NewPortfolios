CREATE PROCEDURE BVQ_BACKOFFICE.SpProvisionInversiones
--declare
	@i_fechaCorte as datetime='2024-04-30T23:59:59',
	@i_lga_id int = null
AS
BEGIN
	DECLARE @v_fechaCorte datetime
	DECLARE @v_fechaDesde datetime
	declare @v_diasMes as int = 30

	if (month(@i_fechaCorte)=2)
	begin
		set @v_diasMes = 28 --DAY(EOMONTH(@i_fechaCorte))
	end
	SET @v_fechaDesde = CONVERT(datetime,Convert(varchar,@i_fechaCorte,106) +' 00:00:00')
	SET @v_fechaCorte = CONVERT(datetime,Convert(varchar,@i_fechaCorte,106) +' 23:59:59')
 --16380,6817770833
	delete from corteslist
	insert into corteslist (c,cortenum) select @v_fechaCorte,1
	exec BVQ_BACKOFFICE.GenerarCompraVentaFlujo

	IF OBJECT_ID('tempdb..##tablaInversionesIsspol') IS NOT NULL
      DROP TABLE ##tablaInversionesIsspol

	  --   tvl_codigo as 'CODIGO',
	select
		   htp_numeracion,
		   rtrim(ltrim(ems_nombre)) as 'EMISOR',
		   --TVL_DESCRIPCION as 'CODIGO',	    
		   CASE  WHEN TVL_DESCRIPCION = 'PAPEL COMERCIAL' AND tiv_tasa_interes = 0 THEN 'PAPEL COMERCIAL CERO CUPON'
				 WHEN TVL_DESCRIPCION = 'PAPEL COMERCIAL' AND tiv_tasa_interes > 0 THEN 'PAPEL COMERCIAL CON INTERES'
				 ELSE TVL_DESCRIPCION END as 'CODIGO',
		   sum(salNewValNom) as 'CAPITAL', 	       	
	       tiv_tasa_interes/100 as 'TASA',
		   dbo.fnDias(fecha_compra , tiv_fecha_vencimiento, tiv_tipo_base)
			+case when TVL_DESCRIPCION = 'PAPEL COMERCIAL' AND tiv_tasa_interes = 0 then
					bvq_administracion.fncalcularsiguientediatrabajo(dateadd(d,-1,tiv_fecha_vencimiento),1)-1
			else 0 end
		   'PLAZO',		
		   0 as 'DIASINTERES',
		   0 as 'INTERES',
		   (SELECT DATEADD(DAY, 1 - DAY(@v_fechaDesde), @v_fechaDesde)) as 'DESDE',
		   (SELECT (CONVERT(datetime,Convert(varchar,EOMONTH(@i_fechaCorte),106) +' 23:59:59'))) as 'HASTA',
		   convert(varchar,fecha_compra,106) as 'FECHACOMPRA',		
		   coalesce(tfl_fecha_inicio_orig2,max(latest_inicio)) as 'FECHAULTIMOCUPON',
		   FECHA_INTERES = (CASE WHEN fecha_compra BETWEEN (SELECT DATEADD(DAY, 1 - DAY(@v_fechaDesde), @v_fechaDesde))   AND (SELECT EOMONTH(@v_fechaCorte))  and fecha_compra>coalesce(tfl_fecha_inicio_orig2,max(latest_inicio)) THEN fecha_compra ELSE coalesce(tfl_fecha_inicio_orig2,max(latest_inicio)) END)

		   ,tiv_fecha_vencimiento as 'FECHAVENCIMIENTO'	
		   ,sum(isnull((TPO_COMISION_BOLSA),0) + valEfeOper) valEfectivo
		   ,tfl_fecha_inicio_orig2
		   ,MAX(latest_inicio) latest_inicio
	 into ##tablaInversionesIsspol 
	 from BVQ_BACKOFFICE.portafoliocorte i
	 --join (select tfl_fecha_inicio_orig,tfl_fecha_vencimiento2,htp_tpo_id from bvq_backoffice.EventoPortafolio) e on @i_fechaCorte between tfl_fecha_inicio_orig and tfl_fecha_vencimiento2 and e.htp_tpo_id=i.httpo_id
	 where isnull(ipr_es_cxc,0)=0 and tiv_tipo_renta=153
	 group by htp_numeracion,tvl_codigo,tiv_tasa_interes,dias_al_corte,fecha_compra,ult_fecha_interes,tiv_fecha_vencimiento,ems_nombre,TVL_DESCRIPCION, tiv_tipo_base,tfl_fecha_inicio_orig2
	 HAVING sum(salNewValNom)>0
	 order by tvl_codigo
/*	 select * from ##tablaInversionesIsspol	 	 
end*/

	select
		   --htp_numeracion,
		   --FECHA_INTERES,
		   EMISOR,		  
	       CODIGO,
	       CAPITAL,
		   TASA,
		   PLAZO,
		   CASE WHEN FECHA_INTERES>HASTA THEN 0 
		        WHEN FECHA_INTERES<DESDE THEN @v_diasMes --30
				WHEN FECHA_INTERES>=DESDE THEN DATEDIFF(DAY, FECHA_INTERES,HASTA) END AS DIASINTERES,

		  isnull( 
		  CASE WHEN CODIGO = 'PAPEL COMERCIAL CERO CUPON'  AND TASA = 0 THEN (((CAPITAL - VALEFECTIVO)/PLAZO )  * ( CASE WHEN FECHA_INTERES>HASTA THEN 0 
		        WHEN FECHA_INTERES<DESDE THEN @v_diasMes --30
				ELSE DATEDIFF(DAY, FECHA_INTERES,HASTA) END))

				ELSE (
		  CAPITAL * TASA * ( CASE WHEN FECHA_INTERES>HASTA THEN 0 
		        WHEN FECHA_INTERES<DESDE THEN @v_diasMes --30
				ELSE DATEDIFF(DAY, FECHA_INTERES,HASTA) END) /360
				) 
				END


		   ,0) AS INTERES,
		   DESDE,
		   HASTA,
		   FECHACOMPRA,
		   FECHAULTIMOCUPON,
		   FECHAVENCIMIENTO
		   ,VALEFECTIVO AS 'VALOR EFECTIVO'
	from ##tablaInversionesIsspol
END