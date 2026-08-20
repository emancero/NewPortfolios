CREATE PROCEDURE [BVQ_PREVENCION].[ObtenerPNyPJAutoCompleteByDate]
(
    @i_estados VARCHAR(80),
    @i_date DATETIME,
    @i_lga_id INT
)
AS
BEGIN
    SET NOCOUNT ON;
    
	IF OBJECT_ID(N'tempdb..#ESTADO_PERSONA', N'U') IS NOT NULL
		DROP TABLE #ESTADO_PERSONA;

	CREATE TABLE #ESTADO_PERSONA (ITC_ID INT);

	DECLARE @v_sql NVARCHAR(1000);
	SET @v_sql = N'INSERT INTO #ESTADO_PERSONA (ITC_ID) SELECT ITC.ITC_ID FROM BVQ_ADMINISTRACION.CATALOGO CAT INNER JOIN BVQ_ADMINISTRACION.ITEM_CATALOGO ITC ON CAT.CAT_ID = ITC.CAT_ID WHERE CAT.CAT_CODIGO = ''GENSTATUS''';

	IF (@i_estados IS NOT NULL)
		SET @v_sql = @v_sql + ' AND ITC.ITC_CODIGO IN (''' + @i_estados + ''')';

	EXEC sp_executesql @v_sql;    
    
    SELECT 
        ID,
        NOMBRE,
        IDENTIFICACION,
        NOMBRE_COMP,
        ESTADO AS PER_ESTADO,
        TIPO_PERSONA,
        ORDEN,
        DIRECCION = CASE WHEN SPI2PAR.PAR_VALOR = 'SI' THEN DIRECCION ELSE '' END,
        EMAIL = CASE WHEN SPI2PAR.PAR_VALOR = 'SI' THEN EMAIL ELSE '' END,
		PER_FECHA_ACTUALIZACION
    FROM (
        SELECT 
            ID = CONVERT(INT, tblTotal.ORDEN),
            ORDEN,
            IDENTIFICACION,
            NOMBRE = LTRIM(RTRIM(tblTotal.NOMBRE)),
            DIRECCION,
            EMAIL,
            TIPO_PERSONA,
            NOMBRE_COMP,
            ESTADO,
			PER_FECHA_ACTUALIZACION
        FROM (
            SELECT 
                PER.ID,
                ORDEN = ROW_NUMBER() OVER (ORDER BY PER.NOMBRE ASC),
                PER.IDENTIFICACION,
                PER.NOMBRE,
                PER.DIRECCION,
                PER.EMAIL,
                PER.TIPO_PERSONA,
                PER.NOMBRE_COMP,
                PER.ESTADO,
                PER.PER_ESTADO,
				PER.PER_FECHA_ACTUALIZACION
            FROM (
                SELECT 
                    ID = pn.PNA_ID,
                    IDENTIFICACION = pn.PNA_IDENTIFICACION,
                    NOMBRE = REPLACE(ISNULL(pn.PNA_PRIMER_APELLIDO, '') + ' ' + ISNULL(pn.PNA_SEGUNDO_APELLIDO, '') + ' ' + ISNULL(pn.PNA_PRIMER_NOMBRE, '') + ' ' + ISNULL(pn.PNA_SEGUNDO_NOMBRE, ''), ':', '') 
                             + ' : ' + pn.PNA_IDENTIFICACION,
                    DIRECCION = ISNULL(pn.PNA_DIRECCION_DOMICILIO, ''),
                    EMAIL = ISNULL(pn.PNA_EMAIL, ''),
                    TIPO_PERSONA = 'PN',
                    NOMBRE_COMP = pn.PNA_IDENTIFICACION + ': ' + ISNULL(pn.PNA_PRIMER_NOMBRE, '') + ' ' + ISNULL(pn.PNA_SEGUNDO_NOMBRE, '') + ' ' + ISNULL(pn.PNA_PRIMER_APELLIDO, '') + ' ' + ISNULL(pn.PNA_SEGUNDO_APELLIDO, ''),
                    ESTADO = case when isnull(PNA_IS_PEP,0)=0 or isnull(PNA_IS_BLACK_LIST,0)=0 then 'A' else 'PA' end,
                    PER_ESTADO = case when isnull(PNA_IS_PEP,0)=0 or isnull(PNA_IS_BLACK_LIST,0)=0 then '21' else '22' end,
					PER_FECHA_ACTUALIZACION=pn.PNA_FECHA_ULTIMA_ACT
                FROM BVQ_PREVENCION.PERSONA_NATURAL pn
                WHERE pn.PNA_FECHA_ULTIMA_ACT >= DATEADD(SECOND, -30, @i_date) 
				and dbo.fn_TieneDigitosRepetidos(pn.PNA_IDENTIFICACION, 5) = 0

                UNION

                SELECT 
                    ID = pj.PRJ_ID,
                    IDENTIFICACION = pj.PRJ_IDENTIFICACION,
                    NOMBRE = REPLACE(ISNULL(pj.PRJ_RAZON_SOCIAL, ''), ':', '') 
                             + ' : ' + pj.PRJ_IDENTIFICACION,
                    DIRECCION = ISNULL(pj.PRJ_DIRECCION, ''),
                    EMAIL = ISNULL(pj.PRJ_EMAIL, ''),
                    TIPO_PERSONA = 'PJ',
                    NOMBRE_COMP = pj.PRJ_IDENTIFICACION + ': ' + pj.PRJ_RAZON_SOCIAL,
                    ESTADO = case when isnull(PRJ_IS_PEP,0)=0 or isnull(PRJ_IS_BLACK_LIST,0)=0 then 'A' else 'PA' end,
                    PER_ESTADO = case when isnull(PRJ_IS_PEP,0)=0 or isnull(PRJ_IS_BLACK_LIST,0)=0 then '21' else '22' end,
					PER_FECHA_ACTUALIZACION=pj.PRJ_FECHA_ULTIMA_ACT
                FROM BVQ_PREVENCION.PERSONA_JURIDICA pj
                WHERE pj.PRJ_FECHA_ULTIMA_ACT >= DATEADD(SECOND, -30, @i_date)  
            ) AS PER
            WHERE LTRIM(RTRIM(IDENTIFICACION)) NOT IN ('DECEVALE','DCV-BCE','')
        ) AS tblTotal
        WHERE tblTotal.PER_ESTADO IN (SELECT ITC_ID FROM #ESTADO_PERSONA)
    ) AS CON_ID
    LEFT JOIN BVQ_ADMINISTRACION.PARAMETRO SPI2PAR ON SPI2PAR.PAR_CODIGO = 'SPI_PERSISTENTE'
    ORDER BY CON_ID.ORDEN;
END
