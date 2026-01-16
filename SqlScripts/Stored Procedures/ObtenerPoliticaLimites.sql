create procedure BVQ_BACKOFFICE.ObtenerPoliticaLimites
	 @i_fecha_corte datetime = '2025-06-30T23:59:59'
	,@i_lga_id int = null
as
begin


	declare @v_fecha_base datetime = dateadd(s,-1,dateadd(d,1,convert(datetime,EOMONTH(@i_fecha_corte,-1))))
	if exists(select * from bvq_administracion.parametro where par_codigo='POLITICA_MES' and par_valor='NO')
		set @v_fecha_base=DATEADD(yy, DATEDIFF(yy, 0, @i_fecha_corte), -1)
	
	--exec bvq_backoffice.generarcompraventaflujo

	--montos al corte anterior
	delete from corteslist
	insert into corteslist values (@v_fecha_base,1)
	exec bvq_backoffice.GenerarCompraVentaFlujo
	exec bvq_administracion.GenerarVectores
	exec bvq_administracion.PrepararValoracionLinealCache
	truncate table [_temp].[ObtenerInfoPortfoliosPorFechaResult]
	insert into [_temp].[ObtenerInfoPortfoliosPorFechaResult](VALOR_NOMINAL,sal,PRECIO_DE_HOY,INTERES_GANADO,INTERES_GANADO_2,latest_inicio
	,tiv_tipo_base
	,htp_numeracion
	,TVL_CODIGO
	)
	select VALOR_NOMINAL,sal,PRECIO_DE_HOY,INTERES_GANADO,INTERES_GANADO_2,latest_inicio
	,tiv_tipo_base
	,htp_numeracion
	,TVL_CODIGO
	from BVQ_BACKOFFICE.PortafolioCortePrcInt
	where isnull(ipr_es_cxc,0)=0 and (sal>0 or round(salNewValNom,2)>0)
	--exec [BVQ_BACKOFFICE].[ObtenerInfoPortfoliosPorFecha] @v_fecha_base,null

	
	
	select tipoRenta='nopriv'
	,baseSal=
		--caso excepcional: monto quemado el primer año de uso del sistema
		--pues ciertos precios estaban incorrectos en los archivos manuales
		case when datediff(d,@v_fecha_base,'20231231')=0 then--and tipoRenta='Renta fija' then
			505968256.55
		--fin caso excepcional
		else
			sum(sal*
				isnull(PRECIO_DE_HOY,1)
				+isnull(
					INTERES_GANADO_2
					*dbo.fnDias3(
						 latest_inicio
						,@v_fecha_base
						,iif(TVL_CODIGO='PCO' and @v_fecha_base>='2025-12-31T23:59:59',tiv_tipo_base,354)
					)
				,0)
			)--,sum(valor_nominal)--isnull(sum(sal*case when tipo_renta='RENTA VARIABLE' then tiv_valor_nominal else 1 end),0)
		end
	,baseFecha=
	formatmessage('INVERSIONES NO PRIVATIVAS (%s)'
		--,case when tipoRenta='Renta fija' then 'FIJA' when tipoRenta='Renta variable' then 'VARIABLE' end
		,format(@v_fecha_base,'dd/MM/yyyy'))
	from --(values('Renta variable'),('Renta fija')) v(tipoRenta)
	--left join
	[_temp].[ObtenerInfoPortfoliosPorFechaResult] pc --on pc.tipo_renta=v.tipoRenta
	where isnull(ipr_es_cxc,0)=0 and VALOR_NOMINAL>0
	--group by tipoRenta
	union
	select
	tipoRenta=null
	,baseSal=sum(saldo)
	,baseFecha=formatmessage('INVERSIONES PRIVATIVAS (%s)',format(@v_fecha_base,'dd/MM/yyyy'))
	from
	--BVQ_BACKOFFICE.isspol_saldo_inicial
	(
		select per.fecha_hasta,saldo,cuenta.cuenta
		FROM siisspolweb.siisspolweb.contabilidad.saldo A with (nolock)
		INNER JOIN siisspolweb.siisspolweb.contabilidad.cuenta with (nolock)
				ON a.id_cuenta = cuenta.id_cuenta
		INNER JOIN siisspolweb.siisspolweb.contabilidad.periodo per with (nolock)
				ON A.id_periodo = per.id_periodo
		WHERE /*id_periodo =167  
		AND*/ 1=1--cuenta.movimiento = 1  
		and cuenta.cuenta='71303'
	)
	s
	where datediff(MM,@v_fecha_base,fecha_hasta)=0
	order by tipoRenta

	

	delete from corteslist
	insert into corteslist values (@i_fecha_corte,1)

	;with a as(
		select tpo_recursos
		,vn=sal*case when tiv_tipo_renta=154 then coalesce(VNU.VNU_VALOR,tiv_valor_nominal) else 1 end
		,pai=case when tpo_recursos='pai' then 1 else 0 end*sal*case when tiv_tipo_renta=154 then coalesce(VNU.VNU_VALOR,tiv_valor_nominal) else 1 end
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
		when tvl_codigo in ('FI') or tfcorte>='20251126' and tvl_codigo='CDP' then 'FONDOS DE INVERSIÓN COLECTIVO / COTIZADO'
		when tvl_codigo in ('CDP','VTP') then 'VALORES DE PARTICIPACIÓN'
		end--,*
		--when 
		from bvq_backoffice.portafoliocorte pc
		left join BVQ_BACKOFFICE.VALOR_NOMINAL_UNITARIO VNU ON VNU.TIV_ID=pc.TIV_ID and pc.tfcorte>=VNU.VNU_FECHA_INICIO and pc.tfcorte<VNU.VNU_FECHA_FIN
		where isnull(ipr_es_cxc,0)=0 and sal>0
	) select
		 sal=isnull(sum(vn),0)
		,pai=isnull(sum(pai),0)
		,excedentes=isnull(sum(excedentes),0)
		,sinClasificar=isnull(sum(sinClasificar),0)
		,sec.TIPO_RENTA,sec.SECTOR,PCT,alert
	,r=row_number() over (partition by sec.TIPO_RENTA order by ord desc)
	from
	(values
		 (1,'19000101','2025-12-08T23:59:59')
		,(2,'20251209','2999-12-31T23:59:59')
	) lim(LIM_ID, LIM_DESDE, LIM_HASTA)
	join
	BVQ_BACKOFFICE.ISSPOL_DETALLE_LIMITES sec
	on sec.LIM_ID=lim.LIM_ID
	left join a
	on sec.SECTOR=a.sector
	where @i_fecha_corte between LIM_DESDE and LIM_HASTA
	group by sec.sector,sec.tipo_renta,pct,ord,alert order by ord

end
