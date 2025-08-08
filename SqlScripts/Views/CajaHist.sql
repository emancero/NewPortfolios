CREATE view bvq_backoffice.CajaHist as 
	select  
	tablaraw='caja_seguros',
	--F.F1,  
	CJ.F1,
	/*case when tablaraw='caja_seguros' then
		Case    
		when CJ.F1>7 AND CJ.F1<1744 Then 'ISSPOL - RIM'      
		when CJ.F1>1972 AND CJ.F1<2731 Then 'ISSPOL - Acc. Profesionales'    
		when CJ.F1>2834 AND CJ.F1<3677 Then 'ISSPOL - Seg. Vida Activos'    
		when CJ.F1>3777 AND CJ.F1<4722 Then 'ISSPOL -  Seguro Mortuoria'    
		when CJ.F1>4839 AND CJ.F1<5816 Then 'ISSPOL -  Fondos de Reserva'    
		when CJ.F1>5935 AND CJ.F1<6823 Then 'ISSPOL -  Enfermedad y Maternidad'    
		when CJ.F1>7006 AND CJ.F1<8148 Then 'ISSPOL -  Fondos de Vivienda'    
		when CJ.F1>8301 AND CJ.F1<8905 Then 'ISSPOL -  Seguro de Saldos'    
		when CJ.F1>8991 AND CJ.F1<9468 Then 'ISSPOL -  Seguro de Desgravamen'    
		when CJ.F1>9534 AND CJ.F1<10362 Then 'ISSPOL -  Seguro de Vida Contratado'     
		when CJ.F1>10474 AND CJ.F1<11214 Then 'ISSPOL -  Ind. Profesional'     
		when CJ.F1>11308 AND CJ.F1<11692 Then 'ISSPOL - CESANTÍA'     
		--when CJ.F1>11780 AND CJ.F1<12160 Then 'ISSPOL RIM MORTUORIA LDF'     
		when CJ.F1>11780 AND CJ.F1<12160 Then 'ISSPOL RIM-MORTUORIA 01331687 LDF'     
		--when CJ.F1>12160 Then 'ISSPOL SEGURO DE VIDA Y ACCIDENTES PROFESIONALES NR'
		when CJ.F1>12239 AND CJ.F1<12611 Then 'ISSPOL-VIDA Y ACCI. PROF.01331688 LDF'
		end 
	when tablaraw='caja_adm_fondos' then
		case
		when CJ.F1>6 AND CJ.F1<5186 Then '1330003-Banco Central del Ecuador Administradora'
		end
	end*/
	acc as Fondo
	--,F.Fecha  
	,Fecha = case when isnumeric(f2)=1 then DATEADD(d, f2-2,0) end
	,Saldo_Inicial = COALESCE(TRY_CAST(CJ.F3 AS FLOAT), 0)
	,Aportes=COALESCE(TRY_CAST(CJ.F4 AS FLOAT), 0)
	,PRESTAMO_QUIROGRAFARIO=COALESCE(TRY_CAST(CJ.F5 AS FLOAT), 0)
	,PRESTAMO_HIPOTECARIO=COALESCE(TRY_CAST(CJ.F6 AS FLOAT), 0)
	,VENCIMIENTO_CAPITAL=COALESCE(TRY_CAST(CJ.F7 AS FLOAT), 0)
	,RENDIMIENTOS=COALESCE(TRY_CAST(CJ.F8 AS FLOAT), 0)
	,FONDEO=COALESCE(TRY_CAST(CJ.F9 AS FLOAT), 0)
	,OTROS=COALESCE(TRY_CAST(CJ.F10 AS FLOAT), 0)
	,COMPRAS_E=COALESCE(TRY_CAST(CJ.F11 AS FLOAT), 0)
	,PENSIONES_FONDO_SEGURO_E=COALESCE(TRY_CAST(CJ.F12 AS FLOAT), 0)
	,PRESTAMO_QUIROGRAFARIO_E=COALESCE(TRY_CAST(CJ.F13 AS FLOAT), 0)	
	,PRESTAMO_HIPOTECARIO_E=COALESCE(TRY_CAST(CJ.F14 AS FLOAT), 0)
	,FONDEO_E=COALESCE(TRY_CAST(CJ.F15 AS FLOAT), 0)
	,OTROS_E=COALESCE(TRY_CAST(CJ.F16 AS FLOAT), 0)
	,SALDO_FINAL = COALESCE(TRY_CAST(CJ.F17 AS FLOAT), 0)
	from (
		select acc,s.* from(
			select tablaraw='caja_seguros',* from CAJA_SEGUROS
			union all select tablaraw='caja_adm_fondos', * from CAJA_ADM_FONDOS
		) s
		join (
			select ini=f1, fin=isnull(lead(f1) over (partition by tablaraw order by f1),2e9),f2,tablaraw from(
				select tablaraw='caja_seguros',* from CAJA_SEGUROS
				union all select tablaraw='caja_adm_fondos', * from CAJA_ADM_FONDOS
			) cc where f2 like 'port%'
		) t on s.tablaraw=t.tablaraw and s.f1 between ini and fin-1
		join (values
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL RIM','ISSPOL - RIM'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL ACC. PROFESIONALES','ISSPOL - Acc. Profesionales'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL SEG. VIDA ACTIVOS','ISSPOL - Seg. Vida Activos'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL SEGURO MORTUORIA','ISSPOL - Seguro Mortuoria'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL FONDOS DE RESERVA','ISSPOL - Fondos de Reserva'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL ENFERMEDAD Y MATERNIDAD','ISSPOL - Enfermedad y Maternidad'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL FONDOS DE VIVIENDA','ISSPOL - Fondos de Vivienda'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL SEGURO DE SALDOS','ISSPOL - Seguro de Saldos'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL SEGURO DE DESGRAVAMEN','ISSPOL - Seguro de Desgravamen'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL SEGURO DE VIDA CONTRATADO','ISSPOL - Seguro de Vida Contratado'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL INDEMNIZACION PROFESIONAL','ISSPOL - Ind. Profesional'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL CESANTIA','ISSPOL - CESANTÍA'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL RIM MORTUORIA LDF','ISSPOL RIM-MORTUORIA 01331687 LDF'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL SEGURO DE VIDA Y ACCIDENTES PROFESIONALES NR','ISSPOL-VIDA Y ACCI. PROF.01331688 LDF'),
			('PORTAFOLIO DE INVERSIONES CAJA  - ISSPOL ADMINISTRADORA DE FONDOS','1330003-Banco Central del Ecuador Administradora')
		) v(fil,acc)
		on t.f2=v.fil
	) CJ
	where
	CJ.F2 is not null
	--and case when isnumeric(f2)=1 then DATEADD(d, f2-2,0) end<='20221230'
