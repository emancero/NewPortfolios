exec dropifexists 'BVQ_BACKOFFICE.ObtenerPoliticaLimites'
go
create procedure BVQ_BACKOFFICE.ObtenerPoliticaLimites
	 @i_fecha_corte datetime
	,@i_lga_id int = null
as
begin
	delete from corteslist
	insert into corteslist values (@i_fecha_corte,1)
	exec bvq_backoffice.generarcompraventaflujo
	;with a as(
		select sal,TIPO_RENTA=tiv_tipo_renta
		--,sector_general
		,SECTOR=case when sector_general like 'SEC_PUB_%' then 'ESTADO'
		when sector_general like '%_NFIN' then 'FINANCIERO'
		when tvl_codigo in ('OBL','PCO') then 'OBLIGACIONES Y PAPEL COMERCIAL'
		when tvl_codigo in ('REP') then 'REPORTOS'
		when tvl_codigo in ('VCC') then 'TITULARIZACIONES'
		when tvl_codigo in ('FAC') then 'FACTURAS COMERCIALES'
		when tvl_codigo in ('ACC','ENC') then 'ACCIONES Y ENCARGO FID'
		when tvl_codigo in ('FI') then 'FONDOS DE INVERSIÓN'
		when tvl_codigo in ('CDP') then 'VALORES DE PARTICIPACIÓN'
		end
		--when 
		from bvq_backoffice.portafoliocorte pc
	) select sal=sum(sal),TIPO_RENTA,sec.SECTOR,PCT from a
	left join (values
		 ('ESTADO',10,0.3)
		,('FINANCIERO',20,0.25)
		,('OBLIGACIONES Y PAPEL COMERCIAL',30,0.2)
		,('REPORTOS',40,0.15)
		,('TITULARIZACIONES',50,0.05)
		,('FACTURAS COMERCIALES',60,0.05)

		,('ACCIONES Y ENCARGO FID',70,0.3)
		,('FONDOS DE INVERSIÓN',80,0.3)
		,('VALORES DE PARTICIPACIÓN',90,0.4)
	) sec(SECTOR,ord,PCT) on sec.SECTOR=a.sector
	group by sec.sector,tipo_renta,pct,ord order by ord
end
