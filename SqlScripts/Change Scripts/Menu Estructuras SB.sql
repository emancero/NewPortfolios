DECLARE @UltimoId INT;
DECLARE @SQL NVARCHAR(MAX);

if exists(select 1 from information_schema.columns where column_name='fun_es_version2' and table_schema='BVQ_SEGURIDAD' and table_name='FUNCIONALIDAD')
    SET @SQL = N'
        SELECT @UltimoId = ISNULL(MAX(FUN_ID), 0)
        FROM bvq_seguridad.funcionalidad
        WHERE fun_es_version2 IS NULL';
ELSE
    SET @SQL = N'
        SELECT @UltimoId = ISNULL(MAX(FUN_ID), 0)
        FROM bvq_seguridad.funcionalidad';

EXEC sp_executesql 
    @SQL,
    N'@UltimoId INT OUTPUT',
    @UltimoId OUTPUT;

if not exists(
    select * from bvq_seguridad.funcionalidad where fun_nombre like 'Estructuras SB'
)
begin
    INSERT INTO bvq_seguridad.funcionalidad
    (
	    FUN_ID,
        MOD_ID,
        FUN_NOMBRE,
        FUN_TIPO,
        FUN_CODIGO,
        FUN_ESTADO,
        FUN_NOMBRE_DLL,
        FUN_NOMBRE_CLASE,
        FUN_PADRE,
        FUN_AUDITAR,
        FUN_ORDEN
    )
    VALUES
    (
	    @UltimoId + 1,
        4,
        'Estructuras SB',
        89,
        'BCK_ISSPOL_OVERVIEW',
        82,
        'Bvq.Sipla.Isspol.Module.dll',
        'Bvq.Sipla.Isspol.Module.StructuresView',
        21,
        1,
        106
    );

    SELECT @UltimoId = ISNULL(MAX(FUN_ID), 0)
    FROM bvq_seguridad.funcionalidad;
 
    INSERT INTO bvq_seguridad.perfil_funcionalidad
    (
        PRF_ID,
        FUN_ID
    )
    VALUES
    (
        1,
        @UltimoId
    );
end
