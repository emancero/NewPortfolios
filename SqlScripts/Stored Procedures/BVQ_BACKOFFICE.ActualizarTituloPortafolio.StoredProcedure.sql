-- =============================================
-- Author:		Pablo Sanmartin
-- Create date: 13/11/2008
-- Description:	actualiza orden de negociación
-- Parametros: 
-- MODIFICACION:	JIMMY CHUICO 06/17/2009 para que actulice los datos del portafolio en el historico  
--					JCH 04/08/2009 Para que actualice los datos del efectivo de un  portafolio.
--					JCH: 20/Abr/2010 Para insertar al categoria cuando se tenga ambinentes NIF
--					PSA: 20/11/2012	Precio Sucio
--					PSA: 11/12/2012	Inserta numeración para papeles desmaterializados
--					PSA: 20/06/2014 Elimina el campo TPO_SALDO
--					PSA: 12/11/2017	Actualiza el campo renovado por
-- =============================================
CREATE PROCEDURE [BVQ_BACKOFFICE].[ActualizarTituloPortafolio]	
	 @i_tpo_id int
	,@i_usr_id int
	,@i_tiv_id int
	,@i_por_id int
	,@i_cantidad float
	,@i_precio_ingreso float	
	,@i_cobro_cupon bit
	,@i_dirty_price bit
	,@i_dirty_price_val float
	,@i_numeracion varchar(250)
	-- NIF
	,@i_categoria	int = NULL
	-- FIN NIF
	,@i_rendimiento float = NULL
	,@i_fecha datetime
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
	,@i_oferta_id int = null
	
	,@i_lga_id int
	
AS
BEGIN
	
	SET NOCOUNT ON;	
	 DECLARE @v_monId int, @v_saldo_efectivo float, @v_valefec int ;

	EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = N'TITULOS_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'U',
		@i_subTipo = N'A',
		@i_columIdName = N'TPO_ID',
		@i_idAfectado = @i_tpo_id;
		
	

	UPDATE [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO]
	SET [USR_ID] = @i_usr_id
		  ,[TIV_ID] = @i_tiv_id
		  ,[POR_ID] = @i_por_id
		  ,[TPO_CANTIDAD] = @i_cantidad
		  ,[TPO_PRECIO_INGRESO] = @i_precio_ingreso
		  ,[TPO_FECHA_INGRESO] = @i_fecha
		  ,[TPO_COBRO_CUPON] = @i_cobro_cupon		  
		  ,[TPO_PRECIO_SUCIO] = @i_dirty_price
		  ,[TPO_PRECIO_SUCIO_VAL] = @i_dirty_price_val
		  ,[TPO_NUMERACION] = @i_numeracion
		  --NIF
		  ,[TPO_CATEGORIA] = @i_categoria
		  --FIN NIF
		  ,TPO_RENOVADO_DE = @i_renovadopor
		  ,TPO_CATEGORIA_INVERSION=(select civ_id from bvq_backoffice.CivCatMap map where cat_id=@i_categoria)
		  ,TPO_COMISION_BOLSA = @i_comisionBolsa
		  ,TPO_NUMERACION_2 = @i_numeracion2
		  ,TPO_COMISION_COMPROMISO = @i_comisionCompromiso
		  ,TPO_COMISION_FINANCIAMIENTO = @i_comisionFinanciamiento
		  ,TPO_COMISION_EVALUACION = @i_comisionEvaluacion
		  ,TPO_PARTICIPACION = @i_participacion
		  ,TPO_MONTO_EMISION = @i_montoEmision
		  ,TPO_OBJETO = @i_objeto
		  ,TPO_OFERTA_ID = @i_oferta_id
	 FROM [BVQ_BACKOFFICE].[TITULOS_PORTAFOLIO] TPO
	 JOIN BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HTP ON HTP.HTP_TPO_ID=TPO.TPO_ID
	 WHERE HTP.HTP_ID = @i_tpo_id;

	UPDATE HTP
	SET HTP_FECHA_OPERACION = @i_fecha,
		HTP_COMPRA = case when @i_cantidad>0 then @i_cantidad else 0 end,
		HTP_PRECIO_COMPRA = case when @i_cantidad>0 then @i_precio_ingreso else 0 end,
        HTP_VENTA = case when @i_cantidad>0 then 0 else (@i_cantidad*-1) end,
		HTP_PRECIO_VENTA = case when @i_cantidad>0 then 0 else @i_precio_ingreso end,
		HTP_SALDO = 0,
		HTP_CUPON = @i_cobro_cupon,
		HTP_PRECIO_SUCIO = @i_dirty_price,
		HTP_PRECIO_SUCIO_VAL = @i_dirty_price_val,
		HTP_NUMERACION = @i_numeracion
		-- NIF
		,HTP_CATEGORIA = @i_categoria
		-- FIN NIF
		,HTP_RENDIMIENTO = @i_rendimiento
		,HTP_RENOVADO_DE = @i_renovadopor
		,HTP_COMISION_BOLSA = @i_comisionBolsa
		,HTP_TIR = @i_tir
		,HTP_RENDIMIENTO_RETORNO = @i_rendimiento_retorno
		,HTP_NUMERACION_2 = @i_numeracion2
	FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HTP
	--WHERE htp_id in (select htp_id from bvq_backoffice.htptpo where tpo_id=@i_tpo_id)
	WHERE HTP_ID=@i_tpo_id
/*		
	WHERE POR_ID = @i_por_id
	AND TIV_ID = @i_tiv_id
	AND	HTP_CUPON = @i_cobro_cupon
*/
		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = N'TITULOS_PORTAFOLIO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'U',
		@i_subTipo = N'N',
		@i_columIdName = N'TPO_ID',
		@i_idAfectado = @i_tpo_id;
		
	if exists(select * from BVQ_ADMINISTRACION.PARAMETRO WHERE PAR_CODIGO='SEPARAR_EN_COMPRAS' AND PAR_VALOR='SI')
	BEGIN
		UPDATE HTP SET HTP_NUMERACION=g.HTP_NUMERACION
		FROM BVQ_BACKOFFICE.HISTORICO_TITULOS_PORTAFOLIO HTP
		JOIN BVQ_BACKOFFICE.GrupoCompras g ON g.POR_ID=@i_por_id and g.TIV_ID=@i_tiv_id
		and case when charindex(' id:',g.htp_numeracion)>0 then substring(g.HTP_NUMERACION,1,charindex(' id:',g.HTP_NUMERACION)-1) else g.htp_numeracion END =@i_numeracion
		WHERE charindex(' id:',htp.htp_numeracion)=0 and HTP.HTP_ID=@i_tpo_id
	END
	
	exec _temp.refreshtpo

END