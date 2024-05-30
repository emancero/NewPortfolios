CREATE PROCEDURE [BVQ_BACKOFFICE].[IsspolInsertarComprobanteRecuperacion]
	@i_id_inversion AS INT,
	@i_estado_inversion AS INT,
	@i_maquina AS VARCHAR(50),
	@i_usuario AS VARCHAR(50),
	@i_monto_inversion AS MONEY,
	@i_fecha_original as DATETIME=null,
	@i_fecha as DATETIME,
	@i_nombre as varchar(200),
	@AS_MSJ AS VARCHAR(500) output,
	@i_lga_id int
AS
begin
	set xact_abort on
	begin tran
		if 1=0 and @i_id_inversion is not null
		begin
			declare @log varchar(500)
			declare @w_id_recuperacion int

			--variables
			declare @v_referencia varchar(250)
			declare @v_concepto varchar(250)
			declare @v_beneficiario varchar(250)
			--declare @i_id_inversion int =224
			select
					@v_referencia = CIS.tpo_numeracion -- nombre
				,@v_concepto = 'REGISTRO PAGO ' + isnull(tvl.tvl_nombre + ' ','') + isnull(emi.ems_nombre,'') + ' - ' + isnull(cis.tpo_numeracion,'') + ' - Pago de: ' + isnull(format(cis.fecha,'dd-MMM-yyyy'),'') 
				,@v_beneficiario = emi.ems_nombre

			from BVQ_BACKOFFICE.Comprobante_Isspol CIS join BVQ_ADMINISTRACION.TITULO_VALOR tit
				on CIS.tiv_id = tit.tiv_id	join BVQ_ADMINISTRACION.emisor emi
				on tit.tiv_emisor = emi.ems_id	join BVQ_ADMINISTRACION.PERSONA_JURIDICA pju
				on emi.PJU_ID = pju.PJU_ID	join [siisspolweb].siisspolweb.inversion.vis_emisor_calificacion e
				on pju.pju_identificacion = e.identificacion join BVQ_ADMINISTRACION.tipo_valor tvl
				on tit.TIV_TIPO_VALOR = tvl.tvl_id	
				--t.id_emisor=sic.idemisor 

			--unión con la inversión
				join [siisspolweb].siisspolweb.[inversion].[inversion] i
					join [siisspolweb].siisspolweb.[inversion].[inversion_titulo] it on it.id_inversion=i.id_inversion
					join [siisspolweb].siisspolweb.[inversion].[titulo] t on it.id_titulo=t.id_titulo
				on tit.tiv_fecha_vencimiento = t.fecha_vencimiento 
			where it.id_inversion=@i_id_inversion   --225--181
			and cis.fecha=@i_fecha
			print formatmessage('referencia:%s concepto:%s beneficiario:%s',@v_referencia,@v_concepto,@v_beneficiario)

			-- insertar en int_inversion_recuperacion -------------------------------------------
			delete from _temp.vars
			insert into _temp.vars(id)
			exec [siisspolweb].siisspolweb.dbo.sp_executesql N'
				INSERT INTO inversion.int_inversion_recuperacion (
					id_inversion, estado, referencia, concepto, beneficiario, creacion_usuario, creacion_fecha
					,creacion_equipo,modifica_usuario,modifica_fecha,modifica_equipo,fecha_recuperacion
				)
				VALUES (
						@i_id_inversion, @i_estado_inversion, @v_referencia, @v_concepto, @v_beneficiario, @i_usuario, GETDATE()
					, @i_maquina, @i_usuario, GETDATE(), @i_maquina,@i_fecha
				)
				SELECT SCOPE_IDENTITY();'
			,N'
				@i_id_inversion int, @i_estado_inversion int, @i_usuario varchar(100), @i_maquina varchar(100)
				, @v_referencia varchar(250), @v_concepto varchar(250), @v_beneficiario varchar(250), @i_fecha datetime'
			,@i_id_inversion,@i_estado_inversion,@i_usuario,@i_maquina,@v_referencia, @v_concepto, @v_beneficiario, @i_fecha --i_id_inversion,@i_estado_inversion,@i_usuario,@i_maquina
			set @w_id_recuperacion = (select top 1 id from _temp.vars)

			set @log=formatmessage('id de recuperación %d',isnull(@w_id_recuperacion,0))
			exec bvq_administracion.IsspolEnvioLog @log
			print @log
			-- Fin insertar en int_inversion_recuperacion ---------------------------------------

					
			---///////////////
			select @w_id_recuperacion, id_int_conf_fondo_cuenta, 
			case when cis.tipo_rubro_movimiento='D' then cis.debe else cis.haber end, 
			@i_usuario, 
			GETDATE(), 
			@i_maquina, 
			@i_usuario, 
			GETDATE(), 
			@i_maquina
			--select cis.*--tiv_id,cis.htp_tpo_id
			--,i.id_inversion--tiv.tiv_emisor,tiv_subtipo,tpo.tpo_acta,tp.id_tipo_papel,idEmisor,imf_sis--,*
			from bvq_backoffice.IsspolComprobanteRecuperacion cis

			--select ri,rubro,* from bvq_backoffice.comprobanteisspol cis
			where
			cis.fecha=@i_fecha/*'20230629'*/
			and cis.tpo_numeracion=@i_nombre/*'ABO-2023-06-26-10'*/
			and cis.id_inversion=@i_id_inversion
			print @i_fecha
			print @i_nombre
			print @i_id_inversion
			---////////////////////

			--insertar en int_recuperacion_detalle -------------------------------------------------
			INSERT INTO [siisspolweb].siisspolweb.inversion.int_recuperacion_detalle (id_int_inversion_recuperacion, id_int_conf_fondo_cuenta, valor, creacion_usuario, creacion_fecha,creacion_equipo,modifica_usuario,modifica_fecha,modifica_equipo)
			select @w_id_recuperacion, id_int_conf_fondo_cuenta, 
			case when cis.tipo_rubro_movimiento='D' then cis.debe else cis.haber end, 
			@i_usuario, 
			GETDATE(), 
			@i_maquina, 
			@i_usuario, 
			GETDATE(), 
			@i_maquina
			--select cis.*--tiv_id,cis.htp_tpo_id
			--,i.id_inversion--tiv.tiv_emisor,tiv_subtipo,tpo.tpo_acta,tp.id_tipo_papel,idEmisor,imf_sis--,*
			from bvq_backoffice.IsspolComprobanteRecuperacion cis

			--select ri,rubro,* from bvq_backoffice.comprobanteisspol cis
			where
			cis.fecha=@i_fecha/*'20230629'*/
			and cis.tpo_numeracion=@i_nombre/*'ABO-2023-06-26-10'*/
			and cis.id_inversion=@i_id_inversion/*225*/--datediff(m,'20230901',cis.fecha)=0
			--Fin insertar en int_recuperacion_detalle --------------------------------------------
					
			---and datediff(d,cis.fecha,@i_fecha)=0
			/*select * from siisspolweb.siisspolweb.inversion.int_conf_fondo_cuenta c where id_int_conf_fondo_cuenta>140
			select rubro,* from bvq_backoffice.comprobanteisspol c where tpo_numeracion='DAN-2023-04-19' and fecha='20231014'*/
			/*.
			select * from bvq_backoffice.isspolainsertar

			VALUES (@w_id_recuperacion, @w_id_conf_fondo, @i_monto_inversion, @i_usuario, GETDATE(), @i_maquina, @i_usuario, GETDATE(), @i_maquina)*/
			
			--insert into bvq_administracion.msj(cola_id, inst_tipo, inst_id, seq, obj_id)
			--values(@cola,'COM_BVQ_BACKOFFICE.IsspolInsertarComprobanteInversion',1,1,'COM_InsertarComprobante.Inversion')

			--SELECT @w_id_mensaje=SCOPE_IDENTITY();
			--select * from siisspolweb.siisspolweb.inversion.int_recuperacion_detalle
			/*

			END TRY 
			BEGIN CATCH
				SET @AS_MSJ = ERROR_MESSAGE()
				RETURN -1
			END CATCH
			*/
					
		end --fin if 1=0 and @i_id_inversion is not null

		declare @li_id_asiento int=-1
		if 1=0 and @i_id_inversion is not null
		begin
			exec BVQ_ADMINISTRACION.IsspolEnvioLog 'Antes de proc_generar_recuperacion_inversion'
			declare @ret2 int
			exec @ret2=[siisspolweb].siisspolweb.[inversion].[proc_generar_recuperacion_inversion]
																		@ai_inversion = @i_id_inversion,
																		@ad_fecha_recuperacion =@i_fecha,
																		@as_usuario = @i_usuario,
																		@as_equipo = @i_maquina,
																		@as_msj = @as_msj OUTPUT
			exec BVQ_ADMINISTRACION.IsspolEnvioLog 'Después de proc_generar_recuperacion_inversion'

			if @ret2<>1
			begin
				raiserror('Error en proc_generar_recuperacion_inversion: %s', 16, 1, @as_msj)
				rollback tran
				return @ret2
			end
		end
		else
		begin
			exec BVQ_ADMINISTRACION.IsspolEnvioLog 'Antes de GenerarRecuperacionInversion'
			declare @ret3 int
			exec @ret3=bvq_backoffice.GenerarRecuperacionInversion
				@ai_inversion = @i_id_inversion,
				@as_nombre = @i_nombre,-- @i_nombre es TPO_NUMERACION
				@ad_fecha_original = @i_fecha_original,
				@ad_fecha_recuperacion = @i_fecha,
				@as_usuario = @i_usuario,
				@as_equipo = @i_maquina,
				@ai_id_asiento = @li_id_asiento output,
				@as_msj = @as_msj OUTPUT
			exec BVQ_ADMINISTRACION.IsspolEnvioLog 'Después de GenerarRecuperacionInversion'



			if @ret3<>1
			begin
				raiserror('Error en GenerarRecuperacionInversion: %s', 16, 1, @as_msj)
				rollback tran
				return @ret3
			end
		end
				
		--insertar en log local se obtiene en la consulta de envío de recuperaciones para saber si está enviada
		IF NOT EXISTS (SELECT 1 FROM bvq_backoffice.ISSPOL_RECUPERACION WHERE ISR_NUMERACION=@i_nombre AND ISR_FECHA=@i_fecha)
		BEGIN
			insert into bvq_backoffice.ISSPOL_RECUPERACION (ISR_NUMERACION, ISR_FECHA)
												values (@i_nombre,@i_fecha)
		END

		--referencias -------------------------------
		declare CUR_REFS cursor for
		select valor,idMasivasTransaccion,referencia from bvq_backoffice.liquidez_referencias_table lrt
		where tpo_numeracion=@i_nombre and datediff(hh,fecha,@i_fecha)=0-- and fecha_original=@i_fecha_original

		declare @v_total float, @v_id_masivas_transaccion int, @v_referencia2 varchar(50), @v_sec int
		open CUR_REFS
		fetch next from CUR_REFS into @v_total,@v_id_masivas_transaccion,@v_referencia2
		while @@FETCH_STATUS=0
		begin
			--obtener sec
			select @v_sec=sec from [siisspolweb].siisspolweb.contabilidad.movimiento m where id_asiento=@li_id_asiento and m.referencia=@v_referencia2

			INSERT INTO [siisspolweb].siisspolweb.banco.masiva_detalle_deposito_noidentif(
			 id_masivas_transaccion
			,id_asiento
			,sec
			,referencia
			,fecha
			,valor
			,concepto
			,tipo_asignacion
			,eliminado
			,creacion_usuario
			,creacion_fecha
			,creacion_equipo
			,modifica_usuario
			,modifica_fecha,modifica_equipo)
			VALUES (
				 @v_id_masivas_transaccion --@AI_ID_MASIVA_TRANSACCION
				,@li_id_asiento--@AI_ID_ASIENTO
				,@v_sec--@AI_SEC
				,@v_referencia2--@AS_REFERENCIA
				,getdate()--@AD_FECHA
				,@v_total--@AM_VALOR
				,@v_referencia2--@AS_CONCEPTO
				,'I'--@AS_TIPO_ASIGNACION
				,0
				,@i_usuario--@AS_USUARIO
				,getdate()--@AD_FECHA
				,@i_maquina--@AS_EQUIPO
				,@i_usuario--@AS_USUARIO
				,getdate()--@AD_FECHA
				,@i_maquina--@AS_EQUIPO
			)
			IF ( @@ERROR<> 0 )
			BEGIN
				SET @AS_MSJ = 'siisspol.comun.errorProcesarPeticion'
				RETURN -1
			END

			exec BVQ_BACKOFFICE.IsspolAbonarADeposito
				 @LM_TOTAL=@v_total, @AS_USUARIO=@i_usuario, @AS_EQUIPO=@i_maquina
				,@AI_ID_MASIVA_TRANSACCION=@v_id_masivas_transaccion

			fetch next from CUR_REFS into @v_total,@v_id_masivas_transaccion,@v_referencia2
		end
		close CUR_REFS
		deallocate CUR_REFS
		--fin referencias-----------------------------

	COMMIT transaction

	exec BVQ_ADMINISTRACION.IsspolEnvioLog 'Fin IsspolInsertarComprobanteRecuperacion'

	return 1
/*end try
begin catch
	--exec BVQ_ADMINISTRACION.IsspolEnvioLog 'Error en ejecucion: '
	declare @error varchar(1000)=error_message()
	raiserror('Catch: %s',16,1,@error)
end catch*/

end;
