CREATE PROCEDURE [BVQ_BACKOFFICE].[IsspolCrearConfiguracion]
	@i_id_inversion AS INT=null,
	@i_estado_inversion AS INT=null,
	@i_maquina AS VARCHAR(50),
	@i_usuario AS VARCHAR(50),
	@i_monto_inversion AS MONEY=null,
	@i_fecha as DATETIME=null,
	@i_nombre AS VARCHAR(200)=null,
	@AS_MSJ AS VARCHAR(500) output,
	@i_all bit=null,
	@i_lga_id int=null
AS
begin
	exec BVQ_ADMINISTRACION.IsspolEnvioLog 'Inicio en ejecucion: '
--begin try
	set xact_abort on
	begin transaction
		declare @w_id_recuperacion AS INT,
				@w_id_conf_fondo AS INT,
				@LS_FECHA_ACTUAL  DATETIME,
				@w_id_mensaje AS VARCHAR,
				@cola AS INT
			declare @log varchar(500)
			exec @cola = bvq_administracion.BeginCola
			
		--create table _temp.vars(id int)
		/*	INSERT INTO siisspolweb.siisspolweb.inversion.int_inversion_recuperacion (id_inversion, estado, creacion_usuario, creacion_fecha,creacion_equipo,modifica_usuario,modifica_fecha,modifica_equipo)
			VALUES (@i_id_inversion, @i_estado_inversion, @i_usuario, GETDATE(), @i_maquina, @i_usuario, GETDATE(), @i_maquina)
			SELECT @w_id_recuperacion=SCOPE_IDENTITY();*/

			DECLARE @LT_TEMP TABLE (ID INT IDENTITY, T_FONDO INT, T_TIPO_PAPEL INT, D_FONDO VARCHAR(100), D_TIPO_PAPEL VARCHAR(100), CODIGO VARCHAR(100), T_COD_LISTA_RUBRO VARCHAR(100), T_TIPO_RUBRO VARCHAR(1))

			
			INSERT INTO @LT_TEMP
			select distinct(id_cuenta), icr.id_tipo_papel,  icr.descripcion as fondo, icr.descripcion as tipoPapel, icr.codigo_configuracion
			,icr.codigo_configuracion + case when 1=0 and icr.codigo_configuracion='DIDENT' then '' else
				'_'+icr.tippap+'_'+
				VCT.tipoCodigo
			end
			,icr.tipo_rubro_movimiento
			from bvq_backoffice.isspolcomprobanterecuperacion icr
			left JOIN [siisspolweb].siisspolweb.comun.vis_catalogo_tipo VCT ON VCT.grupoCodigo= 'CDF' AND VCT.valor = CAST(icr.id_cuenta AS varchar(10))
			--where tpo_numeracion='SNF-2019-08-16' and fecha='20231030'
			--where fecha>='20231201' and tippap<>'SWAP'
			--order by fecha,tpo_numeracion,id_cuenta
			/*left join siisspolweb.siisspolweb.inversion.int_conf_fondo_cuenta cnf
			on icr.id_tipo_papel=cnf.id_tipo_papel
			and icr.id_cuenta=cnf.id_fondo*/
			where
			(
				@i_all is null and(
					icr.tpo_numeracion=@i_nombre and icr.fecha=@i_fecha
					and @i_id_inversion is null
					or icr.id_inversion=@i_id_inversion
				)
				or @i_all=1
			)
			and fecha>='20231030' and tippap<>'SWAP'

			DECLARE @Command NVARCHAR(MAX) = 
			N'SELECT @LS_FECHA_ACTUAL = [ReturnValue] FROM OPENQUERY(
				[siisspolweb]
				, ''SELECT comun.func_fecha_actual() ReturnValue''
				)'
			EXEC sys.sp_executesql 
			@Command, N'@LS_FECHA_ACTUAL datetime output', @LS_FECHA_ACTUAL=@LS_FECHA_ACTUAL OUTPUT
			--SET @LS_FECHA_ACTUAL = siisspolweb.siisspolweb.comun.func_fecha_actual()

			INSERT INTO [siisspolweb].siisspolweb.[inversion].[int_conf_fondo_cuenta] ([id_fondo],[id_tipo_papel],[codigo_configuracion]
																,  [creacion_usuario],[creacion_fecha], [creacion_equipo]
																, [modifica_usuario], [modifica_fecha],  [modifica_equipo], [codigo_lista_rubro], [tipo_rubro_movimiento]  )
			SELECT T_FONDO, T_TIPO_PAPEL, CODIGO, @i_usuario , @LS_FECHA_ACTUAL, @i_maquina, @i_usuario , @LS_FECHA_ACTUAL, @i_maquina, T_COD_LISTA_RUBRO, T_TIPO_RUBRO
			FROM @LT_TEMP
			WHERE ID NOT IN (
				SELECT T.ID
				FROM [siisspolweb].siisspolweb.[inversion].[int_conf_fondo_cuenta] ICF
				INNER JOIN @LT_TEMP T ON T.T_FONDO = ICF.id_fondo AND T.T_TIPO_PAPEL = ICF.id_tipo_papel and CODIGO = codigo_configuracion
			)

			--lista_rubro
			DECLARE @TEMP TABLE (ID INT IDENTITY, T_CODIGO VARCHAR(100))

			INSERT INTO @TEMP
			SELECT codigo 
			FROM [siisspolweb].siisspolweb.contautom.lista_rubro WHERE id_tipo_rubro_contable = 'INVERSION-R'
				
			INSERT INTO [siisspolweb].siisspolweb.contautom.lista_rubro
			(id_tipo_rubro_contable, nombre, descripcion, codigo,
				creacion_usuario, creacion_fecha, creacion_equipo, modifica_usuario, modifica_fecha, modifica_equipo)
			SELECT 
				'INVERSION-R', 
				C.descripcion,
				coalesce(VC.nombre,rfp.codigo_configuracion) +' - ' + RFP.[tipo_rubro_movimiento],
				RFP.CODIGO_LISTA_RUBRO,
				@i_usuario,@LS_FECHA_ACTUAL,@i_maquina, 
				@i_usuario,@LS_FECHA_ACTUAL,@i_maquina
			FROM [siisspolweb].siisspolweb.[inversion].[int_conf_fondo_cuenta] RFP
			INNER JOIN [siisspolweb].siisspolweb.inversion.tipo_papel TP ON TP.id_tipo_papel= RFP.ID_TIPO_PAPEL
			INNER JOIN [siisspolweb].siisspolweb.banco.cuenta  C ON C.id_cuenta = RFP.ID_FONDO	
			left JOIN [siisspolweb].siisspolweb.comun.vis_catalogo_tipo VC ON VC.grupoCodigo = 'RECUPERA' AND VC.valor = RFP.codigo_configuracion
			WHERE RFP.CODIGO_LISTA_RUBRO  NOT IN (SELECT T_CODIGO FROM @TEMP)


			--crear lista_rubro_detalle
			--crea tabla temporal con los comprobantes de recuperación
			if object_id('tempdb..#icr') is not null
				drop table #icr
			select distinct tippap,por_id,codigo_lista_rubro,tipo_rubro_movimiento,codigo_configuracion,cis_cuenta,cis_aux
			into #icr
			from bvq_backoffice.isspolcomprobanterecuperacion where fecha>='20231030'

			--inserta en lista_rubro detalle las cuentas contables de cada rubro
			insert into siisspolweb.siisspolweb.contautom.lista_rubro_detalle(
					id_lista_rubro,id_cuenta_contable,id_grupo_cuenta,id_cuenta_presupuesto,id_centro_costo
				,creacion_usuario,creacion_fecha,creacion_equipo,modifica_usuario,modifica_fecha,modifica_equipo,id_tipo_presupuesto
			)
			select distinct
				l.id_lista_rubro
			,c.id_cuenta
			,grupo_cuenta=case left(c.cuenta_formato,1) when '7' then 3 else 1 end
			,cp.id_cuenta_presupuestaria
			,p.id_centro_costo
			,creacion_usuario='adminisspol'
			,creacion_fecha=l.creacion_fecha--getdate()
			,creacion_equipo='192.168.2.225'
			,modifica_usuario='adminisspol'
			,modifica_fecha=getdate()
			,modifica_equipo='192.168.2.225'
			,id_tipo_presupuesto=null
			--,codigo_lista_rubro
			--,l.codigo
			from #icr icr
			join siisspolweb.siisspolweb.contautom.lista_rubro l on l.codigo=codigo_lista_rubro and l.id_tipo_rubro_contable='INVERSION-R'
			left join siisspolweb.siisspolweb.contabilidad.cuenta c on c.cuenta_formato=cis_cuenta+'.'+cis_aux--(tipo_rubro_movimiento='D' and c.cuenta_formato=deudora or tipo_rubro_movimiento='C' and c.cuenta_formato=acreedora)
			left join siisspolweb.siisspolweb.contabilidad.relacion_cuenta_ct_pre cp on c.id_cuenta=cp.id_cuenta and cp.id_ejercicio=34 and codigo_configuracion='INTE' and tipo_rubro_movimiento='C'
			left join siisspolweb.siisspolweb.contabilidad.cuenta_presupuestaria pre on pre.id_cuenta_presupuestaria=cp.id_cuenta_presupuestaria
			left join siisspolweb.siisspolweb.contabilidad.presupuesto p on p.id_cuenta_presupuestaria=cp.id_cuenta_presupuestaria and cp.id_ejercicio=p.id_ejercicio
			left join siisspolweb.siisspolweb.contautom.lista_rubro_detalle ld on ld.id_lista_rubro=l.id_lista_rubro
			where c.id_cuenta is not null-- and cp.id_cuenta_presupuestaria is not null--id_centro_costo is not null
			and ld.id_lista_rubro is null
			--fin crear lista_rubro_detalle

			/*
			declare @max_id_int_conf_fondo_cuenta int = (select max(id_int_conf_fondo_cuenta) from siisspolweb.siisspolweb.inversion.int_conf_fondo_cuenta)
			declare @CONF_MSJ varchar(500), @retConf int
			exec @retConf = siisspolweb.siisspolweb.[inversion].[proc_creacion_configuracion] @i_id_inversion, @i_usuario, @i_maquina, @AS_MSJ=@CONF_MSJ OUTPUT
			if @retConf not in (0,1)
			begin
					declare @err varchar(250)=isnull(@CONF_MSJ,'')
					raiserror('%s ErrNum: %d', 16, 0, @err)
					rollback tran
					return --@retConf
			end

			declare @new_max_id_int_conf_fondo_cuenta int = (select max(id_int_conf_fondo_cuenta) from siisspolweb.siisspolweb.inversion.int_conf_fondo_cuenta)
			if(@new_max_id_int_conf_fondo_cuenta > @max_id_int_conf_fondo_cuenta)
				SET @AS_MSJ = 'Se ha creado una nueva configuración para ser llenada en contabilidad'
			*/
			--select * from bvq_backoffice.isspolcomprobanterecuperacion ict where fecha='20231201' and tpo_numeracion='MDF-2013-04-25-2'

	commit tran
end

