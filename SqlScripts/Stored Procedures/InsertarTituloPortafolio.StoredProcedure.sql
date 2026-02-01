-- =============================================
-- Author:		Pablo Sanmartin
-- Create date: 10/12/2008
-- Description:	Inserta un título al portafolio
-- Parametros:  
-- MODIFICACION: JIMMY CHUICO 06/17/2009 para que inserte los datos del portafolio en el historico
--				 JCH 04/08/2009 Para que inserte los datos del efectivo de un  portafolio 
--				 GCA: 28-oct-2009 Se cambia la inserción en la tabla HISTORICO_TITULOS_PORTAFOLIO para que 
--								actualice el registro de mismo titulo del mismo portafolio con el mismo cupón.
--								Se usa solamente desde la pantalla de modificar o crear el portafolio, es decir antes 
--								de que se adjunte el contrato.
--				JCH: 20/Abr/2010 Para insertar al categoria cuando se tenga ambinentes NIF
--				EMN: 14/Sep/2011 No consolida movimientos del mismo título en un solo movimiento si es portafolio propio,
--								aunque no tenga contrato
--				PSA: Insertar título portafolio
--				PSA: Inserta campo renovado por
--				PSA: 28/02/2024 Inserta tpoId origen
-- =============================================
CREATE PROCEDURE [BVQ_BACKOFFICE].[InsertarTituloPortafolio]
	 @i_usr_id int
	,@i_tiv_id int
	,@i_por_id int
	,@i_cantidad float
	,@i_precio_ingreso float
	,@i_fecha_ingreso datetime	
	,@i_cobro_cupon bit
	,@i_confirn_title bit
	,@i_dirty_price bit
	,@i_dirty_price_val float	
	,@i_numeracion varchar(max)
	,@i_categoria	int = NULL
	,@i_rendimiento float = NULL
	,@i_renovadopor varchar(50) = NULL
	
	,@i_numeracion2 varchar(50) = NULL
	,@i_comisionBolsa float	
	,@i_tir	float=0
	,@i_rendimiento_retorno float=0

	,@i_comisionCompromiso float
	,@i_comisionFinanciamiento float
	,@i_comisionEvaluacion float
	,@i_participacion float
	
	,@i_montoEmision float
	,@i_objeto varchar(max)
	

	,@i_amortizarMontoTotal bit
	,@i_saldoEnFilaAnterior bit
	,@i_oferta_id int=null
	,@i_liq_id int=null
	,@i_recursos varchar(30)=null

	---campos adicionales
	
	,@i_tpo_fecha_ven_convenio datetime = null		
	,@i_tpo_fecha_susc_convenio datetime = null		
	,@i_tpo_intervinientes varchar(255) = null		
	,@i_tpo_interes_transcurrido float = null		
	,@i_tpo_precio_ultima_compra float = null		
	,@i_tpo_cupon_vector float = null		
	,@i_tpo_acta varchar(10) = null		
	,@i_tpo_otros_costos float = null		
	,@i_tpo_comisiones float = null		
	,@i_tpo_abono_interes float = null		
	,@i_tpo_valnom_anterior float = null		
	,@i_tpo_fecha_encargo datetime = null		
	,@i_tpo_boletin varchar(20) = null
	,@i_tiv_id_origen	int = null
	,@i_fon_numero_liquidacion varchar(10) = null
	,@i_fon_procedencia char(1) = null
	,@i_nombre_bono_global varchar(100) = null
	,@i_dividendo bit
	,@i_cxc bit
	,@i_lga_id int
AS
BEGIN

	SET NOCOUNT ON;	


	DECLARE @v_id_estado int, @v_monId int, @v_saldo float, @v_saldo_efectivo float, @v_tpoId_org int;

	if @i_tpo_fecha_ven_convenio='01/01/1900'  set @i_tpo_fecha_ven_convenio = null
	if @i_tpo_fecha_susc_convenio='01/01/1900'  set @i_tpo_fecha_susc_convenio = null
	if @i_tpo_fecha_encargo='01/01/1900'  set @i_tpo_fecha_encargo = null

	IF(@i_tiv_id_origen IS NOT NULL)
	BEGIN
		SELECT TOP 1 @v_tpoId_org=TPO_ID
		FROM [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO] TP
		INNER JOIN BVQ_ADMINISTRACION.ITEM_CATALOGO EST ON EST.ITC_ID = TP.TPO_ESTADO AND EST.ITC_CODIGO = 'A'
		WHERE TP.TIV_ID=@i_tiv_id_origen AND TP.POR_ID = @i_por_id
	END


	EXEC @v_id_estado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
	@i_code = N'BCK_ES_TIT_POR',
	@i_status = N'A';
	print @v_id_estado

	set @v_saldo=bvq_backoffice.fnObtenerSaldoTituloPortafolio
	(
		@i_por_id,
		@i_tiv_id,
		@i_cobro_cupon,
		@v_id_estado,
		@i_numeracion
	)			

	declare @v_tpo_id int
	if not exists
		(
			select 1 from BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
			where
				POR_ID = @i_por_id and
				TIV_ID = @i_tiv_id and
				HTP_CUPON = @i_cobro_cupon and
				HTP_ESTADO = @v_id_estado and
				HTP_NUMERACION = @i_numeracion
		)
	begin
			declare @v_fon_id int=(
				select fon_id from bvq_backoffice.fondo
				where fon_tiv_id=@i_tiv_id and fon_numeracion=@i_numeracion
			)
			if @v_fon_id is null
			begin
				insert into bvq_backoffice.fondo(
					  fon_tiv_id
					, fon_numeracion
					, FON_NUMERO_LIQUIDACION
					, FON_PROCEDENCIA
					)
				values (
					  @i_tiv_id
					, @i_numeracion
					, @i_fon_numero_liquidacion
					, @i_fon_procedencia
				)
				set @v_fon_id=scope_identity()
			end

			INSERT INTO [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
           (
				USR_ID,
				TIV_ID,
				POR_ID,
				TPO_CANTIDAD,
				TPO_PRECIO_INGRESO,
				TPO_FECHA_INGRESO,
				TPO_FECHA_REGISTRO,
				TPO_ESTADO,
				TPO_ULTIMA_REVALUACION,
				TPO_COBRO_CUPON,
				TPO_CONFIRMA_TITULO,
				TPO_PRECIO_SUCIO,
				TPO_PRECIO_SUCIO_VAL,
				TPO_NUMERACION,
				TPO_CATEGORIA,
				TPO_RENOVADO_DE,
				TPO_COMISION_BOLSA,
				TPO_OFERTA_ID,
				FON_ID,
				--campos adicionales Isspol
				TPO_FECHA_VEN_CONVENIO,
				TPO_FECHA_SUSC_CONVENIO,
				TPO_INTERVINIENTES,
				TPO_INTERES_TRANSCURRIDO,
				TPO_PRECIO_ULTIMA_COMPRA,
				TPO_CUPON_VECTOR,
				TPO_ACTA,
				TPO_OTROS_COSTOS,
				TPO_COMISIONES,
				TPO_ABONO_INTERES,
				TPO_VALNOM_ANTERIOR,
				TPO_FECHA_ENCARGO,
				TPO_BOLETIN,
				tpo_id_anterior,
				TPO_NOMBRE_BONO_GLOBAL,
				TPO_RECURSOS,
				TPO_PROG
           )
			 VALUES
           (
				@i_usr_id,
				@i_tiv_id,
				@i_por_id,
				@i_cantidad,
				@i_precio_ingreso,
				@i_fecha_ingreso,
				BVQ_ADMINISTRACION.ObtenerFechaSistema(),
				@v_id_estado,
				null,
				@i_cobro_cupon,
				@i_confirn_title,
				@i_dirty_price,
				@i_dirty_price_val,			   
				@i_numeracion,
				@i_categoria,
				@i_renovadopor,
				@i_comisionBolsa,
				@i_oferta_id,
				@v_fon_id,

				--campos adicionales Isspol
				@i_tpo_fecha_ven_convenio,		
				@i_tpo_fecha_susc_convenio,	
				@i_tpo_intervinientes,
				@i_tpo_interes_transcurrido,	
				@i_tpo_precio_ultima_compra,	
				@i_tpo_cupon_vector,	
				@i_tpo_acta,	
				@i_tpo_otros_costos,		
				@i_tpo_comisiones,		
				@i_tpo_abono_interes,		
				@i_tpo_valnom_anterior,	
				@i_tpo_fecha_encargo,
				@i_tpo_boletin,
				@v_tpoId_org,
				@i_nombre_bono_global,
				@i_recursos,
				case when @i_cxc = 1 then 'normal' else null end
           )
			set @v_tpo_id=scope_identity()
	end
	else
	begin
		
			
		UPDATE [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
		SET
		TPO_CANTIDAD = @v_saldo	+ @i_cantidad,
		TPO_PRECIO_INGRESO = @i_precio_ingreso,
		TPO_FECHA_INGRESO = @i_fecha_ingreso,
		TPO_FECHA_REGISTRO = BVQ_ADMINISTRACION.ObtenerFechaSistema(),
		TPO_COBRO_CUPON = @i_cobro_cupon,		
		TPO_NUMERACION =@i_numeracion,
		TPO_CATEGORIA = @i_categoria,
		TPO_RENOVADO_DE = @i_renovadopor,
		TPO_COMISION_BOLSA = @i_comisionBolsa,
		TPO_OFERTA_ID = @i_oferta_id,
		tpo_id_anterior = @v_tpoId_org,
		TPO_RECURSOS = @i_recursos
		where
			POR_ID = @i_por_id and
			TIV_ID = @i_tiv_id and
			TPO_COBRO_CUPON = @i_cobro_cupon and
			TPO_ESTADO = @v_id_estado and
			TPO_NUMERACION = @i_numeracion
		
		select @v_tpo_id=TPO_ID
		FROM BVQ_BACKOFFICE.TITULOS_PORTAFOLIO
		where
			POR_ID = @i_por_id and
			TIV_ID = @i_tiv_id and
			TPO_COBRO_CUPON = @i_cobro_cupon and
			TPO_ESTADO = @v_id_estado and
			TPO_NUMERACION = @i_numeracion
	end

	exec bvq_backoffice.CancelarTpoAnterior @v_tpoid_org, @i_fecha_ingreso

	if @i_cantidad=0
		raiserror('La cantidad no puede ser 0',16,1)

	INSERT INTO BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
	(
		HTP_TPO_ID,
		POR_ID,
		TIV_ID,
		HTP_FECHA_OPERACION,
		HTP_COMPRA, 
		HTP_PRECIO_COMPRA , 
		HTP_VENTA, 
		HTP_PRECIO_VENTA, 
		HTP_SALDO,
		HTP_ESTADO,
		HTP_CUPON,
		HTP_PRECIO_SUCIO,
		HTP_PRECIO_SUCIO_VAL,
		HTP_NUMERACION,
		HTP_CATEGORIA,
		HTP_RENDIMIENTO,
		HTP_COMISION_BOLSA,
		HTP_TIR,
		HTP_RENDIMIENTO_RETORNO
		,LIQ_ID,
		HTP_DIVIDENDO
	)
	VALUES
	(
		@v_tpo_id,
		@i_por_id,
		@i_tiv_id,
		@i_fecha_ingreso,
		@i_cantidad,
		@i_precio_ingreso,
		0,
		0,
		@v_saldo+@i_cantidad,
		@v_id_estado,
		@i_cobro_cupon,
		@i_dirty_price,
		@i_dirty_price_val,
		@i_numeracion,
		@i_categoria,
		@i_rendimiento,
		@i_comisionBolsa,
		@i_tir,
		@i_rendimiento_retorno
		,@i_liq_id,
		@i_dividendo
	)

	EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
	@i_lga_id = @i_lga_id,
	@i_tabla = 'HISTORICO_TITULOS_PORTAFOLIO',
	@i_esquema = N'BVQ_BACKOFFICE',
	@i_operacion = N'I',
	@i_subTipo = N'N',
	@i_columIdName = 'HTP_ID',
	@i_idAfectado = @@IDENTITY;


	if exists(select * from bvq_administracion.parametro where par_codigo='SEPARAR_EN_COMPRAS' and par_valor='SI')
	begin
		declare @v_numeracion varchar(250);
		select @v_numeracion = case when charindex(' id:',htp_numeracion)>0 then left(htp_numeracion,charindex(' id:',htp_numeracion)-1) else htp_numeracion end
		from bvq_backoffice.historico_titulos_portafolio where htp_id=scope_identity()

		update tpo set tpo_numeracion=@v_numeracion + ' id:' + rtrim(scope_identity()) 
		from bvq_backoffice.titulos_portafolio tpo
		where TPO.TPO_ID=@v_tpo_id
		
		update bvq_backoffice.historico_titulos_portafolio 
		set htp_numeracion=@v_numeracion + ' id:' + rtrim(scope_identity()) 
		where htp_id=scope_identity()

		exec bvq_backoffice.GenerarCompraVentaPortafolio
		exec bvq_administracion.GenerarTituloFlujoComun
		exec bvq_administracion.GenerarTasaValorCompact
		exec bvq_backoffice.GenerarCompraVentaFlujo

		
		update htp set htp_numeracion=isnull(htp.htp_numeracion,'')+' id:'+rtrim(htp.htp_id)
		from bvq_backoffice.grupocompras htp
		where charindex(' id:',htp.htp_numeracion)=0 and htp.htp_fecha_operacion>'2016-09-01T23:59:59'

		exec _temp.refreshtpo
		update htp set htp_tpo_id=tpo_id1 from bvq_backoffice.duptpos d join bvq_backoffice.historico_titulos_portafolio htp on htp.htp_id=htp_id0
		delete tpo from bvq_backoffice.titulos_portafolio tpo left join bvq_backoffice.historico_titulos_portafolio htp on tpo_id_c=tpo_id where tpo_id_c is null

		update htp set compra_htp_id=compra.htp_id from bvq_backoffice.historico_titulos_portafolio htp join
		bvq_backoffice.historico_titulos_portafolio compra
		join bvq_administracion.titulo_valor tiv on compra.tiv_id=tiv.tiv_id
		on htp.htp_tpo_id=compra.htp_tpo_id and compra.htp_estado=352 and compra.htp_compra>0 and tiv_fecha_vencimiento is not null
	end
	update htp set htp_tpo_id=tpo_id_c from bvq_backoffice.historico_titulos_portafolio htp where tpo_id_c<>htp_tpo_id or htp_tpo_id is null and tpo_id_c is not null

	--
	--declare @v_tpo_id int = 2241
	--declare @i_fecha_ingreso datetime ='2025-02-14T00:00:00'
	--select * from corteslist
	--select sal,fecha_vencimiento,fecha_compra--*
	update tpo set tpo_fecha_compra_anterior=s.fecha_compra, tpo_fecha_vencimiento_anterior=s.fecha_vencimiento
	from bvq_backoffice.titulos_portafolio tpo-- where tpo_id=2241
	join (
		select htp_tpo_id, sal=sum(montooper),fecha_compra=min(htp_fecha_operacion),fecha_vencimiento=max(e.tiv_fecha_vencimiento)
		from bvq_backoffice.eventoportafolio e
		where htp_fecha_operacion<@i_fecha_ingreso group by htp_tpo_id
	) s on s.htp_tpo_id=tpo.tpo_id_anterior--bvq_backoffice.portafoliocorte pc on tpo.tpo_id=pc.httpo_id
	where tpo.tpo_id=@v_tpo_id and tpo.tpo_numeracion like 'plaza_proyec%'
	--



END
