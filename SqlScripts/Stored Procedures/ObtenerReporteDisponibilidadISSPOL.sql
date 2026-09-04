CREATE procedure [BVQ_BACKOFFICE].[ObtenerReporteDisponibilidadISSPOL]
	@i_fechaFin datetime = '2024-05-31T23:59:59',--null,
	@i_lga_id int
AS

BEGIN
	SET NOCOUNT ON;

	declare @v_fechaIni datetime, @v_oper int
	declare @fechaCorte  date,
		@fecha_inicio date
	set @v_fechaIni = dateadd(s, -3, DATEADD(dd, 1, DATEDIFF(dd, 0, @i_fechaFin)))
	set @v_oper=1

	set @fechaCorte = dateadd(s, -3, DATEADD(dd, 1, DATEDIFF(dd, 0, @i_fechaFin)))
	set @fecha_inicio = DATEADD(yy, DATEDIFF(yy, 0, @i_fechaFin), 0)

		truncate table corteslist
		insert into corteslist(c,cortenum)
		select @v_fechaIni,1
		exec bvq_administracion.generarcompraventacorte
		exec bvq_administracion.generarvectores
		exec bvq_administracion.PrepararValoracionLinealCache

	
	--[+]	Carga de homologacion de fondos y portafolios
		if (OBJECT_ID('[BVQ_BACKOFFICE].[FONDO_HOMOLOGACION]') is NULL)
		begin
			select distinct por.por_id,por.por_codigo,c.descripcion, c.id_cuenta
			into [BVQ_BACKOFFICE].[FONDO_HOMOLOGACION]
			from BVQ_ADMINISTRACION.ISSPOL_MAPA_FONDOS imf
				join BVQ_BACKOFFICE.PORTAFOLIO por on por.POR_ID=imf.IMF_SICAV
				join inversion.r_fondo_inversion fi on imf.IMF_SIS=fi.id_seguro_tipo
				join isspolBanco.cuenta c on c.id_cuenta=fi.id_cuenta
		end
		else
		begin
			truncate table [BVQ_BACKOFFICE].[FONDO_HOMOLOGACION]
			insert into [BVQ_BACKOFFICE].[FONDO_HOMOLOGACION]
			select distinct por.por_id,por.por_codigo,c.descripcion, c.id_cuenta
			from BVQ_ADMINISTRACION.ISSPOL_MAPA_FONDOS imf
				join BVQ_BACKOFFICE.PORTAFOLIO por on por.POR_ID=imf.IMF_SICAV
				join inversion.r_fondo_inversion fi on imf.IMF_SIS=fi.id_seguro_tipo
				join isspolBanco.cuenta c on c.id_cuenta=fi.id_cuenta
		end
	--[+]	Fin de carga de homologacion de fondos y portafolios

			select
			 portafolio=ICB_DESCRIPCION
			,mov_cuenta_contable
			,fecha_vencimiento=mov_fecha
			,cupon=sum(isnull(fte.MOV_DEBE,0)-isnull(fte.MOV_HABER,0))
			,origen='Real'
			,[real]=1
			,[itc_valor]=upper(sbt.ITC_VALOR)
			,[tipo]=isnull(tipAct.ITC_VALOR,'Sin clasificación')
			,id_cuenta=null
			,[I/E]=tipMov.ITC_VALOR
			,CRC_NUMERO_OPERACION=null
			,id_rubro=null
			,tasa=null
			,producto=null
			,segmento=null
			,estado=null
			,valor=null
			,abono=null
			,tipo_papel=null
			from
			_temp.isspol_movimiento_contable_fuente fte
			join bvq_backoffice.isspol_cuentas_contables_de_bancos icb on icb_cuenta=mov_cuenta_contable
			left join [BVQ_ADMINISTRACION].[ITEM_CATALOGO] tipMov on fte.mov_tipo_movimiento=tipMov.ITC_ID
			left join [BVQ_ADMINISTRACION].[ITEM_CATALOGO] tipAct on fte.mov_tipo_actividad=tipAct.ITC_ID
			left join [BVQ_ADMINISTRACION].[ITEM_CATALOGO] sbt on fte.mov_subtipo=sbt.ITC_ID and sbt.CAT_ID = 328
			where datediff(m,'20230101',mov_fecha)>=0
			group by [ICB_DESCRIPCION],mov_cuenta_contable,mov_fecha,sbt.itc_valor,tipAct.ITC_VALOR,tipMov.ITC_VALOR

			union 
			select
			 portafolio=ICB_DESCRIPCION
			 ,null
			,fecha_vencimiento=mov_fecha
			,cupon=sum(fte.MOV_SALDO)
			,origen='0 Saldo Inicial'
			,[real]=1
			,[itc_valor]=upper(sbt.ITC_VALOR)
			,[tipo]='0 Saldo Inicial'
			,id_cuenta=null
			,[I/E]='0 Saldo Inicial'
			,CRC_NUMERO_OPERACION=null
			,id_rubro=null
			,tasa=null
			,producto=null
			,segmento=null
			,estado=null
			,valor=null
			,abono=null
			,tipo_papel=null
			from
			BVQ_BACKOFFICE.isspol_saldo_inicial fte
			join bvq_backoffice.isspol_cuentas_contables_de_bancos icb on icb_cuenta=mov_cuenta_contable
			left join [BVQ_ADMINISTRACION].[ITEM_CATALOGO] tipMov on fte.mov_tipo_movimiento=tipMov.ITC_ID
			left join [BVQ_ADMINISTRACION].[ITEM_CATALOGO] tipAct on fte.mov_tipo_actividad=tipAct.ITC_ID
			left join [BVQ_ADMINISTRACION].[ITEM_CATALOGO] sbt on fte.mov_subtipo=sbt.ITC_ID and sbt.CAT_ID = 328
			where datediff(m,'20230101',mov_fecha)>=0
			group by [ICB_DESCRIPCION],mov_fecha,sbt.itc_valor,tipAct.ITC_VALOR

			union all
			select distinct 
					portafolio=isnull(fnd.descripcion,'N/A')
					,NULL
					,fecha_vencimiento=convert(date,HTP_FECHA_OPERACION)
					,cupon=sum(TOTAL)
					,origen='Proyectado'
					,[real]=0
					,[itc_valor]='REDENCIÓN NO PRIVATIVAS'
					,[tipo]='Proyectado'
					,fnd.id_cuenta
					,[I/E]='1 Ingreso'
					,CRC_NUMERO_OPERACION=null
					,id_rubro=null
					,tasa=null
					,producto=null
					,segmento=null
					,estado=null
					,valor=null
					,abono=null
					,tipo_papel=TVL_NOMBRE
			from bvq_backoffice.DetallePortafolio dpf
				left join [BVQ_BACKOFFICE].[FONDO_HOMOLOGACION] fnd on fnd.POR_ID=dpf.por_id
				left join BVQ_ADMINISTRACION.TITULO_VALOR tiv on tiv.TIV_ID = dpf.tiv_id
				left join BVQ_ADMINISTRACION.TIPO_VALOR tvl on tvl.TVL_ID = tiv.TIV_TIPO_VALOR
			where 
				(idiff>0.05e or total>0.05e)
				AND datediff(d,@i_fechaFin,dpf.htp_fecha_operacion)>=1-->=@i_fechaFin-->='20230101' and datediff(d,dpf.htp_fecha_operacion,@i_fechaFin)<0
				and (@v_oper is null or oper=@v_oper)
			group by fnd.descripcion,convert(date,HTP_FECHA_OPERACION),fnd.id_cuenta,tvl.TVL_NOMBRE

			/*
			union
			
			select distinct
					fon.fon_homologado
					,ccm.fecha_vencimiento
					,cupon=sum(ccm.total)
					,origen='Privativas'
					,[real]=0
					,[itc_valor]=''
					,null
			from [BVQ_BACKOFFICE].[CREDITOS_CARTERA_MES] ccm
				left join [credito].[FONDO_HOMOLOGACION] fon on ltrim(rtrim(ccm.por_codigo))=ltrim(rtrim(fon.fon_descripcion_credito))
			where
				(ccm.total>0.05e)
				AND datediff(d,@i_fechaFin,ccm.fecha_vencimiento)>=1--ccm.fecha_vencimiento>=@i_fechaFin--'20230101' and datediff(d,ccm.fecha_vencimiento,@i_fechaFin)>=0
			group by fon.fon_homologado,convert(date,ccm.fecha_vencimiento)
			*/
			union
			select
				ccc.por_codigo
				,NULL
				,ccc.fecha_vencimiento
				,cupon=sum(round(ccc.total,2)-round(ccc.total,2))+sum(case when ccc.fecha_vencimiento >= DATEADD(day, 1, CAST(@i_fechaFin AS date)) then ccc.total else 0 end)
				,origen='Proyectado'
				,[real]=0
				,[itc_valor]='REDENCIÓN PRIVATIVAS'
				,[tipo]='Proyectado'
				,id_cuenta = ccc.id_cuenta
				,[I/E]='1 Ingreso'
				,CRC_NUMERO_OPERACION=count(*)
				,ccc.id_rubro
				,ccc.tasa
				,ccc.producto
				,ccc.segmento
				,NULL --estado
				,sum(ccc.total)
				,sum(case when ccc.fecha_vencimiento >= DATEADD(day, 1, CAST(@i_fechaFin AS date)) then ccc.total else 0 end)
				,tipo_papel=null
			from [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA_2] ccc
			where
				ccc.total > 0.05
				AND ccc.fecha_vencimiento >= DATEADD(day, 1, CAST(@i_fechaFin AS date))
			group by ccc.por_codigo,ccc.fecha_vencimiento,ccc.id_cuenta,id_rubro,tasa,producto,segmento


			UNION
			SELECT
				portafolio
				,cuenta_contable
				,fecha_vencimiento
				,cupon
				,origen
				,[real]
				,[itc_valor]
				,[tipo]
				,id_cuenta
				,[I/E]
				,CRC_NUMERO_OPERACION
				,id_rubro
				,tasa
				,producto
				,segmento
				,estado
				,valor
				,abono
				,tipo_papel
			FROM BVQ_BACKOFFICE.PrivativasProyectadas

END
