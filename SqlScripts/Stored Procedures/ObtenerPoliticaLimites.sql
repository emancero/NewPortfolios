create procedure BVQ_BACKOFFICE.ObtenerPoliticaLimites
	 @i_fecha_corte datetime
	,@i_lga_id int = null
as
begin


	declare @v_fecha_base datetime = EOMONTH('2024-06-28T10:09:40', -1)
	if exists(select * from bvq_administracion.parametro where par_codigo='POLITICA_MES' and par_valor='NO')
		set @v_fecha_base=DATEADD(yy, DATEDIFF(yy, 0, getdate()), -1)
	
	--exec bvq_backoffice.generarcompraventaflujo

	--montos al corte anterior
	truncate table [_temp].[ObtenerInfoPortfoliosPorFechaResult]
	insert into [_temp].[ObtenerInfoPortfoliosPorFechaResult]
	exec [BVQ_BACKOFFICE].[ObtenerInfoPortfoliosPorFecha] @v_fecha_base,null

	select tipoRenta
	,baseSal=
		--caso excepcional: monto quemado el primer año de uso del sistema
		--pues ciertos precios estaban incorrectos en los archivos manuales
		case when datediff(d,@v_fecha_base,'20231231')=0 and tipoRenta='Renta fija' then
			505968256.55
		--fin caso excepcional
		else
			sum(sal*
				isnull(PRECIO_DE_HOY,1)+isnull(INTERES_GANADO,0))--,sum(valor_nominal)--isnull(sum(sal*case when tipo_renta='RENTA VARIABLE' then tiv_valor_nominal else 1 end),0)
		end
	,baseFecha=
	formatmessage('INVERSIONES NO PRIVATIVAS RENTA %s (%s)'
		,case when tipoRenta='Renta fija' then 'FIJA' when tipoRenta='Renta variable' then 'VARIABLE' end
		,format(@v_fecha_base,'dd/MM/yyyy'))
	from (values('Renta variable'),('Renta fija')) v(tipoRenta)
	left join [_temp].[ObtenerInfoPortfoliosPorFechaResult] pc on pc.tipo_renta=v.tipoRenta
	where isnull(ipr_es_cxc,0)=0 and VALOR_NOMINAL>0
	group by tipoRenta order by tipoRenta

	delete from corteslist
	insert into corteslist values (@i_fecha_corte,1)

	;with a as(
		select tpo_recursos
		,vn=sal*case when tiv_tipo_renta=154 then tiv_valor_nominal else 1 end
		,pai=case when tpo_recursos='pai' then 1 else 0 end*sal*case when tiv_tipo_renta=154 then tiv_valor_nominal else 1 end
		,excedentes=case when tpo_recursos='Excedentes de liquidez' then 1 else 0 end*sal*case when tiv_tipo_renta=154 then tiv_valor_nominal else 1 end
		,sinClasificar=case when tpo_recursos is null or tpo_recursos not in ('Excedentes de liquidez','pai') then 1 else 0 end*sal*case when tiv_tipo_renta=154 then tiv_valor_nominal else 1 end
		,TIPO_RENTA=tiv_tipo_renta
		--,sector_general
		,SECTOR=
		case when sector_general like 'SEC[_]PUB[_]%' then 'ESTADO'
		when sector_general like '%[_]FIN' and tvl_codigo not in ('OCA') then 'FINANCIERO'
		when tvl_codigo in ('OBL','PCO','OCA') then 'OBLIGACIONES Y PAPEL COMERCIAL'
		when tvl_codigo in ('REP') then 'REPORTOS'
		when tvl_codigo in ('VCC') then 'TITULARIZACIONES'
		when tvl_codigo in ('FAC') then 'FACTURAS COMERCIALES'
		when tvl_codigo in ('ACC','ENC') then 'ACCIONES Y ENCARGO FID'
		when tvl_codigo in ('FI') then 'FONDOS DE INVERSIÓN'
		when tvl_codigo in ('CDP') then 'VALORES DE PARTICIPACIÓN'
		end--,*
		--when 
		from bvq_backoffice.portafoliocorte pc where isnull(ipr_es_cxc,0)=0 and sal>0
	) select
		 sal=isnull(sum(vn),0)
		,pai=isnull(sum(pai),0)
		,excedentes=isnull(sum(excedentes),0)
		,sinClasificar=isnull(sum(sinClasificar),0)
		,sec.TIPO_RENTA,sec.SECTOR,PCT,alert
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
