-- Basado en sp creado por Santiago.Yacelga Isspol
CREATE PROCEDURE bvq_backoffice.GenerarRecuperacionInversion
																--@ai_inversion INT,
																@as_nombre VARCHAR(200),
																@ad_fecha_original datetime=null,
																@ad_fecha_recuperacion datetime,
																@as_usuario VARCHAR(20),
																@as_equipo VARCHAR(20),
																@ai_id_asiento int OUTPUT,
																@as_msj VARCHAR(500) OUTPUT
AS
BEGIN
	SET
	NOCOUNT ON
	DECLARE @LI_RETURN  INT, @ls_oficina VARCHAR(20)--= comun.func_obtiene_oficina_principal()

	DECLARE @cmdOficina NVARCHAR(MAX) = 
	N'SELECT @ls_oficina = [ReturnValue] FROM OPENQUERY(
		[siisspolweb]
		, ''SELECT comun.func_obtiene_oficina_principal() ReturnValue''
		)'
	EXEC sys.sp_executesql 
	@cmdOficina, N'@ls_oficina varchar(20) output', @ls_oficina=@ls_oficina OUTPUT

	DECLARE @LD_FECHA_ACTUAL DATE --= comun.func_fecha_actual()
	DECLARE @cmdFechaActual NVARCHAR(MAX) = 
	N'SELECT @LD_FECHA_ACTUAL = [ReturnValue] FROM OPENQUERY(
		[siisspolweb]
		, ''SELECT comun.func_fecha_actual() ReturnValue''
		)'
	EXEC sys.sp_executesql 
	@cmdFechaActual, N'@LD_FECHA_ACTUAL date output', @LD_FECHA_ACTUAL=@LD_FECHA_ACTUAL OUTPUT



	DECLARE @LS_MOV_REFERENCIA VARCHAR(7000)--, @ls_moneda VARCHAR(20)=[comun].[func_obtiene_moneda_local]()
	DECLARE @ls_moneda VARCHAR(20)
	DECLARE @cmdMoneda NVARCHAR(MAX) = 
	N'SELECT @ls_moneda = [ReturnValue] FROM OPENQUERY(
		[siisspolweb]
		, ''SELECT comun.[func_obtiene_moneda_local]() ReturnValue''
		)'
	EXEC sys.sp_executesql 
	@cmdMoneda, N'@ls_moneda varchar(20) output', @ls_moneda=@ls_moneda OUTPUT
	DECLARE @li_ret INT, @li_id_lote int, @li_id_origen INT, @li_id_asiento INT
	DECLARE @TBL_CNT_TMP TABLE
							(
								fecha           DATE,
								modulo          VARCHAR(10),
								tipo_tcrans_org VARCHAR(10),
								oficina_ct      VARCHAR(10),
								concepto        VARCHAR(MAX),
								referencia      VARCHAR(MAX),             
								mov_cuenta      VARCHAR(MAX),
								mov_valor       VARCHAR(MAX),
								mov_tipo_trans  VARCHAR(MAX),
								mov_referencia  VARCHAR(MAX),
								moneda          VARCHAR(10),
								beneficiario    VARCHAR(MAX)
							)

	/*IF @ai_inversion is not null
	BEGIN
		--GENERA LOS MOVIMIENTOS CONTABLES, EN EL CASO DE QUE UN MOVIMIENTO CONTABLE NO CUENTE CON SU RESPECTIVA CONFIGURACION
		EXEC	@LI_RETURN = siisspolweb.siisspolweb.[inversion].[proc_obtiene_conf_asiento_recuperacion]
				@AI_INVERSION =		@ai_inversion,
				@AS_USARIO =		@as_usuario,
				@AS_EQUIPO =		@as_equipo,
				@AD_FECHA  =		@ad_fecha_recuperacion,
				@AS_MOV_CUENTA =	@LS_MOV_CUENTA OUTPUT,
				@AS_MOV_TIPO =		@AS_MOV_TIPO OUTPUT,
				@AS_MOV_VALOR =		@LS_MOV_VALOR OUTPUT,
				@AS_MSJ = @AS_MSJ OUTPUT

				SELECT @LS_MOV_REFERENCIA= COALESCE(@LS_MOV_REFERENCIA + ';', '') +  convert(varchar(100),C.descripcion ) 
				FROM  [inversion].[int_recuperacion_detalle] i 
				inner join [inversion].[int_inversion_recuperacion] r on r.id_int_inversion_recuperacion = i.id_int_inversion_recuperacion
				INNER JOIN  [inversion].[int_conf_fondo_cuenta] CC ON CC.id_int_conf_fondo_cuenta= i.id_int_conf_fondo_cuenta
				INNER JOIN banco.cuenta C ON C.id_cuenta = CC.id_fondo
				WHERE r.id_inversion  = @AI_INVERSION	 and r.fecha_recuperacion = @ad_fecha_recuperacion
				GROUP BY C.descripcion

	END
	ELSE*/
	DECLARE @LS_MOV_CUENTA VARCHAR(7000), @AS_MOV_TIPO VARCHAR(7000), @as_tabla VARCHAR(20)='CNT', @li_trans_cnt INT,
			@LS_MOV_VALOR VARCHAR(7000)
	BEGIN
		EXEC	@LI_RETURN = BVQ_BACKOFFICE.ObtenerConfAsientoRecuperacion--[inversion].[proc_obtiene_conf_asiento_recuperacion]
				--@AI_INVERSION =		@ai_inversion,
				@AS_NOMBRE =			@as_nombre,
				@AS_USARIO =			@as_usuario,
				@AS_EQUIPO =			@as_equipo,
				@AD_FECHA_ORIGINAL =	@ad_fecha_original,
				@AD_FECHA  =			@ad_fecha_recuperacion,
				@AS_MOV_CUENTA =		@LS_MOV_CUENTA OUTPUT,
				@AS_MOV_TIPO =			@AS_MOV_TIPO OUTPUT,
				@AS_MOV_VALOR =			@LS_MOV_VALOR OUTPUT,
				@AS_MOV_REFERENCIA =	@LS_MOV_REFERENCIA OUTPUT,
				@AS_MSJ = @AS_MSJ OUTPUT

				/*SELECT
						@LS_MOV_REFERENCIA= COALESCE(@LS_MOV_REFERENCIA + ';', '') +  convert(varchar(100),isnull(ref.referencia,'') ) 
				--select distinct top 100 codigo_configuracion
				from bvq_backoffice.IsspolComprobanteRecuperacion icr
				left join bvq_backoffice.Liquidez_Referencias_table ref on icr.tpo_numeracion=ref.tpo_numeracion and icr.fecha=ref.fecha and icr.codigo_configuracion in ('DIDENT','DIDENT02')
				where icr.tpo_numeracion=--'MDF-2013-04-25-2'
					@AS_NOMBRE
				and icr.fecha=--'20231201'
					@ad_fecha_recuperacion*/
				--group by icr.descripcion

	END

	IF (@LI_RETURN<>1)
	RETURN -1


	declare @ems_nombre varchar(200),@tvl_nombre varchar(150),@referencia varchar(200)
	select
	 @ems_nombre=ems_nombre
	,@tvl_nombre=tvl_nombre
	,@referencia=cis.tpo_numeracion
	from bvq_backoffice.comprobanteisspol cis
	where tpo_numeracion=@as_nombre and datediff(hh,fecha,@ad_fecha_recuperacion)=0


	SELECT @li_id_origen = id_tipo_tran_origen
	FROM [siisspolweb].siisspolweb.contabilidad.tipo_tran_origen
	WHERE codigo = 'LNV'

		SET @li_trans_cnt = @@IDENTITY

			delete from _temp.vars
			insert into _temp.vars(id)
			exec [siisspolweb].siisspolweb.dbo.sp_executesql N'
				DECLARE @TBL_CNT_TMP TABLE
				(
					fecha           DATE,
					modulo          VARCHAR(10),
					tipo_tcrans_org VARCHAR(10),
					oficina_ct      VARCHAR(10),
					concepto        VARCHAR(MAX),
					referencia      VARCHAR(MAX),             
					mov_cuenta      VARCHAR(MAX),
					mov_valor       VARCHAR(MAX),
					mov_tipo_trans  VARCHAR(MAX),
					mov_referencia  VARCHAR(MAX),
					moneda          VARCHAR(10),
					beneficiario    VARCHAR(MAX)
				)

				INSERT INTO @TBL_CNT_TMP
				SELECT top 1 @LD_FECHA_ACTUAL,''CNT'', ''LINV'', @ls_oficina
				, [concepto] = ''REGISTRO PAGO '' + isnull(@tvl_nombre + '' '','''') + isnull(@ems_nombre,'''') + '' - '' + isnull(@as_nombre,'''') + '' - Pago de: '' + isnull(format(@ad_fecha_recuperacion,''dd-MMM-yyyy''),'''')
				, referencia = @referencia
				, @LS_MOV_CUENTA, @LS_MOV_VALOR, @AS_MOV_TIPO, @LS_MOV_REFERENCIA, @ls_moneda
				, @ems_nombre
				--from bvq_backoffice.comprobanteisspol cis
				--where tpo_numeracion=@as_nombre and fecha=@ad_fecha_recuperacion


				--ENVIO A TABLA REMPORAL
				INSERT INTO dbo.cn_trans_cnt
				(
					fecha,
					modulo,
					tipo_trans_org,
					oficina_ct,
					concepto,
					referencia,
					mov_valor,
					mov_cuenta,
					mov_tipo_trans,
					mov_referencia,
					moneda,
					beneficiario)
				select
						@ad_fecha_recuperacion,
						modulo,
						tipo_tcrans_org,
						oficina_ct,
						concepto,
						referencia,
						mov_valor,
						mov_cuenta,
						mov_tipo_trans,
						mov_referencia,
						moneda,
						beneficiario
				from @tbl_cnt_tmp 
				SELECT SCOPE_IDENTITY();'
			,N'
				@LD_FECHA_ACTUAL date, @ls_oficina varchar(20), @LS_MOV_CUENTA varchar(7000), @LS_MOV_VALOR varchar(7000), @AS_MOV_TIPO varchar(7000), @LS_MOV_REFERENCIA varchar(7000), @ls_moneda varchar(20)
				, @as_nombre varchar(200), @ad_fecha_recuperacion datetime, @ems_nombre varchar(200), @tvl_nombre varchar(150),@referencia varchar(200)'
			,@LD_FECHA_ACTUAL,@ls_oficina,@LS_MOV_CUENTA,@LS_MOV_VALOR,@AS_MOV_TIPO,@LS_MOV_REFERENCIA,@ls_moneda
			,@as_nombre,@ad_fecha_recuperacion,@ems_nombre,@tvl_nombre,@referencia
			set @li_trans_cnt = (select top 1 id from _temp.vars)

	IF @@ERROR <> 0
	BEGIN
			exec bvq_administracion.IsspolFormatoMensajeValidacion 'ERROR AL ENVIAR LOS DATOS A CONTABILIDAD AUTOMATICA', 3, @as_msj output
			RETURN -1
	END

	--GENERACION DE ASIENTO CONTABLE
	EXEC @li_ret = [siisspolweb].siisspolweb.contautom.proc_procesar_contab_automatica_tran_id
						@as_tabla = @as_tabla,
						@adt_fecha = @LD_FECHA_ACTUAL,
						@as_oficina = @ls_oficina,
						@ai_id = @li_trans_cnt,
						@ai_lote = @li_id_lote OUTPUT,
						@as_usuario = @as_usuario,
						@dt_fecha = @LD_FECHA_ACTUAL,
						@as_equipo = @as_equipo,
						@as_msj = @as_msj OUTPUT,
						@ai_depurar = 0
	IF (@li_ret <> 1)
	BEGIN
			set @as_msj = ISNULL(@as_msj, 'ERROR EN contautom.proc_procesar_contab_automatica_tran_id')
			exec bvq_administracion.IsspolFormatoMensajeValidacion @as_msj, 2, @as_msj output
			RETURN @li_ret
	END

	EXEC @li_ret = [siisspolweb].siisspolweb.[contabilidad].[proc_transferir_lote_contab]
						@ai_lote = @li_id_lote,
						@ai_id_origen = @li_id_origen,
						@ai_id_asiento = @li_id_asiento OUTPUT,
						@as_usuario = @as_usuario,
						@dt_fecha = @LD_FECHA_ACTUAL,
						@as_equipo = @as_equipo,
						@as_msj = @as_msj OUTPUT
	set @ai_id_asiento=@li_id_asiento

	IF (@li_ret <> 1)
	BEGIN
			set @as_msj = ISNULL(@as_msj, 'ERROR EN [contabilidad].[proc_transferir_lote_contab]')
			exec bvq_administracion.IsspolFormatoMensajeValidacion @as_msj, 2, @as_msj output
			RETURN @li_ret
	END



return 1
end
