CREATE procedure [BVQ_ADMINISTRACION].[InsertarCapitalSuscritoEmisor](
	@i_emsId int,
	@i_tipo varchar(2) = null,
	@i_valor_nominal float = null, 
	@i_autorizado float = null,
	@i_suscrito float = null,
	@i_pagado float = null,
	@i_tesoreria float = null,
	@i_estado int = null,
	@i_act_id int = null,
	@i_fecha_actualizacion datetime = null,
	@i_participaciones float = null,
	@o_ccaId int out,
	@i_lga_id int=null
) as
begin
	
	DECLARE @CAA_LastID INT;
	DECLARE @CAA_NextID INT;

	SELECT @CAA_LastID = ISNULL(MAX(CCA_ID), 0)
	FROM BVQ_ADMINISTRACION.COMPOSICION_CAPITAL;

	SET @CAA_NextID = @CAA_LastID + 1;

	INSERT INTO BVQ_ADMINISTRACION.COMPOSICION_CAPITAL(
	CCA_ID,
	EMI_ID,
	CCA_TIPO,
	CCA_VALOR_NOMINAL,
	CCA_AUTORIZADO,
	CCA_SUSCRITO,
	CCA_PAGADO,
	CCA_TESORERIA,
	CCA_ESTADO,
	ACT_ID,
	CCA_FECHA_ACTUALIZACION,
	CCA_NUM_ACC_PARTICIPACIONES
	) VALUES (
		@CAA_NextID,
		@i_emsId,
		@i_tipo,
		@i_valor_nominal, 
		@i_autorizado,
		@i_suscrito,
		@i_pagado,
		@i_tesoreria,
		@i_estado,
		@i_act_id,
		@i_fecha_actualizacion,
		@i_participaciones
	)
	set @o_ccaId=scope_identity()

 	EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
	@i_lga_id = @i_lga_id,
	@i_tabla = 'COMPOSICION_CAPITAL',
	@i_esquema = N'BVQ_ADMINISTRACION',
	@i_operacion = N'I',
	@i_subTipo = N'N',
	@i_columIdName = 'VBA_ID',
	@i_idAfectado = @o_ccaId;

end