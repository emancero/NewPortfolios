CREATE PROCEDURE [BVQ_BACKOFFICE].[spOtrasCuentasPorCobrar] @i_fechaCorte DATETIME = NULL, @i_lga_id INT = NULL
AS
BEGIN
begin tran
	DELETE FROM corteslist
	INSERT INTO corteslist (c, cortenum)
		SELECT
			@i_fechaCorte
		   ,1
	EXEC BVQ_BACKOFFICE.GenerarCompraVentaFlujo
	EXEC BVQ_ADMINISTRACION.GenerarVectores
	EXEC BVQ_ADMINISTRACION.PrepararValoracionLinealCache

	IF 1 = 1
		SELECT
			FECHA_EVALUACION = @i_fechaCorte

	SELECT * FROM BVQ_BACKOFFICE.OtrasCuentasPorCobrarView order by case when tpo_prog='normal' then FECHA_VALOR_DE_COMPRA else tpo_f1 end

	IF 1 = 1
		SELECT
			NOTA = INC_DESCRIPCION
		FROM BVQ_BACKOFFICE.ISSPOL_NOTAS_CXC
		WHERE @i_fechaCorte BETWEEN ISNULL(INC_FECHA_DESDE, 0) AND ISNULL(INC_FECHA_HASTA, '9999-12-31T00:00:00')
		AND INC_ARCHIVO = 'CXC'
		ORDER BY INC_ORDEN
commit tran
END
