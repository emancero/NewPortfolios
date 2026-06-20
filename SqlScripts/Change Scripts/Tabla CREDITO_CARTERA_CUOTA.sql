CREATE TABLE [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA](
	[id_credito] [varchar](20) not NULL,
	[id_numero_cuota] [int] not NULL,
	[por_codigo] [varchar](50) NULL,
	[total] [money] NULL,
	[fecha_vencimiento] [date] NULL,
	[id_cuenta] [int] NULL,
	[pagada] [bit] NOT NULL,
	[id_rubro] [varchar](3) NULL,
	[saldo] [money] NULL,
	[estado] [char](1) NULL,
	[valor_pactado] [money] NULL,
	[tasa] [float] NULL,
	[abono] [money] NULL
) ON [PRIMARY]

ALTER TABLE [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA] ADD  DEFAULT ((0)) FOR [pagada]


