-- ===========================================================================
-- Author:		Pablo Sanmartin
-- Create date: 15/12/2008
-- Description:	cambia de estado la orden de negociación
-- History:		GCA: 28-oct-2009:	Se cambia para que se cancelen los titulos de historico_titulos_portafolio
--				GCA: 21-abr-2010: Se aumenta variable categoría para NIFs
--				PSA: 08/01/2013 : Cambia estado al historico validando numeración
-- ===========================================================================
CREATE PROCEDURE [BVQ_BACKOFFICE].[CancelarTituloPortafolio]
	 @i_tpo_id int
	,@i_precio float=100
	,@i_cantidad float=-1
	,@i_rendimiento float=0
	,@i_tir	float=0
	,@i_rendimiento_retorno float=0
	,@i_fecha datetime
	,@i_lga_id int=null
AS
BEGIN
	
	SET NOCOUNT ON;	


	DECLARE @v_id_cancelado int;

	EXEC @v_id_cancelado = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
	@i_code = N'BCK_ES_TIT_POR',
	@i_status = N'C';

	DECLARE @v_id_activo int;

	EXEC @v_id_activo = [BVQ_ADMINISTRACION].ObtenerIdEstadoCatalogo
	@i_code = N'BCK_ES_TIT_POR',
	@i_status = N'A';

	print @v_id_activo
	print @v_id_cancelado

	EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = N'TITULOS_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'U',
		@i_subTipo = N'A',
		@i_columIdName = N'TPO_ID',
		@i_idAfectado = @i_tpo_id;	


	declare @v_por_id int
	declare @v_tiv_id int
	declare @v_cupon  bit
	DECLARE @v_numeracion varchar(255);

	-- NIF
	declare @v_categoria int
	-- FIN NIF

	select @v_por_id = por_id,	@v_tiv_id = tiv_id, @v_cupon = HTP_CUPON, @v_numeracion = HTP_NUMERACION
	
	-- NIF
	, @v_categoria = HTP_CATEGORIA
	-- FIN NIF

	from [BVQ_BACKOFFICE].[HISTORICO_TITULOS_PORTAFOLIO]
	where HTP_ID = @i_tpo_id
	and	HTP_ESTADO = @v_id_activo;

	 EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = N'TITULOS_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'U',
		@i_subTipo = N'A',
		@i_columIdName = N'TPO_ID',
		@i_idAfectado = @i_tpo_id;


	 EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = N'TITULOS_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'U',
		@i_subTipo = N'N',
		@i_columIdName = N'TPO_ID',
		@i_idAfectado = @i_tpo_id;

	declare @i_fecha_c datetime
	set @i_fecha_c=bvq_administracion.ObtenerFechaSistema()
	truncate table corteslist
	
	insert into corteslist(c,cortenum) select @i_fecha_c, null-- from _temp.corteslist
	exec bvq_administracion.GenerarCompraVentaCorte
	insert bvq_backoffice.historico_titulos_portafolio
	(
	POR_ID,
	TIV_ID,
	HTP_FECHA_OPERACION,
	HTP_COMPRA,
	HTP_PRECIO_COMPRA,

	HTP_VENTA,
	HTP_PRECIO_VENTA,
	HTP_SALDO,
	LIQ_ID,
	HTP_ESTADO,

	HTP_CUPON,
	HTP_REPORTADO,
	HTP_CATEGORIA,
	HTP_PRECIO_SUCIO,
	HTP_PRECIO_SUCIO_VAL,

	HTP_NUMERACION,
	old_htp_id,
	htp_tpo_id,
	htp_tfl_id,
	htp_rendimiento,
	htp_tir,
	htp_rendimiento_retorno
	)
	select
	a.por_id,
	a.tiv_id,
	@i_fecha,
	0,
	0,

	case when @i_cantidad=-1 then sal else abs(@i_cantidad) end,
	@i_precio,
	0,
	null,
	352,

	a.tpo_cobro_cupon,
	0,
	a.tpo_categoria,
	null,
	null,

	htp_numeracion,
	null,
	httpo_id,
	null,
	@i_rendimiento,
	@i_tir,
	@i_rendimiento_retorno
	from bvq_backoffice.PortafolioCorte a
		inner join bvq_backoffice.titulos_portafolio tpo on httpo_id=tpo_id
		/* UPDATE BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO
		 set HTP_ESTADO = @v_id_cancelado*/
		 WHERE a.por_id = @v_por_id
		 AND	a.tiv_id = @v_tiv_id
		 --AND	HTP_CUPON = @v_cupon
		 --AND	HTP_ESTADO = @v_id_activo
		 AND	isnull(HTP_NUMERACION,'') = isnull(@v_numeracion,'')
		-- NIF
		 --AND HTP_CATEGORIA = @v_categoria
		-- FIN NIF

	if exists(select * from BVQ_ADMINISTRACION.PARAMETRO WHERE PAR_CODIGO='SEPARAR_EN_COMPRAS' AND PAR_VALOR='SI')
	BEGIN
		UPDATE HTP SET HTP_NUMERACION=g.HTP_NUMERACION
		FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HTP
		JOIN BVQ_BACKOFFICE.GrupoCompras g ON g.POR_ID=@v_por_id and g.TIV_ID=@v_tiv_id
		and case when charindex(' id:',g.htp_numeracion)>0 then substring(g.HTP_NUMERACION,1,charindex(' id:',g.HTP_NUMERACION)-1) else g.htp_numeracion END =@v_numeracion
		WHERE charindex(' id:',htp.htp_numeracion)=0 and HTP.HTP_ID=scope_identity()
	END

END