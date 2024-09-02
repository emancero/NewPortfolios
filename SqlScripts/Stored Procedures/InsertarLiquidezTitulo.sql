CREATE PROCEDURE BVQ_BACKOFFICE.InsertarLiquidezTitulo
	(
		@i_evt_id	   BIGINT,
		--@i_htp_numero  VARCHAR(100),
		@i_fecha_cobro DATETIME,
		@i_tipo		   INT,
		@i_monto	   FLOAT,
		@i_dpl_abono   BIT = NULL,
		@i_evp_uso_fondos float = NULL,
		@i_evp_rendimiento float = NULL,
		@i_evp_costas_judiciales float = NULL,
		@i_evp_costas_judiciales_referencia varchar(100) = NULL,
		@i_lga_id	   INT = NULL
	)
AS
	BEGIN
		DECLARE @v_evt_id INT,
				@o_vep_id INT,
				@o_cta_id INT,
				@o_com_id INT
		EXEC BVQ_BACKOFFICE.InsertarLiquidezPortafolio
			@i_evp_id = NULL,
			@i_evt_id = @i_evt_id,
			@i_oper_id = 1,
			@i_es_vencimiento_interes = @i_tipo,
			@i_por_id = NULL,
			@i_cobrado = 1,
			@i_fecha = @i_fecha_cobro,
			@i_monto = @i_monto,
			@i_renovacion = 0,
			@i_observaciones = NULL,
			@i_numero_documento = NULL,
			@i_ttl_id = NULL,
			@i_cuenta = NULL,
			@i_retencion = NULL,
			@i_delete = NULL,
			@i_vep_id = NULL,
			@i_cliente_id = NULL,
			@i_inLiquidity = NULL,
			@o_vep_id = @o_vep_id OUT,
			@o_cta_id = @o_cta_id OUT,
			@o_com_id = @o_com_id OUT,
			@i_duplica = @i_dpl_abono,
			@i_evp_uso_fondos = @i_evp_uso_fondos,
			@i_evp_rendimiento = @i_evp_rendimiento,
			@i_lga_id = @i_lga_id,
			@i_evp_costas_judiciales = @i_evp_costas_judiciales,
			@i_evp_costas_judiciales_referencia = @i_evp_costas_judiciales_referencia
		--recuperar default borrado temporalmente si existe (es decir si es cxc)
		update d set fecha=@i_fecha_cobro
		from bvq_backoffice.EventoPortafolioDefaults d
		where d.htp_id=@i_evt_id and fecha='29991231'

	END
