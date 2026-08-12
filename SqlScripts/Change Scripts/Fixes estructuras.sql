--Cambiar tiv_emisor a 913.
--Cacpeco: EMS_ID=85 tiene EMS_ESTADO=22, EMS_ID=913 tiene EMS_ESTADO=21
--El nombre es idéntico, solo que el nuevo tiene un espacio más
--Decisión:Publicar
update bvq_administracion.titulo_valor set tiv_emisor=913 where tiv_id=1e7+85 and tiv_emisor=85


-----------------------------------------------------------------------------
--Sin calificación por código SIC errado
--Vista de errores, no recuerdo cómo se obtuvo, tal vez la calificación estaba vacía
--exec dropifexists '_temp.tivCodigoTituloSicErr'
--go
--Comprobar que son títulos vencidos hace mucho tiempo (vencen máximo a sept. de 2024)
--son papeles comerciales que no tienen calificación del emisor
select distinct tiv_fecha_vencimiento,tiv_tipo_valor,eca.eca_id,ems.ems_id,ems_codigo,tiv.tiv_id,ems.ems_nombre--,enc.*
from
bvq_administracion.titulo_valor tiv
join bvq_administracion.emisor ems on tiv.tiv_emisor=ems.ems_id
join
_temp.tivCodigoTituloSicErr v
on tiv.tiv_numero_rmv=v.inscripcion_cpmv and tiv.tiv_fecha_vencimiento=convert(date,v.fecha_vencimiento,105)
left join bvq_administracion.emisores_calificacion eca on eca.emi_id=ems.ems_id
join BVQ_ADMINISTRACION.EMISION_CALIFICACION enc on enc_numero_corto_emision='02'+right(tiv_numero_rmv,5)
and enc_estado=21
where tiv_codigo_titulo_sic='0206258'
order by tiv.tiv_fecha_vencimiento desc--,tiv.tiv_id--,ENC_FECHA_DESDE,enc_fecha_hasta
--select try
select ems_codigo,ems_nombre,* from bvq_administracion.emisores_calificacion eca
right join bvq_administracion.emisor ems on eca.emi_id=ems.ems_id
where ems_codigo in ('car','cea','lfb','spd','nvc','srg','sma','dth','cpb','crs')

--select tiv_codigo_titulo_sic='02'+right(inscripcion_cpmv,5)
--from _temp.TempEstructuraIsspolView t join bvq_administracion.titulo_valor tiv on TIV_NUMERO_RMV=inscripcion_cpmv
--where errores<>'' and tiv_codigo_titulo_sic='0206258'








--Corrige tiv_codigo_titulo_sic según tiv_numero_rmv que está correcto
--No es tan grave que cambie en históricos porque antes no tenían calificaciones
update tiv set tiv_codigo_titulo_sic='02'+right(tiv_numero_rmv,5)
--select tiv_codigo_titulo_sic,'02'+right(tiv_numero_rmv,5)
--select tiv_numero_rmv,*
from
bvq_administracion.titulo_valor tiv
join bvq_administracion.emisor emi on tiv.tiv_emisor=emi.ems_id
left join
_temp.tivCodigoTituloSicErr v
on tiv.tiv_numero_rmv=v.inscripcion_cpmv
and tiv.tiv_fecha_vencimiento=convert(date,v.fecha_vencimiento,105)
where tiv_codigo_titulo_sic='0206258'
--Fin sin calificación por código sic errado
--------------------------------------------------------------------------------------


--Calificación de la emisión 02.003866 de Pharmabrand
--Se obtuvo de la web de la bvq, emisiones, fecha de aprobación, calificación y calificadora inicial. Pharmabrand
if not exists(
	select * from bvq_administracion.EMISION_CALIFICACION where enc_numero_emision='2023.Q.02.003866' and enc_fecha_desde='20231031'
)
	insert into bvq_administracion.emision_calificacion
	(enc_id,enc_numero_emision,cal_id,enc_fecha_desde,enc_valor,enc_estado,enc_numero_corto_emision)
	values(
		(select case when max(enc_id)<1e7 then max(enc_id) else 1e7 end from bvq_administracion.emision_calificacion)+1
		,'2023.Q.02.003866',10,'20231031','AAA',21,'0203866'
	)

--18/feb/2026
--"Más Valores" es CAVAMASA
update cva set cva_codigo_sb='CV08' from bvq_administracion.casa_valores cva where cva_siglas='msv'



delete from corteslist
insert into corteslist values ('20231231',1)
exec bvq_backoffice.generarcompraventaflujo

--resolución en encargo fiduciario Santa cruz
update fon set FON_NUMERO_RESOLUCION='SN',FON_PROCEDENCIA='N'
from bvq_backoffice.portafoliocorte pc
join bvq_backoffice.titulos_portafolio tpo on pc.httpo_id=tpo.tpo_id
join bvq_backoffice.fondo fon on fon.fon_id=tpo.fon_id
where tvl_codigo='enc'
--select * from _temp.g3sh where idemi='0993121401001'
--SCVS.INMV.DNNF.2019.1811

--tiv_numero_supercias en encargo fiducuciario
--select distinct tiv.tiv_id,tiv_numero_supercias
update tiv set tiv_numero_supercias='SCVS-INMV-DNNF-2019-1811'
from bvq_backoffice.portafoliocorte pc
join bvq_backoffice.titulos_portafolio tpo on pc.httpo_id=tpo.tpo_id
join bvq_backoffice.fondo fon on fon.fon_id=tpo.fon_id
join bvq_administracion.titulo_valor tiv on tpo.tiv_id=tiv.tiv_id
where tvl_codigo='enc'

--Bolsa de valores (procedencia) --------------------------------------------------
--Se probó con el query en el siguiente comentario:
/*
select aru_opc_fchval,count(*),format(sum(aru_opc_valnom),'n2')

select *
from BVQ_BACKOFFICE.operaciones_cerradas oc
join isspolmay2025.dbo.aru_opecer opc on aru_opc_anoope=opc_ano_ope and aru_opc_numope=opc_num_ope
and aru_opc_procedencia=opc_procedencia  collate modern_spanish_ci_ai
join isspolmay2025.dbo.asi_emisor emi on aru_opc_codemi=asi_emi_codemi collate modern_spanish_ci_ai
join isspolmay2025.dbo.asi_titulo tit on asi_tit_codtit=aru_opc_codtit
where asi_emi_abremi='MDF' and asi_tit_abrtit='BON' and aru_opc_anoope between '2013' and '2022'-- between '20130101' and '20230101'--='20140612' --order by opc.aru_opc_valnom,cve.aru_cve_estcomven
group by aru_opc_fchval with rollup
order by opc.aru_opc_fchval
*/
--EMN: 11-ago-2026 ya no aplica pues ya fue arreglado en producción, se comenta
--select bolsa_valores,* from _temp.TempEstructuraIsspolViewG2 e where fecha_transaccion='20231231' and bolsa_valores is null
--select fon_procedencia,numero_liquidacion,e.fecha_compra,*
/*
update fon set fon_procedencia='N'
--output deleted.fon_id,deleted.fon_procedencia into _temp.bakBolsa20260219
from bvq_backoffice.estructuraisspolview e--_temp.TempEstructuraIsspolViewG2 e
join --[192.168.2.225].sicav.
bvq_backoffice.fondo fon on fon.fon_id=e.fon_id
--join _temp.g3sh g on fon_vector_reportado<>'' and g.short=FON_VECTOR_REPORTADO
--join bvq_administracion.casa_valores cva on g.casval=cva_codigo_sb
where-- errores not like 'Sin calificación y no es bono.' and errores<>'' and
numero_liquidacion is null and e.fecha_compra<='20140930' and fon_procedencia is null
and left(fon_numeracion,3)='MDF' and oper=0*/
--Fin Bolsa de valores (procedencia) -------------------------------------------------



--El Fideicomiso Santa Cruz, es extrabursátil
--EMN: 11-ago-2026 Ya no aplica fue corregido en producción, se comenta
/*
update fon set fon_procedencia='N'
--select fon_procedencia,*
from bvq_backoffice.fondo fon
--select tpo_comision_bolsa,* from bvq_backoffice.titulos_portafolio
where fon_id=475 and isnull(fon_procedencia,'')<>'N'
*/

--Bono del acta '02-2022 -------------------------------------------------
--En las estructuras de ejemplo se declara la bolsa como 'N'
--no la encontré en las liquidaciones de bolsa. Por otra parte el interés transcurrido está en la comisión de bolsa
--EMN: 11-ago-2026 Ya no aplica fue corregido en producción, se comenta
/*
select *
from BVQ_BACKOFFICE.operaciones_cerradas oc
join isspolmay2025.dbo.aru_opecer opc on aru_opc_anoope=opc_ano_ope and aru_opc_numope=opc_num_ope
and aru_opc_procedencia=opc_procedencia  collate modern_spanish_ci_ai
join isspolmay2025.dbo.asi_emisor emi on aru_opc_codemi=asi_emi_codemi collate modern_spanish_ci_ai
join isspolmay2025.dbo.asi_titulo tit on asi_tit_codtit=aru_opc_codtit
where aru_opc_fchemitit='20220504'--val='20220512'
group by aru_opc_fchval with rollup
order by opc.aru_opc_fchval
*/
/*
update fon set fon_procedencia='N'
--select fon_procedencia,*
--select --tpo_acta,
--tpo_comision_bolsa,tpo_interes_transcurrido,*
--select fon.*--sum(tpo_cantidad)/1e6,sum(tpo_comision_bolsa)--,*
from bvq_backoffice.fondo fon
join bvq_backoffice.titulos_portafolio tpo on tpo.fon_id=fon.fon_id
where fon.fon_id=472 and tpo_acta='02-2022'
and isnull(fon_procedencia,'')<>'N'
*/
--Fin Bono del acta '02-2022 ------------------------------------------------


/*
Nombre del emisor	Tipo de instrumento	Id de inversión	Tipo de identificación del emisor	Identificación del emisor	Código identificador del instrumento	Tipo de instrumento	Identificación del instrumento	Bolsa de valores que se negocia	Fecha de emisión	Fecha de compra	Fecha de vencimiento	Tipo tasa	Base para tasa interés	Tasa nominal	Valor nominal	Precio de compra	Valor en efectivo/libros	Plazo inicial	Período de amortización	Periodicidad de pago de cupón	Nro. de documento de aprobación de la inversión	Nro. de resolución / decreto	Nro. de inscripción CPMV	Casa de valores en la que se negocia	Tipo de identificación del custodio	Identificación del Custodio de valores	Calificación de riesgo de la emisión	Calificadora de riesgo de la emisión 	Fecha ultima calificación de riesgos	Precio de mercado	Fecha  precio de mercado	No. Acciones/Unidades de participación	Valor de acción/Unidades de participación 	Fondos de inversión	Errores
DOLMEN S.A.	Acciones	175	R	0990319723001  	07	20	DOL			24/12/2015					386850	0	386850	0	RV	RV	SN	SC-IMV-DJMV-DAYR-G-12-0004413	2012.2.02.01070				30	0		0	31/12/2023	15474	0		
Nombre del emisor	Tipo de instrumento	Id de inversión	Tipo de identificación del emisor	Identificación del emisor	Código identificador del instrumento	Tipo de instrumento	Identificación del instrumento	Bolsa de valores que se negocia	Fecha de emisión	Fecha de compra	Fecha de vencimiento	Tipo tasa	Base para tasa interés	Tasa nominal	Valor nominal	Precio de compra	Valor en efectivo/libros	Plazo inicial	Período de amortización	Periodicidad de pago de cupón	Nro. de documento de aprobación de la inversión	Nro. de resolución / decreto	Nro. de inscripción CPMV	Casa de valores en la que se negocia	Tipo de identificación del custodio	Identificación del Custodio de valores	Calificación de riesgo de la emisión	Calificadora de riesgo de la emisión 	Fecha ultima calificación de riesgos	Precio de mercado	Fecha  precio de mercado	No. Acciones/Unidades de participación	Valor de acción/Unidades de participación 	Fondos de inversión	Errores
ENERGY & PALMA ENERGY PALMA S.A.	Acciones	205	R	1391738986001  	07	20	EYP			31/03/2023					46300	0	23247,23	0	RV	RV	I-RES-2023-013-CINV-ISSPOL 	Q.IMV.2013.2320	2013.1.02.01170				30	0		0	31/12/2023	463	0		
Nombre del emisor	Tipo de instrumento	Id de inversión	Tipo de identificación del emisor	Identificación del emisor	Código identificador del instrumento	Tipo de instrumento	Identificación del instrumento	Bolsa de valores que se negocia	Fecha de emisión	Fecha de compra	Fecha de vencimiento	Tipo tasa	Base para tasa interés	Tasa nominal	Valor nominal	Precio de compra	Valor en efectivo/libros	Plazo inicial	Período de amortización	Periodicidad de pago de cupón	Nro. de documento de aprobación de la inversión	Nro. de resolución / decreto	Nro. de inscripción CPMV	Casa de valores en la que se negocia	Tipo de identificación del custodio	Identificación del Custodio de valores	Calificación de riesgo de la emisión	Calificadora de riesgo de la emisión 	Fecha ultima calificación de riesgos	Precio de mercado	Fecha  precio de mercado	No. Acciones/Unidades de participación	Valor de acción/Unidades de participación 	Fondos de inversión	Errores
RETRATOREC S.A.	Acciones	538	R	0992212640001  	07	20	RTT			31/03/2017					21343	0	74700,5	0	RV	RV	SN	SC.IMV.DJMV.DAYR.G.12.0001473	2012.2.02.01033				22	9	14/02/2012	0	31/12/2023	21343	0		
*/

--Acciones que aparentemente son aportes directos al portafolio
--, las de rtt y eyp son dividendos en acciones
--no las encontré en el slc ni en el ejemplo proporcionado
--EMN: 11-ago-2026 Ya no aplica fue corregido en producción, se comenta
/*
select a06,* from _temp.g3sh where idemi in ('0990319723001','1391738986001','0992212640001')
select asi_emi_abremi,aru_opc_numacc*aru_opc_valnomacc,opc.*--asi_emi_abremi,aru_opc_valnomacc,*
from BVQ_BACKOFFICE.operaciones_cerradas oc
join isspolmay2025.dbo.aru_opecer opc on aru_opc_anoope=opc_ano_ope and aru_opc_numope=opc_num_ope
and aru_opc_procedencia=opc_procedencia  collate modern_spanish_ci_ai
join isspolmay2025.dbo.asi_emisor emi on aru_opc_codemi=asi_emi_codemi collate modern_spanish_ci_ai
join isspolmay2025.dbo.asi_titulo tit on asi_tit_codtit=aru_opc_codtit
where asi_emi_abremi in ('dol','rtt','eyp')
*/
--select * 
/*
update fon set fon_procedencia='N'
--select fon_procedencia,*
from bvq_backoffice.fondo fon
join bvq_backoffice.titulos_portafolio tpo on tpo.fon_id=fon.fon_id
join (values ('DOL-','20151224'),('RTT-','20170331'),('EYP-','20230331')) v(abr,fcompra)
on fon.fon_numeracion like abr+'%' and tpo_fecha_ingreso=fcompra
where fon_procedencia is null
and fon.fon_id in (175,205,538)--472 and tpo_acta='02-2022'
and isnull(fon.fon_procedencia,'')<>'N'
--select fon_cva_id from bvq_backoffice.fondo where fon_id in (135,172,198,199,200,236,526,505,533)
*/
--Fin acciones que son aparentemente aportes directos al portafolio

--Operaciones con bolsa de gye pero sin casa de valores --------------------------------------------------------
--No sé porqué está el número de liquidación del slc, eso indicaría que no está bien el número de liquidación de Gye
--EMN: 11-ago-2026 Ya no aplica fue corregido en producción, se comenta
/*
if object_id('_temp.bakFonCva20260220') is null
begin
	create table _temp.bakFonCva20260220(fon_id int)
end
;with a as(
	select --numero_liquidacion,fecha_compra,valor_nominal,
	distinct ems_nombre,fecha_compra,fon_id--.*
	from bvq_backoffice.estructuraIsspolView g
	--left join bvq_backoffice.operaciones_cerradas oc on numero_liquidacion=opc_num_ope
	--join bvq_backoffice.fondo fon
	--join bvq_backoffice.titulos_portafolio tpo on tpo.fon_id=fon.fon_id
	--on fon.fon_id=g.fon_id
	where bolsa_valores in ('q','y') and isnull(casa_valores,'')=''-- and oper=-1
	and fecha_transaccion='20231231'
	--select * from bvq_backoffice.operaciones_cerradas where opc_num_ope in ('')
)
--select cva.cva_id,a.fon_id,fon.fon_cva_id,cva_siglas,fon_procedencia
--,aru_cve_estcomven,asi_csv_nomcasval,aru_opc_procedencia,asi_emi_nomemi,ems_nombre,*
update fon set fon_cva_id=cva.cva_id
--output deleted.fon_id into _temp.bakFonCva20260220(fon_id)
from a join bvq_backoffice.fondo fon on fon.fon_id=a.fon_id
join
	isspolmay2025.dbo.aru_opecer opc
	join isspolmay2025.dbo.asi_emisor emi on aru_opc_codemi=asi_emi_codemi collate modern_spanish_ci_ai
	join isspolmay2025.dbo.asi_titulo tit on asi_tit_codtit=aru_opc_codtit
on aru_opc_numope=coalesce(fon_numero_liquidacion,fon_numliq_temp) and fecha_compra=aru_opc_fchval
join isspolmay2025.dbo.aru_comven cve on aru_opc_numope=aru_cve_numope and aru_opc_procedencia=aru_cve_procedencia and aru_opc_anoope=aru_cve_anoope and aru_cve_estcomven=1
join isspolmay2025.dbo.asi_casval csv on asi_csv_codcasval=aru_cve_codcasval
join bvq_administracion.casa_valores cva on cva_siglas=asi_csv_abrcasval collate modern_spanish_ci_ai
where fon_procedencia='G'
*/
--Fin operaciones con bolsa de gye pero sin casa de valores --------------------------------------------------------


/*
select fon_numero_liquidacion,fon_numliq_temp,fon_procedencia,tpo_fecha_ingreso,* from bvq_backoffice.fondo fon join bvq_backoffice.titulos_portafolio tpo on fon.fon_id=tpo.fon_id
left join bvq_backoffice.isspol_progs ipr on ipr_nombre_prog=tpo_prog
where isnull(ipr_es_cxc,0)=0 and tpo_fecha_ingreso<'20231231' and fon_procedencia='G'-- is null--='' and fon_numeracion not like 'mdf%'
order by tpo.tpo_fecha_ingreso,fon.fon_numeracion
*/



/*
select tiv_precio,*
from bvq_backoffice.portafolioCortePrcInt pc
join bvq_backoffice.titulos_portafolio tpo on pc.httpo_id=tpo.tpo_id
where tpo.fon_id in (171,204,537)
select precio_mercado,* from _temp.tempestructuraisspolviewg2 where fon_id in (171,204,537)

select precio_mercado,* from bvq_backoffice.estructuraisspolview e where fon_id in (171,204,537) and oper=-1 and fecha_transaccion='20231231'


select pju_id,* from bvq_administracion.emisor where ems_nombre like '%energy%'
select * from bvq_administracion.persona_juridica where pju_id=459
where aru_opc_fchval='20151224'--val='20220512'
group by aru_opc_fchval with rollup
order by opc.aru_opc_fchval
*/

/*
--update fon set FON_CVA_ID=38
select distinct fon.fon_id,fon_cva_id
from sicavtestbatch._temp.TempEstructuraIsspolView e
join /*[192.168.2.114].*/sicav.bvq_backoffice.fondo fon on fon.fon_id=e.fon_id
join sicavtestbatch._temp.g3sh g on fon_vector_reportado<>'' and g.short=FON_VECTOR_REPORTADO
--join bvq_administracion.casa_valores cva on g.casval=cva_codigo_sb
where-- errores not like 'Sin calificación y no es bono.' and errores<>'' and
numero_liquidacion is null and e.fecha_compra<='20140930' and isnull(fon.fon_cva_id,-1)<>38
*/

--Obtener código de casa de valores de una aplicación anterior
--EMN: 11-ago-2026 ya no aplica, ya fue solucionado anteriormente.
--Se comenta
/*
update a set cva_codigo_sb=b.cva_codigo_sb
--
--select distinct a.cva_codigo_sb,b.cva_codigo_sb
from bvq_administracion.casa_valores a
join --[192.168.2.114].
sicav.bvq_administracion.casa_valores b on a.cva_id=b.cva_id
*/

--Procedencia y números de liquidación de bonos antiguos---------------------------------------------
--Update: 11-ago-2026 Ya no hace nada porque los números de liquidación ya fueron llenados en producción
--Se comenta
/*
;with a as(
	--group by aru_opc_fchval,aru_opc_numope --with rollup--,aru_opc_numope --with rollup
	--order by opc.aru_opc_fchval--,aru_opc_numope
	--union all
	select
	 r=row_number() over (partition by htp_fecha_operacion,convert(money,sum(coalesce(errValNom,montooper))),max(tiv_fecha_vencimiento)
		order by max(inv.fon_procedencia_null))
	,1 t,htp_fecha_operacion
	,convert(money,sum(coalesce(errValNom,montooper))) montooper
	,tiv_fecha_vencimiento=max(tiv_fecha_vencimiento)
	,numliq=try_cast(coalesce(fixNumeroLiquidacion,fixNumLiqTemp) as varchar)
	,fon_procedencia_null=max(inv.fon_procedencia_null)
	,tpo.fon_id,tpo_numeracion
	from bvq_backoffice.EventoPortafolio evp
	join bvq_backoffice.titulos_portafolio tpo on tpo.tpo_id=evp.htp_tpo_id
	join bvq_backoffice.inversion inv on tpo.fon_id=inv.fon_id
	left join bvq_backoffice.ISSPOL_PROGS ipr on ipr.IPR_NOMBRE_PROG=tpo.tpo_prog
	where errValNom is null --por error incorregible de fon_id=340
	and left(tpo_numeracion,4)='MDF-' and htp_fecha_operacion<='20140930' and oper=0
	group by htp_fecha_operacion,tpo.fon_id,tpo_numeracion,fixNumeroLiquidacion,fixNumLiqTemp
	--order by aru_opc_fchval,aru_opc_valnom,aru_opc_fchventit,t--pr--aru_opc_numope,t
), b as(
	select
	 r=row_number() over (partition by aru_opc_fchval,convert(money,aru_opc_valnom),aru_opc_fchventit order by aru_opc_procedencia)
	,2 t,aru_opc_fchval
	,aru_opc_valnom=convert(money,aru_opc_valnom)
	,aru_opc_fchventit
	,aru_opc_numope=try_cast(rtrim(aru_opc_numope) as varchar)
	,pr=aru_opc_procedencia collate modern_spanish_ci_ai
	,fon_id=null,numeracion=null
	--select *
	from BVQ_BACKOFFICE.operaciones_cerradas oc
	join isspolmay2025.dbo.aru_opecer opc on aru_opc_anoope=opc_ano_ope and aru_opc_numope=opc_num_ope
	and aru_opc_procedencia=opc_procedencia  collate modern_spanish_ci_ai
	join isspolmay2025.dbo.asi_emisor emi on aru_opc_codemi=asi_emi_codemi collate modern_spanish_ci_ai
	join isspolmay2025.dbo.asi_titulo tit on asi_tit_codtit=aru_opc_codtit
	where asi_emi_abremi='MDF' and asi_tit_abrtit='BON' and aru_opc_anoope between '2013' and '2022'-- between '20130101' and '20230101'--='20140612' --order by opc.aru_opc_valnom,cve.aru_cve_estcomven
)
--update fon set FON_NUMERO_LIQUIDACION=iif(pr='Q',aru_opc_numope,null),FON_NUMLIQ_TEMP=iif(pr='G',aru_opc_numope,null),FON_PROCEDENCIA=pr-- *
select aru_opc_numope,pr,fon.*
from a left join b
on b.aru_opc_FchVal=a.htp_fecha_operacion and b.aru_opc_valnom=a.montooper and b.aru_opc_fchventit=a.tiv_fecha_vencimiento
and a.r=b.r
join bvq_backoffice.fondo fon on fon.fon_id=a.fon_id
where fon_numero_liquidacion is null and fon_numliq_temp is null and fon_procedencia='N'
*/
--order by a.fon_id--3,4,5
--Fin procedencia y números de liquidación de bonos antiguos---------------------------------------------


--Patrimonio técnico sobrepuesto, Banco del pacífico
update vba set vba_fecha_hasta='20231108'
--select *
from bvq_administracion.variables_balance vba where ems_id=59 and vba_fecha_hasta='20231231'

--compra_htp_id
--EMN: 4-abr-2026 primera compra
--declare @v_tpo_id int = (select htp_tpo_id from bvq_backoffice.historico_titulos_portafolio where htp_id=@v_htp_id)
/*
update htp set compra_htp_id=primeraCompra.htp_id
--select *
from bvq_backoffice.historico_titulos_portafolio htp
join bvq_backoffice.SecuenciaCompra primeraCompra
	on primeraCompra.htp_tpo_id=htp.htp_tpo_id and primeraCompra.sec=1
where isnull(compra_htp_id,-1)<>isnull(primeraCompra.htp_id,-1)
--where htp.htp_tpo_id=@v_tpo_id
*/

