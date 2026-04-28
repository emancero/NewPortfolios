if object_id('bvq_administracion.firma') is null
	CREATE TABLE [BVQ_ADMINISTRACION].[FIRMA](
		[FIR_ID] [int] IDENTITY(1,1) NOT NULL,
		[FIR_NOMBRE] [nvarchar](200) NULL,
		[FIR_CARGO] [nvarchar](200) NULL,
		[FIR_FECHA_VINCULACION] [datetime] NULL,
	 CONSTRAINT [PK_FIRMA] PRIMARY KEY CLUSTERED 
	(
		[FIR_ID] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

if not exists(select * from INFORMATION_SCHEMA.columns where
	column_name='FIR_SUBROGANTE'
	and table_name='FIRMA'
	and table_schema='BVQ_ADMINISTRACION'
)
	alter table BVQ_ADMINISTRACION.FIRMA add FIR_SUBROGANTE bit not null
	CONSTRAINT DF_FIRMA_FIR_SUBROGANTE default (0) with values
