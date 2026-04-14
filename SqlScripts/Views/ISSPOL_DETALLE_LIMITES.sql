alter VIEW BVQ_BACKOFFICE.ISSPOL_DETALLE_LIMITES AS
	select
		  TIPO_RENTA
		, SECTOR
		, ord
		, PCT
		, alert
		, LIM_ID
		, etiqueta
	from
	(values
		--1
		 ('RENTA FIJA'		,'ESTADO'							, 10, 0.30, 0.05, 1, null)
		,('RENTA FIJA'		,'FINANCIERO'						, 20, 0.25, 0.05, 1, null)
		,('RENTA FIJA'		,'OBLIGACIONES Y PAPEL COMERCIAL'	, 30, 0.20, 0.05, 1, null)
		,('RENTA FIJA'		,'REPORTOS'							, 40, 0.03, 0.05, 1, null)
		,('RENTA FIJA'		,'TITULARIZACIONES'					, 50, 0.05, 0.02, 1, null)
		,('RENTA FIJA'		,'FACTURAS COMERCIALES'				, 60, 0.01, 0.02, 1, null)

		,('RENTA VARIABLE'	,'ACCIONES Y ENCARGO FID'			, 70, 0.03, 0.05, 1, null)
		,('RENTA VARIABLE'	,'FONDOS DE INVERSIÓN COLECTIVO / COTIZADO'				, 80, 0.05, 0.05, 1, null)
		,('RENTA VARIABLE'	,'VALORES DE PARTICIPACIÓN'			, 90, 0.08, 0.05, 1, null)

		--2
		,('RENTA FIJA'		,'ESTADO'							, 10, 0.38, 0.05, 2, null)
		,('RENTA FIJA'		,'FINANCIERO'						, 20, 0.28, 0.05, 2, null)
		,('RENTA FIJA'		,'OBLIGACIONES Y PAPEL COMERCIAL'	, 30, 0.20, 0.05, 2, null)
		,('RENTA FIJA'		,'REPORTOS'							, 40, 0.01, 0.05, 2, null)
		,('RENTA FIJA'		,'TITULARIZACIONES'					, 50, 0.02, 0.02, 2, null)
		,('RENTA FIJA'		,'FACTURAS COMERCIALES'				, 60, 0.01, 0.02, 2, null)

		,('RENTA VARIABLE'	,'ACCIONES Y ENCARGO FID'			, 70, 0.03, 0.05, 2, null)
		,('RENTA VARIABLE'	,'FONDOS DE INVERSIÓN COLECTIVO / COTIZADO'				, 80, 0.03, 0.05, 2, null)
		,('RENTA VARIABLE'	,'VALORES DE PARTICIPACIÓN'			, 90, 0.04, 0.05, 2, null)

		--3
		,('RENTA FIJA'		,'ESTADO'							, 10, 0.40, 0.05, 3, 'No aplica')
		,('RENTA FIJA'		,'FINANCIERO'						, 20, 0.30, 0.05, 3, 'Hasta el 10% del patrimonio técnico de la IFIS o Cooperativa del Segmento 1')
		,('RENTA FIJA'		,'OBLIGACIONES Y PAPEL COMERCIAL'	, 30, 0.15, 0.05, 3, 'Hasta el 50% de la emisión')
		,('RENTA FIJA'		,'REPORTOS'							, 40, 0.01, 0.05, 3, 'Hasta el 50% de la emisión')
		,('RENTA FIJA'		,'TITULARIZACIONES'					, 50, 0.03, 0.05, 3, 'Hasta el 50% de la emisión')
		,('RENTA FIJA'		,'FACTURAS COMERCIALES'				, 60, 0.01, 0.05, 3, 'Hasta el 50% de la emisión')

		,('RENTA VARIABLE'	,'ACCIONES Y ENCARGO FID'			, 70, 0.05, 0.05, 3, 'Al menos el 20% del paquete accionario')
		,('RENTA VARIABLE'	,'FONDOS DE INVERSIÓN COLECTIVO / COTIZADO'				, 80, 0.03, 0.05, 3, 'Hasta el 15% del total de sus cuotas o unidades de participación')
		,('RENTA VARIABLE'	,'VALORES DE PARTICIPACIÓN'			, 90, 0.02, 0.05, 3, 'Hasta el 50% de la emisión')
	) sec(TIPO_RENTA,SECTOR,ord,PCT,alert, LIM_ID, etiqueta)