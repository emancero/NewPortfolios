alter PROCEDURE BVQ_BACKOFFICE.SpProvisionInversionesMesYAcumulada
	@i_fechaCorte datetime,
	@i_lga_id int = null
AS
BEGIN
	SET NOCOUNT ON

	IF OBJECT_ID('tempdb..#ProvisionTitulos') IS NOT NULL DROP TABLE #ProvisionTitulos
	IF OBJECT_ID('tempdb..#ProvisionDetalle') IS NOT NULL DROP TABLE #ProvisionDetalle

	-- Resultado de SpProvisionInversiones (por título)
	CREATE TABLE #ProvisionTitulos (
		POR_CODIGO        varchar(40),
		POR_ORD           int,
		htp_numeracion    varchar(250),
		EMISOR            nvarchar(500),
		CODIGO            nvarchar(255),
		CAPITAL           float,
		TASA              float,
		PLAZO             float,
		DIASINTERES       int,
		INTERES           float,
		DESDE             datetime,
		HASTA             datetime,
		FECHACOMPRA       varchar(30),
		FECHAULTIMOCUPON  datetime,
		FECHAVENCIMIENTO  datetime,
		[VALOR EFECTIVO]  float
	)

	-- Resultado de SpProvisionInversionesView (por documento x seguro)
	CREATE TABLE #ProvisionDetalle (
		orden_doc       int,
		orden_seg       int,
		cuenta1         nvarchar(max),
		cuenta2         nvarchar(max),
		TITULO          nvarchar(250),
		nombre_etiqueta nvarchar(500),
		distribucion    float,
		provision       float
	)

	INSERT INTO #ProvisionTitulos
	EXEC BVQ_BACKOFFICE.SpProvisionInversiones
		@i_fechaCorte = @i_fechaCorte,
		@i_lga_id     = @i_lga_id

	INSERT INTO #ProvisionDetalle
	EXEC BVQ_BACKOFFICE.SpProvisionInversionesView
		@i_fechaCorte  = @i_fechaCorte,
		@i_soloDetalle = 1,
		@i_lga_id      = @i_lga_id

	SELECT origen, POR_CODIGO, POR_ORD, htp_numeracion, EMISOR, CODIGO, CAPITAL, TASA, PLAZO,
		DIASINTERES, INTERES, DESDE, HASTA, FECHACOMPRA, FECHAULTIMOCUPON, FECHAVENCIMIENTO, [VALOR EFECTIVO]
	FROM (
		SELECT 
			'Provisión del mes' AS origen, 
			POR_CODIGO, 
			POR_ORD, 
			htp_numeracion, 
			EMISOR, 
			CODIGO, 
			CAPITAL, 
			TASA, 
			PLAZO,
			DIASINTERES, 
			INTERES, 
			DESDE, 
			HASTA, 
			FECHACOMPRA, 
			FECHAULTIMOCUPON, 
			FECHAVENCIMIENTO, 
			[VALOR EFECTIVO],
			0 AS orden_doc
		FROM #ProvisionTitulos

		UNION ALL

		SELECT 
			'Provisión acumulada' AS origen,
			POR_CODIGO        = NULL,
			POR_ORD           = d.orden_seg,
			htp_numeracion    = NULL,
			EMISOR            = d.nombre_etiqueta,
			CODIGO            = d.TITULO,
			CAPITAL           = d.distribucion,
			TASA              = NULL,
			PLAZO             = NULL,
			DIASINTERES       = NULL,
			INTERES           = d.provision,
			DESDE             = DATEADD(DAY, 1 - DAY(@i_fechaCorte), CONVERT(date, @i_fechaCorte)),
			HASTA             = CONVERT(datetime, CONVERT(varchar, EOMONTH(@i_fechaCorte), 106) + ' 23:59:59'),
			FECHACOMPRA       = NULL,
			FECHAULTIMOCUPON  = NULL,
			FECHAVENCIMIENTO  = NULL,
			[VALOR EFECTIVO]  = NULL,
			d.orden_doc
		FROM #ProvisionDetalle d
	) u
	ORDER BY origen, POR_ORD, orden_doc, CODIGO

	DROP TABLE #ProvisionTitulos
	DROP TABLE #ProvisionDetalle
END
