CREATE PROCEDURE [BVQ_BACKOFFICE].[spUltimoDiaLaborable]
    @i_fechaCorte datetime=null,
    @i_lga_id int=null
AS    
    BEGIN
        SELECT dbo.fnUltimoDiaLaborable(@i_fechaCorte) AS 'ultimo_dia_laborable'
    END 
GO