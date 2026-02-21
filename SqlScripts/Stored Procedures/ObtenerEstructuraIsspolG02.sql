alter PROCEDURE [BVQ_BACKOFFICE].[ObtenerEstructuraIsspolG02]
--declare
		@fecha DateTime='20240831',
		@i_todos_los_vigentes bit=0,
		@i_lga_id int=null
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET NOCOUNT ON;
		declare @i_fechaIni DateTime=DATEADD(month, DATEDIFF(month, 0, @fecha), 0);
	delete from corteslist
	insert into corteslist
	values(@fecha,1)


	--declare @sysver bigint = isnull((select min(CTT_ULTIMA_VERSION) from BVQ_ADMINISTRACION.CT_TABLES),0)
	--if 1=1 or exists(
	--	select 1 from changetable(changes bvq_backoffice.HISTORICO_TITULOS_PORTAFOLIO,@sysver) ct
	--	union all select 1 from changetable(changes bvq_backoffice.TITULOS_PORTAFOLIO,@sysver) ct
	--)
	if 1=1
	begin

		begin
			--update bvq_administracion.ct_tables set ctt_ultima_version=change_tracking_current_version()
			exec bvq_backoffice.GenerarCompraVentaFlujo

			exec GenerarCortesListPorRango @i_fechaIni, @fecha
			exec BVQ_ADMINISTRACION.GenerarVectores
			exec bvq_administracion.PrepararValoracionLinealCache
			exec BVQ_BACKOFFICE.GenerarValoracionSB
		end

		exec dropifexists '_temp.TempEstructuraIsspolViewG2'

		if @i_todos_los_vigentes=0
			select
			 Errores=
			 case when Tipo_Instrumento not in (4,5,9,13,20,21,22,23,24,26) and isnull(fecha_ultima_calificacion,0)=0 then
				'Renta fija privada sin calificación.' else '' end
			+case when isnull(Casa_de_Valores_codigo,'')='' and CVA_SIGLAS not in ('MDF') then
				'Sin casa de valores.' else '' end
			,EMS_NOMBRE
			,FON_ID
			,tiv_tipo_renta
			,Vector_Precio
			,Fecha_Vencimiento
			,Fecha_Compra
			,TIPO_ID_EMISOR
			,ID_EMISOR
			,Codigo_Instrumento
			,Tipo_Instrumento
			,id_Instrumento
			,Bolsa_Valores
			,Fecha_Emision
			,Tipo_Tasa
			,Base_Tasa_Interes
			,Tasa_Nominal
	
			,Valor_Nominal
			,Precio_Compra
			,Valor_Efectivo_Libros
			,Plazo_Inicial=isnull(Plazo_Inicial,0)
			,Calificadora_Riesgo_Emision=isnull(Calificadora_Riesgo_Emision,0)
			,Calificacion_Riesgo_Emision=isnull(sbc.codigo,30)
			,Fecha_Ultima_Calificacion
			,Numero_Acciones
			,Valor_Accion=case when tiv_tipo_renta=154 then Precio_Mercado else 0 end
			,Precio_Mercado=case when tiv_tipo_renta=154 then 0 else Precio_Mercado end
	
			,Fecha_Precio_Mercado
			,Fondo_Inversion
			,Periodo_Amortizacion_codigo
			,Periodo_Amortizacion
			,Periodicidad_Cupon_codigo
			,Periodicidad_Cupon
			,Casa_de_Valores_codigo
			,Casa_Valores
			,Tipo_Id_Custodio
	
			,Documento_Aprobacion=numero_resolucion
			,Resolucion_Decreto
			,Nro_de_Inscripcion_Decreto
			,Inscripcion_CPMV
			,Id_Custodio
			,Numero_liquidacion
			,Tipo_transaccion
			,Fecha_transaccion
			,Dias_transcurridos
			,Dias_por_vencer
			,Yield
			,TVS_DESCRIPCION
			into _temp.TempEstructuraIsspolViewG2
			from BVQ_BACKOFFICE.EstructuraIsspolView
			left join BVQ_ADMINISTRACION.SB_CALIFICACIONES sbc on sbc.sandp=Calificacion_Riesgo_Emision
			where esCxc=0 and oper=0
			and (
				Fecha_transaccion between @i_fechaIni and @fecha
				or @i_todos_los_vigentes=1
			)
		else
			select
			 Errores=
			 case when Tipo_Instrumento not in (4,5,9,13,20,21,22,23,24,26) and isnull(fecha_ultima_calificacion,0)=0 then
				'Renta fija privada sin calificación.' else '' end
			+case when isnull(Casa_de_Valores_codigo,'')='' and CVA_SIGLAS not in ('MDF') then
				'Sin casa de valores.' else '' end
			,EMS_NOMBRE
			,FON_ID
			,tiv_tipo_renta
			,Vector_Precio
			,Fecha_Vencimiento
			,Fecha_Compra
			,TIPO_ID_EMISOR
			,ID_EMISOR
			,Codigo_Instrumento
			,Tipo_Instrumento
			,id_Instrumento
			,Bolsa_Valores
			,Fecha_Emision
			,Tipo_Tasa
			,Base_Tasa_Interes
			,Tasa_Nominal
	
			,Valor_Nominal
			,Precio_Compra
			,Valor_Efectivo_Libros
			,Plazo_Inicial=isnull(Plazo_Inicial,0)
			,Calificadora_Riesgo_Emision=isnull(Calificadora_Riesgo_Emision,0)
			,Calificacion_Riesgo_Emision=isnull(sbc.codigo,30)
			,Fecha_Ultima_Calificacion
			,Numero_Acciones
			,Valor_Accion=case when tiv_tipo_renta=154 then Precio_Mercado else 0 end
			,Precio_Mercado=case when tiv_tipo_renta=154 then 0 else Precio_Mercado end
	
			,Fecha_Precio_Mercado
			,Fondo_Inversion
			,Periodo_Amortizacion_codigo
			,Periodo_Amortizacion
			,Periodicidad_Cupon_codigo
			,Periodicidad_Cupon
			,Casa_de_Valores_codigo
			,Casa_Valores
			,Tipo_Id_Custodio
	
			,Documento_Aprobacion=numero_resolucion
			,Resolucion_Decreto
			,Nro_de_Inscripcion_Decreto
			,Inscripcion_CPMV
			,Id_Custodio
			,Numero_liquidacion
			,Tipo_transaccion
			,Fecha_transaccion
			,Dias_transcurridos
			,Dias_por_vencer
			,Yield
			,TVS_DESCRIPCION
			into _temp.TempEstructuraIsspolViewG2
			from BVQ_BACKOFFICE.EstructuraIsspolView
			left join BVQ_ADMINISTRACION.SB_CALIFICACIONES sbc on sbc.sandp=Calificacion_Riesgo_Emision
			where esCxc=0 and oper=-1
			and datediff(d,fecha_transaccion,@fecha)=0 -- 1 para T-1
	end

	select * from _temp.TempEstructuraIsspolViewG2

END
select * from BVQ_ADMINISTRACION.SB_CALIFICACIONES
/*
go
exec [BVQ_BACKOFFICE].[ObtenerEstructuraIsspolG02] '20231231',1,null
insert into corteslist
values('20231231',1)
select distinct tfcorte,tvl_codigo from bvq_backoffice.portafoliocorte pc where sal>0 and isnull(ipr_es_cxc,0)=0
select 12272727.27/15e6
select count(*) from bvq_backoffice.valoracion_sb

select fecha_compra,left(fon_numeracion,3),count(*),format(sum(valor_nominal),'n2')
--,len(fon_vector_reportado)--,valnom,bolsa,casval
--,cva.cva_id,cva.cva_nombre
--,format(valor_nominal,'n2'),fon.*,fecha_compra,casa_de_valores_codigo,casa_valores,numero_liquidacion, *
--update fon set FON_CVA_ID=38
--select distinct fon.fon_id
--select fon.*
exec BVQ_ADMINISTRACION.GenerarVectores
exec bvq_administracion.PrepararValoracionLinealCache
exec bvq_backoffice.generarvaloracionsb
select fon.fon_id,fecha_compra,sum(valor_nominal)/1e6--fecha_compra,fon_numeracion,valor_nominal,fon.fon_id
--create table _temp.bakBolsa20260219(fon_id int, fon_procedencia varchar(10))
--update fon set fon_procedencia='N'
--output deleted.fon_id,deleted.fon_procedencia into _temp.bakBolsa20260219
from bvq_backoffice.estructuraisspolview e--_temp.TempEstructuraIsspolViewG2 e
join --[192.168.2.225].sicav.
bvq_backoffice.fondo fon on fon.fon_id=e.fon_id
--join _temp.g3sh g on fon_vector_reportado<>'' and g.short=FON_VECTOR_REPORTADO
--join bvq_administracion.casa_valores cva on g.casval=cva_codigo_sb
where-- errores not like 'Sin calificación y no es bono.' and errores<>'' and
numero_liquidacion is null and e.fecha_transaccion='20231231'--e.fecha_compra<='20140930' --and fon_procedencia is null
and left(fon_numeracion,3)='MDF' and oper=-1--0

group by fecha_compra,fon.fon_id with rollup
order by fon.fon_id,e.fecha_compra
--select fon_procedencia,count(*) from bvq_backoffice.fondo group by fon_procedencia

select aru_opc_fchval,count(*),format(sum(aru_opc_valnom),'n2')
from BVQ_BACKOFFICE.operaciones_cerradas oc
join isspolmay2025.dbo.aru_opecer opc on aru_opc_anoope=opc_ano_ope and aru_opc_numope=opc_num_ope
and aru_opc_procedencia=opc_procedencia  collate modern_spanish_ci_ai
join isspolmay2025.dbo.asi_emisor emi on aru_opc_codemi=asi_emi_codemi collate modern_spanish_ci_ai
join isspolmay2025.dbo.asi_titulo tit on asi_tit_codtit=aru_opc_codtit
where asi_emi_abremi='MDF' and asi_tit_abrtit='BON' and aru_opc_anoope between '2013' and '2022'-- between '20130101' and '20230101'--='20140612' --order by opc.aru_opc_valnom,cve.aru_cve_estcomven
group by aru_opc_fchval with rollup
order by opc.aru_opc_fchval


			exec BVQ_ADMINISTRACION.GenerarVectores
			exec bvq_administracion.PrepararValoracionLinealCache

select aru_opc_fchval,count(*),format(sum(aru_opc_valnom),'n2')
--asi_tit_abrtit,asi_emi_abremi,format(aru_opc_valnom,'c2'),aru_opc_fchval,aru_opc_fchope,aru_opc_fchemitit,aru_opc_fchventit,aru_opc_procedencia,aru_opc_hrsope,aru_cve_estcomven,aru_cve_codcasval,asi_csv_nomcasval,*
from BVQ_BACKOFFICE.operaciones_cerradas oc
join isspolmay2025.dbo.aru_opecer opc on aru_opc_anoope=opc_ano_ope and aru_opc_numope=opc_num_ope
and aru_opc_procedencia=opc_procedencia  collate modern_spanish_ci_ai
--join isspolmay2025.dbo.aru_comven cve on aru_cve_anoope=aru_opc_anoope and aru_cve_numope=aru_opc_numope and aru_opc_Procedencia=aru_cve_procedencia
--join isspolmay2025.dbo.asi_casval csv on asi_csv_codcasval=aru_cve_codcasval
join isspolmay2025.dbo.asi_emisor emi on aru_opc_codemi=asi_emi_codemi collate modern_spanish_ci_ai
join isspolmay2025.dbo.asi_titulo tit on asi_tit_codtit=aru_opc_codtit
where asi_emi_abremi='MDF' and asi_tit_abrtit='BON' and aru_opc_fchval between '20130101' and '20230101'--='20140612' --order by opc.aru_opc_valnom,cve.aru_cve_estcomven
--and aru_opc_fchval='20140717'
--and aru_opc_status=1
group by aru_opc_fchval with rollup
order by opc.aru_opc_fchval



--select * from bvq_administracion.casa_valores where cva_siglas='mdf'
select * from bvq_backoffice.fondo where fon_cva_id is not null
--select montooper,htp_tpo_id,* from bvq_backoffice.historico_titulos_portafolio htp where htp_fecha_operacion='20130425'
--select montooper,* from bvq_backoffice.EventoPortafolio where htp_tpo_id in (118,119) and oper=0

*/
--select * from bvq_administracion.casa_valores cva where cva_codigo_sb like 'cv51'

--delete bvq_backoffice.OPERACIONES_CERRADAS
--insert into bvq_backoffice.OPERACIONES_CERRADAS
--select * from [192.168.2.225].sicav.bvq_backoffice.OPERACIONES_CERRADAS-- order by opc_ano_ope
