	IF OBJECT_ID('BVQ_PREVENCION.LOG_INSERTAR_LIQUIDEZ', 'U') IS NULL
	BEGIN

		CREATE TABLE BVQ_PREVENCION.LOG_INSERTAR_LIQUIDEZ
		(
			LIL_ID                              BIGINT IDENTITY(1,1) NOT NULL,
			LIL_FECHA_LOG		               DATETIME       NOT NULL CONSTRAINT DF_LOG_INS_LIQ_fecha   DEFAULT (GETDATE()),

			-- Parámetros recibidos por BVQ_BACKOFFICE.InsertarLiquidezTitulo
			LIL_evt_id                            BIGINT         NULL,
			LIL_fecha_cobro                       DATETIME       NULL,
			LIL_tipo                              INT            NULL,
			LIL_monto                             FLOAT          NULL,
			LIL_dpl_abono                         BIT            NULL,
			LIL_evp_uso_fondos                    FLOAT          NULL,
			LIL_evp_rendimiento                   FLOAT          NULL,
			LIL_evp_costas_judiciales             FLOAT          NULL,
			LIL_evp_costas_judiciales_referencia  VARCHAR(100)   NULL,
			LIL_fecha_default_a_restaurar         DATETIME       NULL,
			LIL_evp_fecha_liq_interes             DATE           NULL,
			LIL_lga_id                            INT            NULL,

			CONSTRAINT PK_LOG_INSERTAR_LIQUIDEZ PRIMARY KEY CLUSTERED (LIL_ID)
		);

		CREATE NONCLUSTERED INDEX IX_LOG_INSERTAR_LIQUIDEZ_evt_id
			ON BVQ_PREVENCION.LOG_INSERTAR_LIQUIDEZ (LIL_evt_id, LIL_ID);

	END