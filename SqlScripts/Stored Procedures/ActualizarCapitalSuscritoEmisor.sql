CREATE procedure [BVQ_ADMINISTRACION].[ActualizarCapitalSuscritoEmisor]
	@i_ccaId int,
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
	@i_lga_id int=null
as
begin
		
		UPDATE BVQ_ADMINISTRACION.COMPOSICION_CAPITAL
		SET
			EMI_ID                     = @i_emsId,
			CCA_TIPO                   = @i_tipo,
			CCA_VALOR_NOMINAL           = @i_valor_nominal,
			CCA_AUTORIZADO              = @i_autorizado,
			CCA_SUSCRITO                = @i_suscrito,
			CCA_PAGADO                  = @i_pagado,
			CCA_TESORERIA               = @i_tesoreria,
			CCA_ESTADO                  = @i_estado,
			ACT_ID                     = @i_act_id,
			CCA_FECHA_ACTUALIZACION     = @i_fecha_actualizacion,
			CCA_NUM_ACC_PARTICIPACIONES = @i_participaciones
		WHERE
			CCA_ID = @i_ccaId;

		 
		EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = 'VARIABLES_BALANCE',
		@i_esquema = N'BVQ_ADMINISTRACION',
		@i_operacion = N'U',
		@i_subTipo = N'A',
		@i_columIdName = 'VBA_ID',
		@i_idAfectado = @i_ccaId

end
