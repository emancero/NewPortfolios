create procedure bvq_backoffice.ObtenerDetallePortafolioConLiquidez(
	 @i_idPortfolio		int				--Identificador del portafolio
	,@i_fechaIni		datetime
	,@i_fechaFin		datetime
	,@i_client_id		int
	,@i_public			bit=0
	,@i_lga_id			int=null
)as
begin
 
	/*if exists(
		select lgaExistente.LGA_FECHA,lgaExistente.LGA_USUARIO,lgaExistente.LGA_DIRECCION_IP from BVQ_SEGURIDAD.LOG_AUDITORIA lgaNuevo
		join BVQ_SEGURIDAD.LOG_AUDITORIA lgaExistente on lgaNuevo.LGA_DIRECCION_IP=lgaExistente.LGA_DIRECCION_IP and lgaNuevo.LGA_USUARIO=lgaExistente.lga_usuario
		where lgaExistente.lga_procedimiento=lgaNuevo.lga_procedimiento
		and DATEDIFF(hh,lgaExistente.lga_fecha,lgaNuevo.lga_fecha) between 0 and 0
		and lgaNuevo.LGA_ID=@i_lga_id and lgaNuevo.lga_usuario='Admin'
	--	order by LGA_ID desc
	) begin
		raiserror('Este procedimiento no puede ser llamado más de 1 vez cada hora por el usuario administrador desde la aplicación',16,1)
		return
	end*/
 
	--PV: para sacar liquidez de portafolios diferidos
	declare @tbPortafolio table (por_id int, dif_por_id int, por_public bit)
	insert into @tbPortafolio
	select distinct por_id,dif_por_id,por_public from BVQ_BACKOFFICE.PORTAFOLIO where @i_public=1
	
	--si solo se solicita un cliente preparar la liquidez
	if @i_idPortfolio<>-1 and @i_idPortfolio is not null
		exec bvq_backoffice.PrepararLiquidezCache null
 
	--exec dropifexists 'bvq_backoffice.evtTemp'
	truncate table bvq_backoffice.evtTemp
	insert into bvq_backoffice.evtTemp
	(oper,htp_id,es_vencimiento_interes,fecha,montoOper,vep_valor_efectivo,en_liquidez,por_id,saldo_liquidez,voucher_exists,lip_cliente_id,htp_tpo_id,htp_fecha_operacion,tasa_cupon,porv_retencion,iAmortizacion,nombre,por_codigo,liquidez_descripcion,ems_nombre,grc_codigo,tvl_codigo,tiv_fecha_vencimiento,tiv_tipo_valor,tpo_numeracion,vep_id,vep_cta_id,vep_other_account,amount,account,vep_renovacion,ttl_id,vep_observaciones,ttl_nombre,lip_retencion,com_id,lip_documento,cliente_nombre,htp_numeracion_clean,fecha_compra,por_tipo,tpo_categoria,vep_fecha,com_numero_comprobante,en_espera,evp_id,liq_compra
	--POR_PUBLIC_2
	,por_public
	,TIV_ID
	,dias_cupon
	,TVL_NOMBRE
	,TIV_FECHA_EMISION
	,TFL_FECHA_INICIO
	,TFL_FECHA_INICIO_ORIG
	,EVP_AJUSTE_PROVISION
	,TPO_FECHA_INGRESO
	,TPO_RECURSOS
	,TIV_SERIE
	,TIV_NUMERO_EMISION_SEB
	,TIV_FRECUENCIA
	,IPR_ES_CXC
	,fecha_original
	)
	select --* into bvq_backoffice.evtTemp
	 oper,htp_id,es_vencimiento_interes,fecha,montoOper,vep_valor_efectivo,en_liquidez,por_id,saldo_liquidez,voucher_exists,lip_cliente_id,htp_tpo_id,htp_fecha_operacion,tasa_cupon,porv_retencion,iAmortizacion,nombre,por_codigo,liquidez_descripcion,ems_nombre

	,grc_codigo,tvl_codigo,tiv_fecha_vencimiento,tiv_tipo_valor,tpo_numeracion,vep_id,vep_cta_id,vep_other_account,amount,account,vep_renovacion,ttl_id,vep_observaciones,ttl_nombre,lip_retencion,com_id,lip_documento,cliente_nombre,htp_numeracion_clean,fecha_compra,por_tipo,tpo_categoria,vep_fecha,com_numero_comprobante,en_espera,evp_id,liq_compra
 
	--POR_PUBLIC_2
	,por_public
	,TIV_ID
	,dias_cupon
	,TVL_NOMBRE
	,TIV_FECHA_EMISION
	,TFL_FECHA_INICIO
	,TFL_FECHA_INICIO_ORIG
	,EVP_AJUSTE_PROVISION
	,TPO_FECHA_INGRESO
	,TPO_RECURSOS
	,TIV_SERIE
	,TIV_NUMERO_EMISION_SEB
	,TIV_FRECUENCIA
	,IPR_ES_CXC
	,fecha_original
	from bvq_backoffice.ObtenerDetallePortafolioConLiquidezView
	--where @i_idPortfolio=-1 or es_vencimiento_interes=0
 
 
	--create clustered index ix01 on bvq_backoffice.evtTemp(por_id,fecha,oper,htp_id,es_vencimiento_interes)
 
	declare @prevPorId int,@accSalLiq float
	set @prevPorId=-1
	set @accSalLiq=0
 
	update bvq_backoffice.evtTemp set
	@accSalLiq=saldo_liquidez=case when @prevPorId=por_id then @accSalLiq+(vep_valor_efectivo-isnull(lip_retencion,0))*en_liquidez else (vep_valor_efectivo-isnull(lip_retencion,0))*en_liquidez end
	,@prevPorId=por_id
	from bvq_backoffice.evtTemp with(tablockx)
	where (abs(round(amount,2))>0.05e or oper=2)

	select *,TPO_REESTRUCTURACION=CASE WHEN TPO_NUMERACION='2014-4933' THEN 1 ELSE 0 END
	,(iAmortizacion+amount) AS 'total_cuota'
	,diasTran=dbo.fnDiasEu(case when fecha_compra>TFL_FECHA_INICIO then fecha_compra else tfl_fecha_inicio end,dateadd(d,-day(fecha),fecha),354)
	,originalProvision	=dbo.fnDiasEu(case when fecha_compra>TFL_FECHA_INICIO then fecha_compra else tfl_fecha_inicio end,dateadd(d,-day(fecha),fecha),354)/dias_cupon * iamortizacion
	,provision			=dbo.fnDiasEu(case when fecha_compra>TFL_FECHA_INICIO then fecha_compra else tfl_fecha_inicio end,dateadd(d,-day(fecha),fecha),354)/dias_cupon * iamortizacion
						+isnull(evp_ajuste_provision,0)
	from bvq_backoffice.evtTemp where fecha between @i_fechaIni and @i_fechaFin
	and (@i_client_id=lip_cliente_id or @i_client_id is null)
	and (@i_idPortfolio=por_id or @i_idPortfolio=-1)
	--Columna por_public
	and (@i_public=0 OR por_public=1)
	and (abs(round(amount,2))>0.05e or oper=2)
	--and por_id in (180,135,181,182,183) --PORTAFOLIOS DE ADVFINSA
	--obtener saldos iniciales
	select por_id,saldo_liquidez from(
		select row_number() over (partition by por_id order by fecha desc,oper asc,htp_id desc,es_vencimiento_interes desc) rn
		,por_id,saldo_liquidez
		from bvq_backoffice.evttemp
		where fecha<@i_fechaIni
		and (abs(round(amount,2))>0.05e or oper=2)
	) s where rn=1	
end