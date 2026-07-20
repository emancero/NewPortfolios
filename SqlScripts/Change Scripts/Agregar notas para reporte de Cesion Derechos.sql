-- Notas al pie extraídas de "Envio matriz CDF AGO 2024.xlsx" (filas 695-700)
-- para el reporte de Cesión de Derechos Fiduciarios (INC_ARCHIVO = 'DER')

IF NOT EXISTS (SELECT 1 FROM [BVQ_BACKOFFICE].[ISSPOL_NOTAS_CXC] WHERE [INC_ARCHIVO] = 'DER' AND [INC_ORDEN] = 1)
BEGIN
    INSERT INTO [BVQ_BACKOFFICE].[ISSPOL_NOTAS_CXC]
        ([INC_DESCRIPCION], [INC_ORDEN], [INC_FECHA_DESDE], [INC_FECHA_HASTA], [INC_ARCHIVO])
    VALUES
        (N'NOTA1: En el portafolio de inversiones consta incluído en Cesión de Derechos Fiduciarios Agricola Pura Vida, la cuenta por cobrar por costas Judiciales, por un total de USD$ 22.000,00 registrado en AD000636 DEL 09/Jul/2019, por la firma del Acuerdo de Mediación, en el cual esta considerado el interes desde las fechas originales de compra, sin embargo no ha existido ningun abono.',
         1, '1900-01-01', '9997-12-31', 'DER')
END

IF NOT EXISTS (SELECT 1 FROM [BVQ_BACKOFFICE].[ISSPOL_NOTAS_CXC] WHERE [INC_ARCHIVO] = 'DER' AND [INC_ORDEN] = 2)
BEGIN
    INSERT INTO [BVQ_BACKOFFICE].[ISSPOL_NOTAS_CXC]
        ([INC_DESCRIPCION], [INC_ORDEN], [INC_FECHA_DESDE], [INC_FECHA_HASTA], [INC_ARCHIVO])
    VALUES
        (N'NOTA2: El interés ganado se liquida al momento de recibir la cancelacion de la operación, por encontrarse reclasificadas en Otras cuentas por cobrar.',
         2, '1900-01-01', '9997-12-31', 'DER')
END

IF NOT EXISTS (SELECT 1 FROM [BVQ_BACKOFFICE].[ISSPOL_NOTAS_CXC] WHERE [INC_ARCHIVO] = 'DER' AND [INC_ORDEN] = 3)
BEGIN
    INSERT INTO [BVQ_BACKOFFICE].[ISSPOL_NOTAS_CXC]
        ([INC_DESCRIPCION], [INC_ORDEN], [INC_FECHA_DESDE], [INC_FECHA_HASTA], [INC_ARCHIVO])
    VALUES
        (N'NOTA3: Los saldos constan registrados con corte al 30 de agosto del 2024',
         3, '1900-01-01', '9997-12-31', 'DER')
END

IF NOT EXISTS (SELECT 1 FROM [BVQ_BACKOFFICE].[ISSPOL_NOTAS_CXC] WHERE [INC_ARCHIVO] = 'DER' AND [INC_ORDEN] = 4)
BEGIN
    INSERT INTO [BVQ_BACKOFFICE].[ISSPOL_NOTAS_CXC]
        ([INC_DESCRIPCION], [INC_ORDEN], [INC_FECHA_DESDE], [INC_FECHA_HASTA], [INC_ARCHIVO])
    VALUES
        (N'',
         4, '1900-01-01', '9997-12-31', 'DER')
END

IF NOT EXISTS (SELECT 1 FROM [BVQ_BACKOFFICE].[ISSPOL_NOTAS_CXC] WHERE [INC_ARCHIVO] = 'DER' AND [INC_ORDEN] = 4)
BEGIN
    INSERT INTO [BVQ_BACKOFFICE].[ISSPOL_NOTAS_CXC]
        ([INC_DESCRIPCION], [INC_ORDEN], [INC_FECHA_DESDE], [INC_FECHA_HASTA], [INC_ARCHIVO])
    VALUES
        (N'FUENTE: Gestión de Inversiones y Contabilidad',
         5, '1900-01-01', '9997-12-31', 'DER')
END