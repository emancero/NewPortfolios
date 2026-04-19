IF NOT EXISTS (
    SELECT 1
    FROM BVQ_ADMINISTRACION.PARAMETRO
    WHERE PAR_CODIGO = 'TEMP_ISSPOL_IVS_MADE'
)
BEGIN
    INSERT INTO BVQ_ADMINISTRACION.PARAMETRO
    (
        PAR_NOMBRE,
        PAR_CODIGO,
        PAR_TIPO_DATO,
        PAR_VALOR,
        PAR_ESTADO,
        PAR_DESCRIPCION,
        PAR_FECHA,
        PAR_DEUSUARIO
    )
    VALUES
    (
        'Plantilla isspol Inversiones Realizadas',
        'TEMP_ISSPOL_IVS_MADE',
        11,
        'plantillas\PLANTILLA_INVERSIONES_REALIZADAS.xlsx',
        21,
        'Plantilla isspol Inversiones Realizadas',
        '2026-01-21 14:01:10.980',
        0
    );
END
