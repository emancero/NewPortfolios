CREATE procedure [BVQ_BACKOFFICE].[InsertarLiquidezPortafolio]
	@i_evp_id int,
	@i_evt_id bigint,
	@i_oper_id int,
	@i_es_vencimiento_interes bit,
	@i_por_id int,
	@i_cobrado bit,
	@i_fecha datetime,
	@i_monto float,
	@i_renovacion bit,
	@i_observaciones varchar(max),
	@i_numero_documento varchar(50),
	@i_ttl_id int,
	@i_cuenta varchar(max),
	@i_retencion float,
	@i_delete bit,
	@i_vep_id int,
	@i_cliente_id int,
	@i_inLiquidity bit,
	@o_vep_id int out,
	@o_cta_id int out,
	@o_com_id int out,
	@i_ajuste_provision float = null,--nuevo campo provision
	@i_pago_efectivo float=null,--nuevo campo ajuste_valor_efectivo
	@i_duplica BIT = NULL,
	@i_referencia VARCHAR(150) = NULL,
	@i_evp_uso_fondos float = null,
	@i_evp_rendimiento float = null,
	@i_evp_costas_judiciales float = null,
	@i_evp_costas_judiciales_referencia varchar(100) = null,
	@i_fecha_identificadora datetime = null,
	@i_lga_id int
AS
begin


	--set @i_evt_id=nullif(@i_evt_id,-1)
	--declare @o_com_id int
	select @o_com_id=com_id from bvq_backoffice.liquidez_portafolio lip
	where vep_id=@i_vep_id
	
	declare @fecha_anterior datetime,@fns_codigo varchar(50),@abono bit = isnull(@i_duplica,0)
	
	declare @v_com_numero_comprobante varchar(50)
	select @v_com_numero_comprobante=com_numero_comprobante,@fecha_anterior=com_fecha_aplicacion,@fns_codigo=fns_codigo
	from bvq_backoffice.comprobante_gestion_negocio com
	join bvq_backoffice.comprobante_tipo cti on com.cti_id=cti.cti_id join bvq_administracion.formato_codigo_documento fns on fns.fns_id=cti.fns_id
	where com_id=@o_com_id

	-- borrar vep
	EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
	@i_lga_id = @i_lga_id,
	@i_tabla = 'LIQUIDEZ_PORTAFOLIO',
	@i_esquema = N'BVQ_BACKOFFICE',
	@i_operacion = N'D',
	@i_subTipo = N'A',
	@i_columIdName = 'VEP_ID',
	@i_idAfectado = @i_vep_id;
	delete from bvq_backoffice.liquidez_portafolio where vep_id=@i_vep_id

	--validar periodo abierto
	declare @fecha_error varchar(100)
	select top 1 @fecha_error=periodo_mes_codigo+' de '+ejercicio_anio
	from bvq_backoffice.periodocontable per
	join (
		select @fecha_anterior com_fecha_aplicacion
		union select @i_fecha
	) s	on datepart(mm,s.com_fecha_aplicacion)=numero_mes and year(s.com_fecha_aplicacion)=ejercicio_anio
	where periodo_estado=224

	if @fecha_error is not null
	begin
		declare @msg varchar(200)
		set @msg='El periodo '+lower(@fecha_error)+' se encuentra cerrado'
		RAISERROR(@msg,16,1)
	end
	-- fin validar periodo abierto

	/*
	declare @i_inLiquidity bit
	set @i_inLiquidity=case when abs(@i_monto)>5e-9 or @i_monto=0 and @i_evt_id is null and @i_delete=0 then 1 else 0 end
	*/
	if @i_cobrado=0
		set @i_inLiquidity=0

	if @i_inLiquidity=1
	begin
		--remplazar
		delete from	bvq_backoffice.asiento_bancos where com_id=@o_com_id

		delete his from	bvq_backoffice.historico_transacciones his join bvq_backoffice.comprobante_gestion_negocio com on his.com_id=com.com_id and his.his_fecha_aplicacion=com.com_fecha_aplicacion
		where com.com_id=@o_com_id

		delete hcom from bvq_backoffice.historico_comprobante hcom join bvq_backoffice.comprobante_gestion_negocio com on hcom.com_id=com.com_id and hcom.com_fecha=com.com_fecha_aplicacion
		where com.com_id=@o_com_id

		--delete from	bvq_backoffice.comprobante_gestion_negocio where com_id=@o_com_id
	end
	else
	begin
		--si usuario quitó check de liquidez reversar
		declare @o_secuencial varchar(50)
		EXEC [BVQ_ADMINISTRACION].[ObtenerSecuencialDocumento]	@fns_codigo, @o_secuencial OUTPUT;
		insert into bvq_backoffice.comprobante_gestion_negocio(
			 CTI_ID,COM_DESCRIPCION,COM_ESTADO,COM_FECHA_APLICACION
			,COM_FECHA_CREACION,COM_FECHA_REVERSO,COM_FECHA_REVISION
			,COM_MODO_REGISTRO,COM_NUMERO_COMPROBANTE
			,COM_TOTAL_CREDITOS,COM_TOTAL_DEBITOS,COM_ORIGEN,COM_MOTIVO_RECHAZO
			,COM_MOTIVO_ANULACION,SUC_ID,USR_ID,COM_DOCUMENTO_ORIGEN,tpo_id_c
		)
		select
		 CTI_ID,COM_DESCRIPCION,COM_ESTADO,COM_FECHA_APLICACION
		,COM_FECHA_CREACION,COM_FECHA_REVERSO,COM_FECHA_REVISION
		,COM_MODO_REGISTRO,'R - ' + @o_secuencial
		,COM_TOTAL_CREDITOS,COM_TOTAL_DEBITOS,COM_ORIGEN,COM_MOTIVO_RECHAZO
		,COM_MOTIVO_ANULACION,SUC_ID,USR_ID,@v_com_numero_comprobante,tpo_id_c
		from bvq_backoffice.comprobante_gestion_negocio where com_id=@o_com_id

		insert into bvq_backoffice.asiento_bancos(
			COM_ID,CTA_ID,DBA_MONTO_MONEDA_LOCAL,DBA_MONTO_MONEDA_TRANSACCION,DBA_COMENTARIO,DBA_COTIZACION,DBA_TIPO,CCO_ID,DBA_FECHA_REGISTRO,MON_ID_LOCAL,MON_ID_EXTRANJERA,MON_COTIZACION,DBA_ESTADO,GNE_RUBRO
		)
		select scope_identity(),CTA_ID,DBA_MONTO_MONEDA_LOCAL,DBA_MONTO_MONEDA_TRANSACCION,'Reverso ' + DBA_COMENTARIO,DBA_COTIZACION,(1-DBA_TIPO),CCO_ID,DBA_FECHA_REGISTRO,MON_ID_LOCAL,MON_ID_EXTRANJERA,MON_COTIZACION,37,GNE_RUBRO
		from bvq_backoffice.asiento_bancos gne where com_id=@o_com_id
	end

	declare @ctl_id int
	select @o_cta_id=cta_id, @ctl_id=ctl_id from bvq_backoffice.CuentaContableYBancaria	--InsertarLiquidezPortafolio				cta_id,ctl_id
	where ctb_descripcion_grid=@i_cuenta

	declare @v_evp_id int
	--if @i_evt_id>-1

	if 1=1--@i_evt_id>-1
	begin
		-- actualizar evp
		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = 'EVENTO_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'U',
		@i_subTipo = N'A',
		@i_columIdName = 'EVP_ID',
		@i_idAfectado = @i_evp_id;
	
		IF(@i_duplica = 0 OR @i_duplica IS NULL)
		begin
			delete from bvq_backoffice.evento_portafolio where evp_id=@i_evp_id --or isnull(@i_evp_id,-1)=-1 and evt_id=@i_evt_id and oper_id=@i_oper_id and es_vencimiento_interes=@i_es_vencimiento_interes
			delete from bvq_backoffice.eventos_relacion where evp_id=@i_evp_id
		end

		delete from bvq_backoffice.evento_portafolio where evp_id=@i_evp_id and evp_abono=1 --si es abono borrar siempre
		delete evr from bvq_backoffice.eventos_relacion evr join bvq_backoffice.evento_portafolio evp on evp.evp_id=evr.evp_id
		where evr.evp_id=@i_evp_id and evp_abono=1
		
		declare @tpo_id int
		set @tpo_id=@i_evt_id % 10000000
		declare @fecha_original datetime
		select @fecha_original=tfl_fecha_vencimiento from BVQ_ADMINISTRACION.TITULO_FLUJO TFL
		WHERE TFL_ID=@i_evt_id/10000000

		--evitar caso excepcional de Fecorsa que paga dos vencimientos del mismo título en una misma fecha
		select top 1 @i_fecha=dateadd(hh,1,fecha)
		from bvq_backoffice.evttemp evp where htp_tpo_id=@tpo_id
		and fecha=@i_fecha and @tpo_id in (321,324) and evp_id is not null
		order by fecha desc
		
		insert into bvq_backoffice.evento_portafolio(evt_id,por_id,oper_id,es_vencimiento_interes,evp_cobrado,evt_fecha,cta_id,evp_retencion,evp_otra_cuenta,evp_renovacion
			--evp_change_6
			,evp_observaciones
			,ctl_id
			,evp_valor_efectivo
			--EMN: 12/05/2020 para hacer join por fecha y tpo, y no por evt_id
			,evp_fecha_original
			,evp_tpo_id
			,evp_ajuste_provision
			,evp_ajuste_valor_efectivo
			,EVP_ABONO
			,evp_referencia
			,evp_uso_fondos
			,evp_rendimiento
			,EVP_COSTAS_JUDICIALES
			,EVP_COSTAS_JUDICIALES_REFERENCIA
		)
		values(@i_evt_id,@i_por_id,@i_oper_id,@i_es_vencimiento_interes,@i_cobrado,@i_fecha,@o_cta_id,@i_retencion,@i_cuenta,@i_renovacion
			--evp_change_7
			,@i_observaciones,@ctl_id,@i_monto
			--EMN: 12/05/2020 para hacer join por fecha y tpo, y no por evt_id
			,@fecha_original,@tpo_id,@i_ajuste_provision
			,@i_pago_efectivo
			,@i_duplica
			,@i_referencia
			,@i_evp_uso_fondos
			,@i_evp_rendimiento
			,@i_evp_costas_judiciales
			,@i_evp_costas_judiciales_referencia
		)

		set @v_evp_id=scope_identity()
		insert into bvq_backoffice.eventos_relacion(
			 htp_id
			,es_vencimiento_interes
			,evp_id
		)
		values (
			 @i_evt_id
			,@i_es_vencimiento_interes
			,@v_evp_id
		)
		
		--actualizar referencia si cambia la fecha (y no es abono)
		update r set fecha=@i_fecha
		from bvq_backoffice.liquidez_referencias_table r
		join bvq_backoffice.titulos_portafolio tpo on r.tpo_numeracion=tpo.tpo_numeracion
		where tpo.tpo_id=@tpo_id and
		(
			@abono=0 and datediff(d,r.fecha_original,@fecha_original)=0
			or
			@abono=1 and datediff(d,r.fecha,@i_fecha_identificadora)=0 and convert(time,r.fecha)=convert(time,@i_fecha_identificadora)
		)

		--actualizar fecha en el control de envío a Siisspolweb
		exec BVQ_BACKOFFICE.ActualizarFechaControlEnvioIsspol
		 @i_fecha = @i_fecha
		,@i_fecha_original = @fecha_original
		,@i_tpo_id = @tpo_id


		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = 'EVENTO_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'U',
		@i_subTipo = N'N',
		@i_columIdName = 'EVP_ID',
		@i_idAfectado = @v_evp_id;
		-- fin actualizar evp
		

		if @i_oper_id=1
		begin
			if(@i_cobrado=0 and isnull(@i_duplica,0) = 0)
			begin
				delete retr from bvq_backoffice.retraso retr join bvq_administracion.titulo_flujo tfl on datediff(d,tfl_fecha_vencimiento,retr_fecha_esperada)=0
				where tfl_id=@i_evt_id/10000000 and retr_tpo_id=@i_evt_id%10000000
			end

			if not exists(
				select * from bvq_backoffice.retraso retr join bvq_administracion.titulo_flujo tfl on datediff(d,tfl_fecha_vencimiento,retr_fecha_esperada)=0
				where tfl_id=@i_evt_id/10000000 and retr_tpo_id=@i_evt_id%10000000
			)
			begin
				insert into bvq_backoffice.retraso(retr_tpo_id,retr_fecha_esperada,retr_fecha_cobro,RETR_INTERES,retr_capital)
				select
				 @i_evt_id%10000000
				,tfl_fecha_vencimiento
				,retr_fecha_cobro=case when @i_duplica=1 then '39991231' else convert(date,@i_fecha) end
				,case when @i_es_vencimiento_interes=1 then 1 else 0 end
				,case when @i_es_vencimiento_interes=0 then 1 else 0 end
				from bvq_administracion.titulo_flujo tfl where tfl_id=@i_evt_id/10000000 and
				datediff(d,tfl_fecha_vencimiento,@i_fecha)<>0
			end
			else
			begin
				if @abono=0
				begin
					declare @v_retr_id int = (select top 1 retr_id from bvq_backoffice.retraso retr join bvq_administracion.titulo_flujo tfl on datediff(d,tfl_fecha_vencimiento,retr_fecha_esperada)=0
					where tfl_id=@i_evt_id/10000000 and retr_tpo_id=@i_evt_id%10000000)

					EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
					@i_lga_id = @i_lga_id,
					@i_tabla = 'RETRASO',
					@i_esquema = N'BVQ_BACKOFFICE',
					@i_operacion = N'U',
					@i_subTipo = N'A',
					@i_columIdName = 'RETR_ID',
					@i_idAfectado = @v_retr_id;

					--delete retr
					update retr set retr_fecha_cobro=convert(date,@i_fecha)
					,retr_interes=case when @i_es_vencimiento_interes=1 then 1 else retr_interes end
					,retr_capital=case when @i_es_vencimiento_interes=0 then 1 else retr_capital end
					from bvq_backoffice.retraso retr join bvq_administracion.titulo_flujo tfl on datediff(d,tfl_fecha_vencimiento,retr_fecha_esperada)=0
					where tfl_id=@i_evt_id/10000000 and retr_tpo_id=@i_evt_id%10000000

					EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
					@i_lga_id = @i_lga_id,
					@i_tabla = 'RETRASO',
					@i_esquema = N'BVQ_BACKOFFICE',
					@i_operacion = N'U',
					@i_subTipo = N'N',
					@i_columIdName = 'RETR_ID',
					@i_idAfectado = @v_retr_id;
				end
			end
		end
	end

	--vep
	if @i_inLiquidity=1
	begin

		insert into bvq_backoffice.liquidez_portafolio(
			por_id,
			vep_fecha,
			vep_valor_efectivo,
			mon_id,
			evp_id,
			evt_id,
			oper_id,
			es_vencimiento_interes,
			vep_renovacion,
			vep_observaciones,
			lip_documento,
			ttl_id,
			vep_cta_id,
			lip_cliente_id,
			lip_retencion,
			ctl_id
		) 
		values(
			@i_por_id,
			@i_fecha,
			@i_monto,
			1,
			@v_evp_id,
			@i_evt_id,
			@i_oper_id,
			@i_es_vencimiento_interes,
			@i_renovacion,
			@i_observaciones,
			@i_numero_documento,
			@i_ttl_id,
			@o_cta_id,
			@i_cliente_id,
			@i_retencion,
			@ctl_id
		)
		set @o_vep_id=scope_identity()
	end
	
	EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
	@i_lga_id = @i_lga_id,
	@i_tabla = 'LIQUIDEZ_PORTAFOLIO',
	@i_esquema = N'BVQ_BACKOFFICE',
	@i_operacion = N'I',
	@i_subTipo = N'N',
	@i_columIdName = 'VEP_ID',
	@i_idAfectado = @@IDENTITY;

end
