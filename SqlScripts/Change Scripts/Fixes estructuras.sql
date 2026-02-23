--select tiv_codigo_titulo_sic='02'+right(inscripcion_cpmv,5)
--from _temp.TempEstructuraIsspolView t join bvq_administracion.titulo_valor tiv on TIV_NUMERO_RMV=inscripcion_cpmv
--where errores<>'' and tiv_codigo_titulo_sic='0206258'
delete from corteslist
insert into corteslist values ('20231231',1)
exec bvq_backoffice.generarcompraventaflujo

update tiv set tiv_codigo_titulo_sic='02'+right(tiv_numero_rmv,5)
--select tiv_codigo_titulo_sic,'02'+right(tiv_numero_rmv,5)
from
bvq_administracion.titulo_valor tiv
join bvq_administracion.emisor emi on tiv.tiv_emisor=emi.ems_id
join
(values ('','INMOBILIARIA MONTECRISTI','01-01-1900'),
('2012.2.02.01070','DOLMEN S.A.','01-01-1900'),
('2013.1.02.01170','ENERGY & PALMA ENERGY PALMA S.A.','01-01-1900'),
('2022.G.02.003427','NOVACREDIT S.A.','17-05-2024'),
('2022.G.02.003445','FABRICA DE DILUYENTES Y ADHESIVOS DISTHER C. LTDA. DISTHER','07-06-2024'),
('2022.G.02.003448','STARCARGO CÍA. LTDA.','25-05-2024'),
('2022.G.02.003613','SALCEDO MOTORS S.A. SALMOTORSA','12-04-2024'),
('2022.Q.02.003473','SUPERDEPORTE S.A.','21-06-2024'),
('2022.Q.02.003561','SUPERDEPORTE S.A.','12-04-2024'),
('2022.Q.02.003561','SUPERDEPORTE S.A.','28-02-2024'),
('2022.Q.02.003590','CORPORACION ECUATORIANA DE ALIMENTOS Y BEBIDAS CORPABE S.A.','26-03-2024'),
('2023.G.02.003643','CORPETROLSA S.A.','19-06-2024'),
('2023.G.02.003668','CARTIMEX S.A.','12-04-2024'),
('2023.G.02.003685','LA FABRIL S.A','21-09-2024'),
('2023.G.02.003764','FABRICA DE DILUYENTES Y ADHESIVOS DISTHER C. LTDA. DISTHER','20-09-2024'),
('2023.Q.02.003737','CORPORACIÓN ECUATORIANA DE ALUMINIO S.A. CEDAL','23-09-2024'),
('2023.Q.02.003866','PHARMABRAND S.A.','21-11-2024'))
v(inscripcion_cpmv,ems_nombre,fecha_vencimiento)
on tiv.tiv_numero_rmv=v.inscripcion_cpmv
where tiv_codigo_titulo_sic='0206258'

--web de la bvq, emisiones, fecha de aprobación, calificación y calificadora inicial
if not exists(select * from bvq_administracion.EMISION_CALIFICACION where enc_numero_emision='2023.Q.02.003866' and enc_fecha_desde='20231031')
	insert into bvq_administracion.emision_calificacion(enc_id,enc_numero_emision,cal_id,enc_fecha_desde,enc_valor,enc_estado,enc_numero_corto_emision)
	values((select max(enc_id) from bvq_administracion.emision_calificacion)+1,'2023.Q.02.003866',10,'20231031','AAA',21,'0203866')

--18/feb/2026
--Más valores es CAVAMASA
update cva set cva_codigo_sb='CV08' from bvq_administracion.casa_valores cva where cva_siglas='msv'
--select * from bvq_administracion.casa_valores cva where cva_codigo_sb is null

--resolución en encargo fiduciario
update fon set FON_NUMERO_RESOLUCION='SN',FON_PROCEDENCIA='N'
from bvq_backoffice.portafoliocorte pc
join bvq_backoffice.titulos_portafolio tpo on pc.httpo_id=tpo.tpo_id
join bvq_backoffice.fondo fon on fon.fon_id=tpo.fon_id
where tvl_codigo='enc'
--select * from _temp.g3sh where idemi='0993121401001'
--SCVS.INMV.DNNF.2019.1811

--select distinct tiv.tiv_id,tiv_numero_supercias
update tiv set tiv_numero_supercias=replace('SCVS.INMV.DNNF.2019.1811','.','-')
from bvq_backoffice.portafoliocorte pc
join bvq_backoffice.titulos_portafolio tpo on pc.httpo_id=tpo.tpo_id
join bvq_backoffice.fondo fon on fon.fon_id=tpo.fon_id
join bvq_administracion.titulo_valor tiv on tpo.tiv_id=tiv.tiv_id
where tvl_codigo='enc'

--bolsa de valores, se probó con el query en el siguiente comentario:
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
--select bolsa_valores,* from _temp.TempEstructuraIsspolViewG2 e where fecha_transaccion='20231231' and bolsa_valores is null

update fon set fon_procedencia='N'
--output deleted.fon_id,deleted.fon_procedencia into _temp.bakBolsa20260219
from bvq_backoffice.estructuraisspolview e--_temp.TempEstructuraIsspolViewG2 e
join --[192.168.2.225].sicav.
bvq_backoffice.fondo fon on fon.fon_id=e.fon_id
--join _temp.g3sh g on fon_vector_reportado<>'' and g.short=FON_VECTOR_REPORTADO
--join bvq_administracion.casa_valores cva on g.casval=cva_codigo_sb
where-- errores not like 'Sin calificación y no es bono.' and errores<>'' and
numero_liquidacion is null and e.fecha_compra<='20140930' and fon_procedencia is null
and left(fon_numeracion,3)='MDF' and oper=0

--es el Fideicomiso Santa Cruz, es extrabursátil
update fon set fon_procedencia='N'
from bvq_backoffice.fondo fon
--select tpo_comision_bolsa,* from bvq_backoffice.titulos_portafolio
where fon_id=475

--el Bono del acta '02-2022, en las estructuras de ejemplo se declara la bolsa como 'N'
--no la encontré en las liquidaciones de bolsa. Por otra parte el interés transcurrido está en la comisión de bolsa
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
update fon set fon_procedencia='N'
--select fon_procedencia,*
--select --tpo_acta,
--tpo_comision_bolsa,tpo_interes_transcurrido,*
--select fon.*--sum(tpo_cantidad)/1e6,sum(tpo_comision_bolsa)--,*
from bvq_backoffice.fondo fon
join bvq_backoffice.titulos_portafolio tpo on tpo.fon_id=fon.fon_id
where fon.fon_id=472 and tpo_acta='02-2022'

/*
Nombre del emisor	Tipo de instrumento	Id de inversión	Tipo de identificación del emisor	Identificación del emisor	Código identificador del instrumento	Tipo de instrumento	Identificación del instrumento	Bolsa de valores que se negocia	Fecha de emisión	Fecha de compra	Fecha de vencimiento	Tipo tasa	Base para tasa interés	Tasa nominal	Valor nominal	Precio de compra	Valor en efectivo/libros	Plazo inicial	Período de amortización	Periodicidad de pago de cupón	Nro. de documento de aprobación de la inversión	Nro. de resolución / decreto	Nro. de inscripción CPMV	Casa de valores en la que se negocia	Tipo de identificación del custodio	Identificación del Custodio de valores	Calificación de riesgo de la emisión	Calificadora de riesgo de la emisión 	Fecha ultima calificación de riesgos	Precio de mercado	Fecha  precio de mercado	No. Acciones/Unidades de participación	Valor de acción/Unidades de participación 	Fondos de inversión	Errores
DOLMEN S.A.	Acciones	175	R	0990319723001  	07	20	DOL			24/12/2015					386850	0	386850	0	RV	RV	SN	SC-IMV-DJMV-DAYR-G-12-0004413	2012.2.02.01070				30	0		0	31/12/2023	15474	0		
Nombre del emisor	Tipo de instrumento	Id de inversión	Tipo de identificación del emisor	Identificación del emisor	Código identificador del instrumento	Tipo de instrumento	Identificación del instrumento	Bolsa de valores que se negocia	Fecha de emisión	Fecha de compra	Fecha de vencimiento	Tipo tasa	Base para tasa interés	Tasa nominal	Valor nominal	Precio de compra	Valor en efectivo/libros	Plazo inicial	Período de amortización	Periodicidad de pago de cupón	Nro. de documento de aprobación de la inversión	Nro. de resolución / decreto	Nro. de inscripción CPMV	Casa de valores en la que se negocia	Tipo de identificación del custodio	Identificación del Custodio de valores	Calificación de riesgo de la emisión	Calificadora de riesgo de la emisión 	Fecha ultima calificación de riesgos	Precio de mercado	Fecha  precio de mercado	No. Acciones/Unidades de participación	Valor de acción/Unidades de participación 	Fondos de inversión	Errores
ENERGY & PALMA ENERGY PALMA S.A.	Acciones	205	R	1391738986001  	07	20	EYP			31/03/2023					46300	0	23247,23	0	RV	RV	I-RES-2023-013-CINV-ISSPOL 	Q.IMV.2013.2320	2013.1.02.01170				30	0		0	31/12/2023	463	0		
Nombre del emisor	Tipo de instrumento	Id de inversión	Tipo de identificación del emisor	Identificación del emisor	Código identificador del instrumento	Tipo de instrumento	Identificación del instrumento	Bolsa de valores que se negocia	Fecha de emisión	Fecha de compra	Fecha de vencimiento	Tipo tasa	Base para tasa interés	Tasa nominal	Valor nominal	Precio de compra	Valor en efectivo/libros	Plazo inicial	Período de amortización	Periodicidad de pago de cupón	Nro. de documento de aprobación de la inversión	Nro. de resolución / decreto	Nro. de inscripción CPMV	Casa de valores en la que se negocia	Tipo de identificación del custodio	Identificación del Custodio de valores	Calificación de riesgo de la emisión	Calificadora de riesgo de la emisión 	Fecha ultima calificación de riesgos	Precio de mercado	Fecha  precio de mercado	No. Acciones/Unidades de participación	Valor de acción/Unidades de participación 	Fondos de inversión	Errores
RETRATOREC S.A.	Acciones	538	R	0992212640001  	07	20	RTT			31/03/2017					21343	0	74700,5	0	RV	RV	SN	SC.IMV.DJMV.DAYR.G.12.0001473	2012.2.02.01033				22	9	14/02/2012	0	31/12/2023	21343	0		
*/

--son acciones que aparentemente son aportes directos al portafolio, las de rtt y eyp son dividendos en acciones
--no las encontré en el slc ni en el ejemplo proporcionado
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
update fon set fon_procedencia='N'
--select fon_procedencia,*
from bvq_backoffice.fondo fon
join bvq_backoffice.titulos_portafolio tpo on tpo.fon_id=fon.fon_id
join (values ('DOL-','20151224'),('RTT-','20170331'),('EYP-','20230331')) v(abr,fcompra)
on fon.fon_numeracion like abr+'%' and tpo_fecha_ingreso=fcompra
where fon_procedencia is null
and fon.fon_id in (175,205,538)--472 and tpo_acta='02-2022'

--select fon_cva_id from bvq_backoffice.fondo where fon_id in (135,172,198,199,200,236,526,505,533)
--operaciones con bolsa de gye pero sin casa de valores, no sé porqué esta el número de liquidación del slc
--, eso indicaría que no está bien el número de liquidación de Gye
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
output deleted.fon_id into _temp.bakFonCva20260220(fon_id)
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



select fon_numero_liquidacion,fon_numliq_temp,fon_procedencia,tpo_fecha_ingreso,* from bvq_backoffice.fondo fon join bvq_backoffice.titulos_portafolio tpo on fon.fon_id=tpo.fon_id
left join bvq_backoffice.isspol_progs ipr on ipr_nombre_prog=tpo_prog
where isnull(ipr_es_cxc,0)=0 and tpo_fecha_ingreso<'20231231' and fon_procedencia='G'-- is null--='' and fon_numeracion not like 'mdf%'
order by tpo.tpo_fecha_ingreso,fon.fon_numeracion





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


/*
--update fon set FON_CVA_ID=38

select distinct fon.fon_id,fon_cva_id
from _temp.TempEstructuraIsspolView e
join /*[192.168.2.114].*/sicav.bvq_backoffice.fondo fon on fon.fon_id=e.fon_id
join _temp.g3sh g on fon_vector_reportado<>'' and g.short=FON_VECTOR_REPORTADO
--join bvq_administracion.casa_valores cva on g.casval=cva_codigo_sb
where-- errores not like 'Sin calificación y no es bono.' and errores<>'' and
numero_liquidacion is null and e.fecha_compra<='20140930'


update a set cva_codigo_sb=b.cva_codigo_sb
from bvq_administracion.casa_valores a
join [192.168.2.114].sicavtestbatch.bvq_administracion.casa_valores b on a.cva_id=b.cva_id
*/

--procedencia de bonos antiguos
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
update fon set FON_NUMERO_LIQUIDACION=iif(pr='Q',aru_opc_numope,null),FON_NUMLIQ_TEMP=iif(pr='G',aru_opc_numope,null),FON_PROCEDENCIA=pr-- *
--select aru_opc_numope,pr,fon.*
from a left join b
on b.aru_opc_FchVal=a.htp_fecha_operacion and b.aru_opc_valnom=a.montooper and b.aru_opc_fchventit=a.tiv_fecha_vencimiento
and a.r=b.r
join bvq_backoffice.fondo fon on fon.fon_id=a.fon_id
where fon_numero_liquidacion is null and fon_numliq_temp is null and fon_procedencia='N'
--order by a.fon_id--3,4,5