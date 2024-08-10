create procedure BVQ_BACKOFFICE.ObtenerPoliticaLimites
	 @i_fecha_corte datetime
	,@i_lga_id int = null
as
begin
	delete from corteslist
	insert into corteslist values (@i_fecha_corte,1)
	exec bvq_backoffice.generarcompraventaflujo
	;with a as(
		select tpo_recursos
		,vn=sal*case when tiv_tipo_renta=154 then tiv_valor_nominal else 1 end
		,TIPO_RENTA=tiv_tipo_renta
		--,sector_general
		,SECTOR=
		case when sector_general like 'SEC[_]PUB[_]%' then 'ESTADO'
		when sector_general like '%[_]FIN' then 'FINANCIERO'
		when tvl_codigo in ('OBL','PCO') then 'OBLIGACIONES Y PAPEL COMERCIAL'
		when tvl_codigo in ('REP') then 'REPORTOS'
		when tvl_codigo in ('VCC') then 'TITULARIZACIONES'
		when tvl_codigo in ('FAC') then 'FACTURAS COMERCIALES'
		when tvl_codigo in ('ACC','ENC') then 'ACCIONES Y ENCARGO FID'
		when tvl_codigo in ('FI') then 'FONDOS DE INVERSIÓN'
		when tvl_codigo in ('CDP') then 'VALORES DE PARTICIPACIÓN'
		end--,*
		--when 
		from bvq_backoffice.portafoliocorte pc where isnull(ipr_es_cxc,0)=0 and sal>0
	) select sal=isnull(sum(vn),0),pai=isnull(sum(vn),0),sec.TIPO_RENTA,sec.SECTOR,PCT,alert
	,r=row_number() over (partition by sec.TIPO_RENTA order by ord desc)
	from
	(values
		 ('RENTA FIJA'		,'ESTADO'							,10,0.30,0.05)
		,('RENTA FIJA'		,'FINANCIERO'						,20,0.25,0.05)
		,('RENTA FIJA'		,'OBLIGACIONES Y PAPEL COMERCIAL'	,30,0.20,0.05)
		,('RENTA FIJA'		,'REPORTOS'							,40,0.15,0.05)
		,('RENTA FIJA'		,'TITULARIZACIONES'					,50,0.05,0.02)
		,('RENTA FIJA'		,'FACTURAS COMERCIALES'				,60,0.05,0.02)

		,('RENTA VARIABLE'	,'ACCIONES Y ENCARGO FID'			,70,0.30,0.05)
		,('RENTA VARIABLE'	,'FONDOS DE INVERSIÓN'				,80,0.30,0.05)
		,('RENTA VARIABLE'	,'VALORES DE PARTICIPACIÓN'			,90,0.40,0.05)
	) sec(TIPO_RENTA,SECTOR,ord,PCT,alert)
	left join a
	on sec.SECTOR=a.sector
	group by sec.sector,sec.tipo_renta,pct,ord,alert order by ord
end
