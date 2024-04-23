CREATE procedure bvq_backoffice.IsspolInsertarInversion
	@TPO_NUMERACION varchar(255), @tiv_id int, @i_creacion_usuario varchar(100), @o_tiv_id int out, @o_msj varchar(max) out, @i_lga_id int=null as
--declare
--	@TPO_NUMERACION varchar(255)='MDF-05-10-2023', @tiv_id int=5098, @i_creacion_usuario varchar(100)='Admin', @o_tiv_id int, @o_msj varchar(200), @i_lga_id int=null
begin
	begin try
		declare @log varchar(max)
		declare @cola int
		exec @cola = bvq_administracion.BeginCola
		if exists(select * from inversion.r_int_inversion where nombre=@TPO_NUMERACION)
			raiserror('MSJ-ERROR: La inversion %s ya ha sido enviada al Sisspolweb',16,0,@TPO_NUMERACION)

		declare
			@AI_ID_EMISOR        INT = null,
			@AI_TIPO_RENTA		 INT = null,
			@AS_ID_PAPEL         VARCHAR(20)= null,
			@AI_CLASE            INT= null,
			@AI_MONEDA           CHAR(1)= null,
			@AS_CODIGO           VARCHAR(20) = null,
			@AI_UBICACION_GEO    INT = null,
			@AS_NOMBRE           VARCHAR(MAX)=NULL,
			@AS_DESCRIPCION      VARCHAR(200)=NULL,
			@AD_FECHA_INICIO     DATE = NULL,
			@AD_FECHA_EMISION	 DATE = NULL,
			@AD_FECHA_VENC	     DATE = NULL,
			@AI_PLAZO_VENCER     INT = NULL,
			@AM_PORCENT_RENTAB   MONEY = NULL,
			@AB_TIENE_CUPON      BIT = NULL,
			@AB_DESMATERIALIZADO BIT = NULL,
			@AN_TASA_VIGENCIA    NUMERIC(10,6) = NULL,
			@AM_VALOR_NOMINAL    MONEY = NULL,
			@AM_VALOR_EFECTIVO   MONEY = NULL,
			@AM_PRECIO		     DECIMAL(18,14) = NULL,
			@AI_PERIODO_GRACIA	 INT = NULL,
			@AB_COMERCIAL		 BIT = NULL,
			@AB_ANUALIDAD		 BIT = NULL,
			@AB_CAPITAL  		 BIT = NULL,
			@AB_TASA_VARIABLE	 BIT = NULL,
			@AB_LLENADO_MANUAL	 BIT = NULL,
			@AS_SERIE_DOCUMENTAL VARCHAR(500) =NULL,
			@AS_FRECUENCIA_INT	 VARCHAR(20) =NULL,
			@AS_FRECUENCIA_CAP	 VARCHAR(20) =NULL,
			@AS_ESTADO			 VARCHAR(20) =NULL,
			@AS_CREACION_USUARIO VARCHAR(50),
			@AS_CREACION_EQUIPO  VARCHAR(50),
			@AM_COMISION		 NUMERIC(18,10)=null,
			@AM_COMISION_OPERADOR NUMERIC(18,10)=null,
			@AI_TITULO_PADRE	 INT=null,
			@AB_ES_365           BIT = NULL,
			@AB_MODIFICA_INTERES BIT = NULL,
			@AB_ES_NUEVO         BIT,-- OUT, 
			@AI_TITULO			 INT,-- OUT,
			@AS_MSJ				 VARCHAR(200),
			@AS_EMS_NOMBRE		VARCHAR(200)-- OUTPUT

		select top 1
		@AI_ID_EMISOR=AI_ID_EMISOR,
		@AI_TIPO_RENTA=AI_TIPO_RENTA,
		@AS_ID_PAPEL=AS_ID_PAPEL,
		@AI_CLASE=AI_CLASE,
		@AI_MONEDA=AI_MONEDA,
		@AS_NOMBRE=AS_NOMBRE,
		@AS_CODIGO=AS_CODIGO,
		@AI_UBICACION_GEO=AI_UBICACION_GEO,
		@AS_DESCRIPCION=AS_DESCRIPCION,
		@AD_FECHA_INICIO=AD_FECHA_INICIO,
		@AD_FECHA_EMISION=AD_FECHA_EMISION,
		@AD_FECHA_VENC=AD_FECHA_VENC,
		@AI_PLAZO_VENCER=AI_PLAZO_VENCER,
		@AM_PORCENT_RENTAB=AM_PORCENT_RENTAB,
		@AB_TIENE_CUPON=AB_TIENE_CUPON,
		@AB_DESMATERIALIZADO=AB_DESMATERIALIZADO,
		@AN_TASA_VIGENCIA=AN_TASA_VIGENCIA,
		@AM_VALOR_NOMINAL=round(AM_VALOR_NOMINAL,2),
		@AM_VALOR_EFECTIVO=round(AM_VALOR_EFECTIVO,2),
		@AM_PRECIO=AM_PRECIO,
		@AI_PERIODO_GRACIA=AI_PERIODO_GRACIA,
		@AB_COMERCIAL=AB_COMERCIAL,
		@AB_ANUALIDAD=AB_ANUALIDAD,
		@AB_CAPITAL=AB_CAPITAL,
		@AB_TASA_VARIABLE=AB_TASA_VARIABLE,
		@AB_LLENADO_MANUAL=AB_LLENADO_MANUAL,
		@AS_SERIE_DOCUMENTAL=AS_SERIE_DOCUMENTAL,
		@AS_FRECUENCIA_INT=AS_FRECUENCIA_INT,
		@AS_FRECUENCIA_CAP=AS_FRECUENCIA_CAP,
		@AS_ESTADO=AS_ESTADO,
		@AS_CREACION_USUARIO=@i_creacion_usuario,
		@AS_CREACION_EQUIPO=AS_CREACION_EQUIPO,
		@AM_COMISION=AM_COMISION,
		@AM_COMISION_OPERADOR=AM_COMISION_OPERADOR,
		@AI_TITULO_PADRE=AI_TITULO_PADRE,
		@AB_ES_365=AB_ES_365,
		@AB_MODIFICA_INTERES=AB_MODIFICA_INTERES,
		@AB_ES_NUEVO=AB_ES_NUEVO,
		@AS_EMS_NOMBRE=AS_EMS_NOMBRE
		--@AI_TITULO=AI_TITULO,
		--@AS_MSJ=AS_MSJ
		from bvq_backoffice.IsspolTitulosAInsertar
		where as_nombre=@tpo_numeracion and tiv_id=@tiv_id

		--select * from bvq_backoffice.IsspolTitulosAInsertar where tiv_id=7749 and as_nombre='abo-2023-06-26-9'

		if @AI_ID_EMISOR is null and isnull(@AS_EMS_NOMBRE,'')<>''
			raiserror('MSJ-ERROR: El emisor ''%s'' no se encuentra en Siisspolweb',16,0,@AS_EMS_NOMBRE)
		if @AS_ID_PAPEL is null
			raiserror('MSJ-ERROR: No existe el tipo de papel en Siisspolweb',16,0)
	
		--58          rfMinDist
		declare @OUT_AI_TITULO INT
		declare @OUT_AS_MSJ VARCHAR(200)
		declare @insertarTituloRet int
		set @log='OUT_AI_TITULO:'+rtrim(@OUT_AI_TITULO)
		exec bvq_administracion.isspolenviolog @log
		exec @insertarTituloRet=inversion.r_proc_insertar_titulo
				@AI_ID_EMISOR=@AI_ID_EMISOR--'4031'
			,@AI_TIPO_RENTA=@AI_TIPO_RENTA--1
			,@AS_ID_PAPEL=@AS_ID_PAPEL--1
			,@AI_CLASE=null
			,@AI_MONEDA='D'
			,@AS_CODIGO=@AS_CODIGO--'TEST-DAN-30-08-2023'
			,@AS_NOMBRE=@AS_NOMBRE--'TEST-DAN-30-08-2023'
			,@AI_UBICACION_GEO=280
			,@AS_DESCRIPCION=''
			,@AD_FECHA_INICIO=@AD_FECHA_INICIO--'20190401'
			,@AD_FECHA_EMISION=@AD_FECHA_EMISION--'20190401'
			,@AD_FECHA_VENC=@AD_FECHA_VENC--'20240401'
			,@AI_PLAZO_VENCER=@AI_PLAZO_VENCER--1827
			,@AM_PORCENT_RENTAB=NULL
			,@AB_TIENE_CUPON=@AB_TIENE_CUPON--0
			,@AB_DESMATERIALIZADO=@AB_DESMATERIALIZADO--1
			,@AN_TASA_VIGENCIA=@AN_TASA_VIGENCIA--10
			,@AM_VALOR_NOMINAL=@AM_VALOR_NOMINAL--500000
			,@AM_VALOR_EFECTIVO=@AM_VALOR_EFECTIVO--500000
			,@AM_PRECIO=@AM_PRECIO--0
			,@AI_PERIODO_GRACIA=@AI_PERIODO_GRACIA--0
			,@AB_COMERCIAL=@AB_COMERCIAL--0
			,@AB_ANUALIDAD=@AB_ANUALIDAD--0
			,@AB_CAPITAL=@AB_CAPITAL--0
			,@AB_TASA_VARIABLE=@AB_TASA_VARIABLE--0
			,@AB_LLENADO_MANUAL=@AB_LLENADO_MANUAL--1
			,@AS_SERIE_DOCUMENTAL=@AS_SERIE_DOCUMENTAL--''
			,@AS_FRECUENCIA_INT=@AS_FRECUENCIA_INT--NULL
			,@AS_FRECUENCIA_CAP=@AS_FRECUENCIA_CAP--'TR'
			,@AS_ESTADO='2'
			,@AS_CREACION_USUARIO=@AS_CREACION_USUARIO
			,@AS_CREACION_EQUIPO=@AS_CREACION_EQUIPO--'129.168.2.114'
			,@AM_COMISION=NULL
			,@AM_COMISION_OPERADOR=@AM_COMISION_OPERADOR
			,@AI_TITULO_PADRE=NULL
			,@AB_ES_365=@AB_ES_365
			,@AB_MODIFICA_INTERES=@AB_MODIFICA_INTERES--0
			,@AB_ES_NUEVO=@AB_ES_NUEVO--1
			,@AI_TITULO=@OUT_AI_TITULO output
			,@AS_MSJ=@OUT_AS_MSJ output
		set @o_msj=@OUT_AS_MSJ
		if(@insertarTituloRet<0)
		begin
			declare @err varchar(250)=isnull(@o_msj,'') + ' - ' + isnull(@AS_NOMBRE,'')
			raiserror(@err, 16, 0)
			return @insertarTituloRet
		end
		exec bvq_administracion.EnviarMsj @cola,'proc_insertar_titulo',@OUT_AI_TITULO,1,'inversion.titulo'
		declare @v_fecha datetime
		select @v_fecha=fecha
		from bvq_backoffice.IsspolAInsertar
		where nombre=@tpo_numeracion and tiv_id=@tiv_id
	
		declare @v_id_efectivo int=null
		declare @insertarEfectivoRet int
		exec bvq_administracion.IsspolEnvioLog 'call IsspolInsertarEfectivo'
		exec @insertarEfectivoRet = BVQ_BACKOFFICE.IsspolInsertarEfectivo @v_fecha, @i_creacion_usuario, @cola, @v_id_efectivo out, @o_msj out
			
		declare @v_creacion_fecha datetime=getdate()
		insert into inversion.r_int_inversion(
			nombre,fecha,total_inversion,observaciones,creacion_fecha,creacion_usuario,creacion_equipo,modifica_fecha,modifica_usuario,modifica_equipo,id_titulo
			,valor_inversion_titulo,comision,comision_operador,estado_inversion)
		select --t.fecha_vencimiento,fecha,total_inversion,fecha_vencimiento,*
		--r,tiv_tipo_valor,
		top 1 nombre,fecha
		,round(total_inversion,2)
		,observaciones
		,creacion_fecha=@v_creacion_fecha
		,@i_creacion_usuario
		--,null
		,creacion_equipo
		,modifica_fecha=@v_creacion_fecha
		,@i_creacion_usuario
		,modifica_equipo,@OUT_AI_TITULO
		,valor_inversion_titulo=round(valor_inversion_titulo,2)
		,comision=round(comision,2)
		,comision_operador=round(comision_operador,2)
		,estado_inversion
		--r,tiv_tipo_valor
		from bvq_backoffice.IsspolAInsertar
		where nombre=@tpo_numeracion and tiv_id=@tiv_id

		exec bvq_administracion.IsspolEnvioLog 'after insert int_inversion'
		declare @v_id_int_inversion int
		select top 1 @v_id_int_inversion=id_int_inversion from inversion.r_int_inversion where nombre=@AS_NOMBRE and creacion_fecha=@v_creacion_fecha
		set @log='v_id_int_inversion '+rtrim(@v_id_int_inversion)
		exec bvq_administracion.isspolenviolog @log

		--colocar id_int_inversion en la inversión de Sicav
		update bvq_backoffice.fondo set FON_ID_INT_INVERSION=@v_id_int_inversion
		where FON_NUMERACION=@tpo_numeracion and FON_TIV_ID=@tiv_id


		if @v_id_int_inversion is null
		begin
			set @o_msj = formatmessage('MSJ-ERROR: No se pudo insertar la inversión %s en la tabla de integración de la inversión',@AS_NOMBRE)
			raiserror(@o_msj, 16, 0)
			return -1
		end
		else
		begin
			exec bvq_administracion.EnviarMsj @cola,'InsertarIntInversion',@v_id_int_inversion,3,'inversion.int_inversion'
		end

		--select 'id_int_inversion: '+rtrim(@OUT_AI_ID_INT_INVERSION)


		insert into inversion.r_int_inversion_fondo_inversion(
				id_int_inversion,id_seguro_tipo,montoInversion,porcentaje,interes_transcurrido,creacion_fecha,creacion_usuario
			,creacion_equipo,modifica_fecha,modifica_usuario,modifica_equipo)
		select
			@v_id_int_inversion--b.id_int_inversion
		,pct.id_seguro_tipo--=seg
		,montoInversion=round(precioCompra*htp_compra,2)--porcentaje*total_inversion
		,porcentaje=precioCompra*htp_compra/b.TOTAL_INVERSION*100.0
		,itrans
		--,nombre
		,CREACION_FECHA
		,CREACION_USUARIO=@i_creacion_usuario
		,CREACION_EQUIPO
		,modifica_fecha
		,modifica_usuario=@i_creacion_usuario
		,modifica_equipo
		--,r
		from bvq_backoffice.IsspolAInsertar b
		left join bvq_backoffice.IsspolSicav pct
		on b.nombre=pct.TPO_NUMERACION and b.tiv_id=pct.tiv_id
		where b.nombre=@tpo_numeracion and b.tiv_id=@tiv_id
		exec bvq_administracion.EnviarMsj @cola,'InsertarIntInversionFondoInversion',@v_id_int_inversion,4,'inversion.int_inversion_fondo_inversion'


		exec BVQ_BACKOFFICE.IsspolInsertarFlujoCaja @AS_NOMBRE, @v_fecha, @i_creacion_usuario, @cola, @i_lga_id
		exec bvq_administracion.EnviarMsj @cola,'InsertarFlujoCaja',@v_id_efectivo,5,'flujocaja.caja'


		set @o_tiv_id = @v_id_int_inversion--@OUT_AI_ID_INT_INVERSION
		set @o_msj=''
	end try
	begin catch
		if ERROR_NUMBER()<50000
		begin
			set @o_msj = 'Error inesperado';
			--log
		end
		else
		begin
			set @o_msj=ERROR_MESSAGE();
		end;
		exec bvq_administracion.ColaRollback @cola;
		throw;
	end catch
end
