

begin tran 

DECLARE @UltimoId INT;

SELECT @UltimoId = ISNULL(MAX(FUN_ID), 0)
FROM bvq_seguridad.funcionalidad;

IF NOT EXISTS (
    SELECT 1 
    FROM bvq_seguridad.funcionalidad 
    WHERE FUN_NOMBRE = 'Inversiones SC'
)
BEGIN

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
		FUN_ORDEN,
		FUN_ES_VERSION2
	)
	VALUES
	(
		@UltimoId + 1,
		4,
		'Inversiones SC',
		89,
		'BCK_INVESTMENTS_ISSPOL',
		82,
		'Bvq.Sipla.Isspol.Module.dll',
		'Bvq.Sipla.Isspol.Module.SCInvestmentsView',
		21,
		1,
		106,
		NULL
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
END

commit tran 