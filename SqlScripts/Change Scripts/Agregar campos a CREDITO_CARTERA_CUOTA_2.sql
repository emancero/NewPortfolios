IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('BVQ_BACKOFFICE.credito_cartera_cuota_2') AND name = 'tasa')
ALTER TABLE bvq_backoffice.credito_cartera_cuota_2 ADD tasa FLOAT;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('BVQ_BACKOFFICE.credito_cartera_cuota_2') AND name = 'fecha_vencimiento_credito')
ALTER TABLE bvq_backoffice.credito_cartera_cuota_2 ADD fecha_vencimiento_credito DATE;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('BVQ_BACKOFFICE.credito_cartera_cuota_2') AND name = 'producto')
ALTER TABLE bvq_backoffice.credito_cartera_cuota_2 ADD producto NVARCHAR(255);

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('BVQ_BACKOFFICE.credito_cartera_cuota_2') AND name = 'fondo')
ALTER TABLE bvq_backoffice.credito_cartera_cuota_2 ADD fondo NVARCHAR(255);

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('BVQ_BACKOFFICE.credito_cartera_cuota_2') AND name = 'segmento')
ALTER TABLE bvq_backoffice.credito_cartera_cuota_2 ADD segmento NVARCHAR(255);

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('BVQ_BACKOFFICE.credito_cartera_cuota_2') AND name = 'por_codigo')
ALTER TABLE bvq_backoffice.credito_cartera_cuota_2 ADD por_codigo NVARCHAR(255);