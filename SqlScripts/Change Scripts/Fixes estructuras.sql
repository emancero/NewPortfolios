--select tiv_codigo_titulo_sic='02'+right(inscripcion_cpmv,5)
--from _temp.TempEstructuraIsspolView t join bvq_administracion.titulo_valor tiv on TIV_NUMERO_RMV=inscripcion_cpmv
--where errores<>'' and tiv_codigo_titulo_sic='0206258'

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
update fon set FON_NUMERO_RESOLUCION='SN'
from bvq_backoffice.portafoliocorte pc
join bvq_backoffice.titulos_portafolio tpo on pc.httpo_id=tpo.tpo_id
join bvq_backoffice.fondo fon on fon.fon_id=tpo.fon_id
where tvl_codigo='enc'

NOTA1: Se realiza el registro conforme a Oficio No. PN-DEF-IN-ISSPOL-QX-2022-0358-I-OF
, que hace referencia al Memorando No. I-ME-2022-60-CD-ISSPOL de 11 de mayo de 2022, relacionado con la Resolución 
No. 58-CD-SO-03-2022-ISSPOL de 10 de Mayo de 2022; 
y memorando No. PN-ISSPOL-QX-2022-2763,de 13 de mayo de 2022 en el que dispone el registro en el portafolio de Inversiones y en Contabilidad.

use isspolmay2025
set language 'spanish'
select * from distrib_header dh where fechacompra='20220512'
select * from distrib where dheaderid in (2529,2829,3180)
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
--select --tpo_acta,
--tpo_comision_bolsa,tpo_interes_transcurrido,*
--select fon.*--sum(tpo_cantidad)/1e6,sum(tpo_comision_bolsa)--,*
from bvq_backoffice.fondo fon
join bvq_backoffice.titulos_portafolio tpo on tpo.fon_id=fon.fon_id
where fon.fon_id=472 and tpo_acta='02-2022'


Nombre del emisor	Tipo de instrumento	Id de inversión	Tipo de identificación del emisor	Identificación del emisor	Código identificador del instrumento	Tipo de instrumento	Identificación del instrumento	Bolsa de valores que se negocia	Fecha de emisión	Fecha de compra	Fecha de vencimiento	Tipo tasa	Base para tasa interés	Tasa nominal	Valor nominal	Precio de compra	Valor en efectivo/libros	Plazo inicial	Período de amortización	Periodicidad de pago de cupón	Nro. de documento de aprobación de la inversión	Nro. de resolución / decreto	Nro. de inscripción CPMV	Casa de valores en la que se negocia	Tipo de identificación del custodio	Identificación del Custodio de valores	Calificación de riesgo de la emisión	Calificadora de riesgo de la emisión 	Fecha ultima calificación de riesgos	Precio de mercado	Fecha  precio de mercado	No. Acciones/Unidades de participación	Valor de acción/Unidades de participación 	Fondos de inversión	Errores
DOLMEN S.A.	Acciones	175	R	0990319723001  	07	20	DOL			24/12/2015					386850	0	386850	0	RV	RV	SN	SC-IMV-DJMV-DAYR-G-12-0004413	2012.2.02.01070				30	0		0	31/12/2023	15474	0		
Nombre del emisor	Tipo de instrumento	Id de inversión	Tipo de identificación del emisor	Identificación del emisor	Código identificador del instrumento	Tipo de instrumento	Identificación del instrumento	Bolsa de valores que se negocia	Fecha de emisión	Fecha de compra	Fecha de vencimiento	Tipo tasa	Base para tasa interés	Tasa nominal	Valor nominal	Precio de compra	Valor en efectivo/libros	Plazo inicial	Período de amortización	Periodicidad de pago de cupón	Nro. de documento de aprobación de la inversión	Nro. de resolución / decreto	Nro. de inscripción CPMV	Casa de valores en la que se negocia	Tipo de identificación del custodio	Identificación del Custodio de valores	Calificación de riesgo de la emisión	Calificadora de riesgo de la emisión 	Fecha ultima calificación de riesgos	Precio de mercado	Fecha  precio de mercado	No. Acciones/Unidades de participación	Valor de acción/Unidades de participación 	Fondos de inversión	Errores
ENERGY & PALMA ENERGY PALMA S.A.	Acciones	205	R	1391738986001  	07	20	EYP			31/03/2023					46300	0	23247,23	0	RV	RV	I-RES-2023-013-CINV-ISSPOL 	Q.IMV.2013.2320	2013.1.02.01170				30	0		0	31/12/2023	463	0		
Nombre del emisor	Tipo de instrumento	Id de inversión	Tipo de identificación del emisor	Identificación del emisor	Código identificador del instrumento	Tipo de instrumento	Identificación del instrumento	Bolsa de valores que se negocia	Fecha de emisión	Fecha de compra	Fecha de vencimiento	Tipo tasa	Base para tasa interés	Tasa nominal	Valor nominal	Precio de compra	Valor en efectivo/libros	Plazo inicial	Período de amortización	Periodicidad de pago de cupón	Nro. de documento de aprobación de la inversión	Nro. de resolución / decreto	Nro. de inscripción CPMV	Casa de valores en la que se negocia	Tipo de identificación del custodio	Identificación del Custodio de valores	Calificación de riesgo de la emisión	Calificadora de riesgo de la emisión 	Fecha ultima calificación de riesgos	Precio de mercado	Fecha  precio de mercado	No. Acciones/Unidades de participación	Valor de acción/Unidades de participación 	Fondos de inversión	Errores
RETRATOREC S.A.	Acciones	538	R	0992212640001  	07	20	RTT			31/03/2017					21343	0	74700,5	0	RV	RV	SN	SC.IMV.DJMV.DAYR.G.12.0001473	2012.2.02.01033				22	9	14/02/2012	0	31/12/2023	21343	0		


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
from bvq_backoffice.fondo fon
join bvq_backoffice.titulos_portafolio tpo on tpo.fon_id=fon.fon_id
join (values ('DOL-','20151224'),('RTT-','20170331'),('EYP-','20230331')) v(abr,fcompra)
on fon.fon_numeracion like abr+'%' and tpo_fecha_ingreso=fcompra
where fon_procedencia is null
and fon.fon_id in (175,205,538)--472 and tpo_acta='02-2022'


select pju_id,* from bvq_administracion.emisor where ems_nombre like '%energy%'
select * from bvq_administracion.persona_juridica where pju_id=459
where aru_opc_fchval='20151224'--val='20220512'
group by aru_opc_fchval with rollup
order by opc.aru_opc_fchval


create view _temp.g02 as
select * from _temp.g3sh
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
