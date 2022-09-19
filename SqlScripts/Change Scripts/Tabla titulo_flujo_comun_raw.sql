CREATE TABLE [BVQ_ADMINISTRACION].[TITULO_FLUJO_COMUN_RAW](
	[TFL_ID] [int] NOT NULL,
	[TIV_ID] [int] NOT NULL,
	[TFL_CODIGO] [varchar](80) NOT NULL,
	[TFL_PERIODO] [int] NULL,
	[TFL_CAPITAL] [float] NULL,
	[TFL_FECHA_INICIO] [datetime] NULL,
	[TFL_INTERES] [float] NULL,
	[TFL_AMORTIZACION] [float] NULL,
	[TFL_RECUPERACION] [float] NULL,
	[TFL_FECHA_VENCIMIENTO] [datetime] NULL,
	[TFL_VALOR_PRESENTE] [float] NULL,
	[TFL_FECHA_INICIO_VIGENCIA] [datetime] NULL,
	[TFL_FECHA_FIN_VIGENCIA] [datetime] NULL,
	[TFL_FECHA_REGISTRO] [datetime] NULL,
	[TFL_FECHA_ACTUALIZACION] [datetime] NULL
--,tiv_tasa_margen float,tiv_tasa_interes float,tiv_tipo_base int
)
