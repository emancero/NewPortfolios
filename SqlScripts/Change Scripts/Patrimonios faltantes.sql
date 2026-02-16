/*set quoted_identifier off
with a as(
	select distinct msg=formatmessage(char(9)+"('%s','%s','%s')",emisor,fecha,pat),lf=char(13)+char(10)
	from patraw where emisor not in ('0','')
), b as(
	select vals=dbo.stringagg(msg,','+lf),lf=max(lf)
	from a
) select 'insert into _temp.pat(emisor,fehca,pat)'+lf+'(values '+lf+vals+lf+') v(emisor,fecha,pat)'
from b*/
--go
if object_id('_temp.pat') is null
	create table _temp.pat(id int,emisor varchar(300),fecha varchar(100),pat varchar(100))

if object_id('_temp.bakVba20260211') is null
	create table _temp.bakVba20260211(ems_id int, VBA_FECHA_DESDE datetime)


insert into _temp.pat(emisor,fecha,pat)
values 
	('ALMACENES BOYACA S.A.','20. oct. 2023','$22.860.610,00 '),
	('ALMACENES BOYACA S.A.','29. jun. 2023','$22.860.610,00 '),
	('ARTES GRAFICAS SENEFELDER C.A.','20. oct. 2023','$11.698.660,00 '),
	('ASISERVY S.A.','20. oct. 2023','$26.872.700,00 '),
	('ASISERVY S.A.','6. mar. 2023','$26.872.700,00 '),
	('AUDIOVISION ELECTRONICA AUDIOELEC S.A.','10. nov. 2022','$15.560.714,00 '),
	('AUDIOVISION ELECTRONICA AUDIOELEC S.A.','28. nov. 2023','18.000.000,00'),
	('AUTOFENIX S.A.','25. oct. 2023','$3.235.160,00 '),
	('Banco Amazonas S.A.','6. mar. 2023','$26.287.098,00 '),
	('Banco Bolivariano C.A','26. jun. 2023','$513.335.955,00 '),
	('Banco Bolivariano C.A','28. sept. 2023','$513.335.955,00 '),
	('Banco Bolivariano C.A','31. mar. 2023','$513.335.955,00 '),
	('Banco de Guayaquil S.A.','8. nov. 2023','$856.791.850,00 '),
	('Banco de Machala S.A.','1. jun. 2023','$92.389.780,00 '),
	('Banco de Machala S.A.','28. sept. 2023','$92.389.780,00 '),
	('Banco de Machala S.A.','29. sept. 2022','$96.411.493,00 '),
	('Banco de Machala S.A.','31. mar. 2023','$92.389.780,00 '),
	('Banco de Machala S.A.','6. mar. 2023','$96.411.493,00 '),
	('Banco de Machala S.A.','8. nov. 2023','$99.717.602,00 '),
	('Banco del Pacifico S.A.','1. jun. 2023','$966.166.506,00 '),
	('Banco del Pacifico S.A.','26. jun. 2023','$966.166.506,00 '),
	('Banco del Pacifico S.A.','28. sept. 2023','$966.166.506,00 '),
	('Banco del Pacifico S.A.','6. mar. 2023','$966.166.506,00 '),
	('Banco del Pacifico S.A.','8. nov. 2023','$964.107.644,00 '),
	('Banco Diners Club del Ecuador S.A.','31. mar. 2023','$580.637.152,00 '),
	('Banco General Rumiñahui S.A.','6. mar. 2023','$121.732.436,00 '),
	('Banco Pichincha C.A.','1. jun. 2023','$1.933.751.902,00 '),
	('Banco Pichincha C.A.','26. jun. 2023','$1.933.751.902,00 '),
	('Banco Pichincha C.A.','28. sept. 2023','$1.933.751.902,00 '),
	('Banco Pichincha C.A.','31. mar. 2023','$1.933.751.902,00 '),
	('Banco Pichincha C.A.','6. mar. 2023','$1.933.751.902,00 '),
	('Banco Pichincha C.A.','8. nov. 2023','$1.294.353.123,00 '),
	('CAC Atuntaqui Limitada','6. mar. 2023','$45.121.786,00 '),
	('CAC Cooprogreso Limitada','6. mar. 2023','$100.588.933,00 '),
	('CAC de la Pequeña Empresa de Cotopaxi Limitada','31. mar. 2023','$104.680.000,00 '),
	('CAC Oscus Limitada','6. mar. 2023','$86.578.692,10 '),
	('CAC Tulcan Limitada','6. mar. 2023','$44.970.066,42 '),
	('CARTIMEX S.A.','19. abr. 2023','$18.908.270,00 '),
	('CARTIMEX S.A.','27. dic. 2022','$18.908.274,32 '),
	('CARTIMEX S.A.','28. nov. 2023','2.000.000,00'),
	('COMPAÑIA PETROLEOS DE LOS RIOS PETROLRIOS C.A.','17. may. 2019','7.473.286,69'),
	('CONSTRUIR FUTURO S.A. CONFUTURO','25. oct. 2023','$2.644.270,00 '),
	('CONTINENTAL TIRE ANDINA S.A.','28. nov. 2023','$30.000.000,00 '),
	('CORPETROLSA S.A.','26. jun. 2023','$13.498.260,00 '),
	('CORPETROLSA S.A.','31. mar. 2023','$14.892.000,00 '),
	('CORPORACION ECUATORIANA DE ALIMENTOS Y BEBIDAS CORPABE S.A.','28. sept. 2023','$2.221.460,00 '),
	('CORPORACION ECUATORIANA DE ALUMINIO S.A. CEDAL','27. dic. 2022','$37.610.245,00 '),
	('CORPORACION ECUATORIANA DE ALUMINIO S.A. CEDAL','28. sept. 2023','$41.999.000,00 '),
	('CORPORACION EL ROSADO S.A.','26. jun. 2023','$320.981.160,00 '),
	('CORPORACIÓN FERNANDEZ CORPFERNANDEZ S.A.','20. oct. 2023','$34.984.370,00 '),
	('DANIELCOM EQUIPMENT SUPPLY S.A.','1. abr. 2019','5.112.259,00'),
	('DANIELCOM EQUIPMENT SUPPLY S.A.','19. abr. 2023','$4.217.710,00 '),
	('DISTRIBUIDORA COMERCIAL DEL NORTE TRICOMNOR S.A.','25. oct. 2023','$4.554.610,00 '),
	('DREAMPACK ECUADOR S.A.','9. may. 2023','$6.897.200,00 '),
	('DREAMPACK ECUADOR S.A.','9. may. 2023','6.897.200,00'),
	('EDESA S.A.','26. feb. 2019','$36.458.540,00 '),
	('EDESA S.A.','4. dic. 2019','$36.759.213,00 '),
	('EXPOTUNA S.A.','28. nov. 2023','5.000.000,00'),
	('EXTRACTORA AGRÍCOLA RÍO MANSO EXA S.A.','10. nov. 2022','$13.957.442,79 '),
	('FABRICA DE DILUYENTES Y ADHESIVOS DISTHER C. LTDA.','28. sept. 2023','$5.430.260,00 '),
	('FERRO TORRE S.A.','9. may. 2023','29.063.560,00'),
	('FIDEICOMISO NOVENA TITULARIZACION CARTERA AUTOMOTRIZ AMAZONAS','2. jun. 2023','$26.287.098,00 '),
	('FIDEICOMISO NOVENA TITULARIZACION CARTERA AUTOMOTRIZ AMAZONAS','2. jun. 2023','26.287.098,00'),
	('FIDEICOMISO NOVENA TITULARIZACION CARTERA AUTOMOTRIZ AMAZONAS','26. abr. 2023','$26.287.098,00 '),
	('FIDEICOMISO TITULARIZACIÓN PROYECTO NUEVO TRANSPORTE GUAYAQUIL','19. jun. 2023','161.386.360,00'),
	('GALPACIFICO TURS S.A.','1. abr. 2019','3.002.931,00'),
	('INTEROC S.A.','10. nov. 2022','$35.369.092,00 '),
	('LA FABRIL S.A.','10. nov. 2022','$144.935.564,00 '),
	('LA FABRIL S.A.','28. sept. 2023','$117.795.640,00 '),
	('NEGOCIOS AUTOMOTRICES NEOHYUNDAI S.A.','9. may. 2023','$58.444.100,00 '),
	('NOVACREDIT S.A.','11. jul. 2023','$4.402.680,00 '),
	('NOVACREDIT S.A.','26. jun. 2023','$4.402.680,00 '),
	('PHARMABRAND S.A.','28. nov. 2023','$2.135.660,00 '),
	('PLASTICOS DEL LITORAL PLASTLIT S.A.','8. nov. 2023','9.000.000,00'),
	('PLASTICSACKS CIA. LTDA.','16. ago. 2019','$7.810.996,00 '),
	('PROCESADORA NACIONAL DE ALIMENTOS C.A. PRONACA ','8. nov. 2023','$445.514.274,48 '),
	('PRODUCTORA CARTONERA S.A.','31. mar. 2023','$58.975.180,00 '),
	('REPUBLICA DEL PLATANO EXPORTPLANTAIN S.A.','29. sept. 2022','$2.469.702,80 '),
	('RIPCONCIV CONSTRUCCIONES CIVILES CIA. LTDA.','17. may. 2019','25.204.718,50'),
	('RIPCONCIV CONSTRUCCIONES CIVILES CIA. LTDA.','28. nov. 2023','5.000.000,00'),
	('RIZZOKNIT CIA. LTDA.','28. nov. 2023','$2.000.000,00 '),
	('SALCEDO MOTORS S.A. SALMOTORSA','19. abr. 2023','$6.227.170,00 '),
	('STARCARGO CIA. LTDA.','1. jun. 2023','$2.857.180,00 '),
	('SUPERDEPORTE S.A.','19. abr. 2023','$58.737.980,00 '),
	('SUPERDEPORTE S.A.','28. jun. 2023','$60.743.340,00 '),
	('SUPERDEPORTE S.A.','6. mar. 2023','$49.900.534,90 '),
	('SURGALARE S.A.','31. mar. 2023','$4.916.610,00 '),
	('SURPAPELCORP S.A.','25. oct. 2023','$39.500.510,00 '),
	('TIENDAS INDUSTRIALES ASOCIADAS TIA S.A.','20. oct. 2023','$74.316.760,00 '),
	('TITULARIZACIÓN DE CARTERA INMOBILIARIA VOLANN','17. mar. 2011','$2.161.501,21 ')


delete from corteslist
insert into corteslist(c,cortenum)
values('20231231',1)

if object_id('tempdb..#map') is not null
	drop table #map
;with a as(
	select * from(
VALUES
('ALMACENES BOYACA S.A.' , 'ALMACENES BOYACÁ S.A.')
,('ARTES GRAFICAS SENEFELDER C.A.' , 'ARTES GRÁFICAS SENEFELDER C.A.')
,('ASISERVY S.A.' , 'ASISERVY S.A.')
,('AUDIOVISION ELECTRONICA AUDIOELEC S.A.' , 'AUDIOVISIÓN ELECTRONICA AUDIOELEC S.A.')
,('AUTOFENIX S.A.' , 'AUTOFENIX S.A.')
,('Banco Amazonas S.A.' , 'BANCO AMAZONAS S.A.')
,('Banco Bolivariano C.A' , 'BANCO BOLIVARIANO C.A.')
,('Banco de Guayaquil S.A.' , 'BANCO GUAYAQUIL S.A.')
,('Banco de Machala S.A.' , 'BANCO DE MACHALA S.A.')
,('Banco del Pacifico S.A.' , 'BANCO DEL PACÍFICO S.A.')
,('Banco Diners Club del Ecuador S.A.' , 'BANCO DINERS CLUB DEL ECUADOR SOCIEDAD ANÓNIMA')
,('Banco General Rumiñahui S.A.' , 'BANCO GENERAL RUMIÑAHUI S.A.')
,('Banco Pichincha C.A.' , 'BANCO PICHINCHA C.A.')
,('CAC Atuntaqui Limitada' , 'CAC ATUNTAQUI')
,('CAC Cooprogreso Limitada' , 'CAC COOPROGRESO LTDA.')
,('CAC de la Pequeña Empresa de Cotopaxi Limitada' , 'CAC DE LA PEQUEÑA EMPRESA DE COTOPAXI CACPECO LTDA.')
,('CAC Oscus Limitada' , 'CAC "OSCUS" LTDA.')
,('CAC Tulcan Limitada' , 'CAC TULCÁN LTDA.')
,('CARTIMEX S.A.' , 'CARTIMEX S.A.')
,('COMPAÑIA PETROLEOS DE LOS RIOS PETROLRIOS C.A.' , 'PETRÓLEOS DE LOS RÍOS PETROLRIOS C.A.')
,('CONSTRUIR FUTURO S.A. CONFUTURO' , 'CONSTRUIR FUTURO S.A. CONFUTURO')
,('CONTINENTAL TIRE ANDINA S.A.' , 'CONTINENTAL TIRE ANDINA S.A.')
,('CORPETROLSA S.A.' , 'CORPETROLSA S.A.')
,('CORPORACION ECUATORIANA DE ALIMENTOS Y BEBIDAS CORPABE S.A.' , 'CORPORACION ECUATORIANA DE ALIMENTOS Y BEBIDAS CORPABE S.A.')
,('CORPORACION ECUATORIANA DE ALUMINIO S.A. CEDAL' , 'CORPORACIÓN ECUATORIANA DE ALUMINIO S.A. CEDAL')
,('CORPORACION EL ROSADO S.A.' , 'CORPORACIÓN EL ROSADO S.A.')
,('CORPORACIÓN FERNANDEZ CORPFERNANDEZ S.A.' , 'CORPORACIÓN FERNÁNDEZ CORPFERNANDEZ S.A.')
,('DANIELCOM EQUIPMENT SUPPLY S.A.' , 'DANIELCOM EQUIPMENT SUPPLY S.A.')
,('DISTRIBUIDORA COMERCIAL DEL NORTE TRICOMNOR S.A.' , 'DISTRIBUIDORA COMERCIAL DEL NORTE TRICOMNOR S.A.')
,('DREAMPACK ECUADOR S.A.' , 'DREAMPACK ECUADOR S.A.')
,('EDESA S.A.' , 'EDESA S.A.')
,('EXPOTUNA S.A.' , 'EXPOTUNA S.A.')
,('EXTRACTORA AGRÍCOLA RÍO MANSO EXA S.A.' , 'EXTRACTORA AGRÍCOLA RÍO MANSO EXA S.A.')
,('FABRICA DE DILUYENTES Y ADHESIVOS DISTHER C. LTDA.' , 'FABRICA DE DILUYENTES Y ADHESIVOS DISTHER C. LTDA. DISTHER')
,('FERRO TORRE S.A.' , 'FERRO TORRE S.A.')
,('FIDEICOMISO NOVENA TITULARIZACION CARTERA AUTOMOTRIZ AMAZONAS' , 'FIDEICOMISO NOVENA TITULARIZACION CARTERA AUTOMOTRIZ AMAZONAS')
,('FIDEICOMISO TITULARIZACIÓN PROYECTO NUEVO TRANSPORTE GUAYAQUIL' , 'FIDEICOMISO TITULARIZACION PROYECTO NUEVO TRANSPORTE GUAYAQUIL')
,('GALPACIFICO TURS S.A.' , 'GALPACIFICO TOURS S.A.')
,('INTEROC S.A.' , 'INTEROC S.A.')
,('LA FABRIL S.A.' , 'LA FABRIL S.A')
,('NEGOCIOS AUTOMOTRICES NEOHYUNDAI S.A.' , 'NEGOCIOS AUTOMOTRICES NEOHYUNDAI S.A.')
,('NOVACREDIT S.A.' , 'NOVACREDIT S.A.')
,('PHARMABRAND S.A.' , 'PHARMABRAND S.A.')
,('PLASTICOS DEL LITORAL PLASTLIT S.A.' , 'PLÁSTICOS DEL LITORAL S.A. PLASTLIT')
,('PLASTICSACKS CIA. LTDA.' , 'PLASTICSACKS CIA. LTDA.')
,('PROCESADORA NACIONAL DE ALIMENTOS C.A. PRONACA' , 'PROCESADORA NACIONAL DE ALIMENTOS C.A. PRONACA')
,('PRODUCTORA CARTONERA S.A.' , 'PRODUCTORA CARTONERA S.A.')
,('REPUBLICA DEL PLATANO EXPORTPLANTAIN S.A.' , 'PLANTAIN REPUBLIC / REPUBLICA DEL PLATANO EXPORTPLANTAIN S.A.')
,('RIPCONCIV CONSTRUCCIONES CIVILES CIA. LTDA.' , 'RIPCONCIV CONSTRUCCIONES CIVILES CÍA. LTDA.')
,('RIZZOKNIT CIA. LTDA.' , 'RIZZOKNIT CÍA. LTDA.')
,('SALCEDO MOTORS S.A. SALMOTORSA' , 'SALCEDO MOTORS S.A. SALMOTORSA')
,('STARCARGO CIA. LTDA.' , 'STARCARGO CÍA. LTDA.')
,('SUPERDEPORTE S.A.' , 'SUPERDEPORTE S.A.')
,('SURGALARE S.A.' , 'SURGALARE S.A.')
,('SURPAPELCORP S.A.' , 'SURPAPELCORP S.A.')
,('TIENDAS INDUSTRIALES ASOCIADAS TIA S.A.' , 'COMPAÑÍA TIENDAS INDUSTRIALES ASOCIADAS TIA S.A.')
,('TITULARIZACIÓN DE CARTERA INMOBILIARIA VOLANN' , 'FIDEICOMISO MERCANTIL DE TITULARIZACIÓN DE CARTERA INMOBILIARIA VOLANN')
) s(a,sicav)
) select v.decreto_emisor,v.id_emisor,a.a,a.sicav,emisor into #map from 
(select distinct decreto_emisor,ID_EMISOR from bvq_backoffice.isspolrentafijaview v) v
join a on decreto_emisor=sicav collate modern_spanish_ci_ai
left join (select distinct emisor from _temp.pat) p on p.emisor=a.a





--select * from #map where emisor is null
if object_id('tempdb..#miss') is not null
	drop table #miss
select distinct
i.ems_nombre,
ems.ems_id,
c,
VBA_FECHA_DESDE=isnull((
	select top 1 VBA_FECHA_DESDE
	from bvq_administracion.VARIABLES_BALANCE vba where vba.ems_id=ems.ems_id
	and vba_fecha_desde>c
	order by vba_fecha_desde asc
),'99991231')
into #miss
from bvq_backoffice.isspolrentafijaviewnew i
left join bvq_administracion.emisor ems on ems.ems_codigo=i.ems_abr
cross join corteslist c
where patrimonio is null --and ems.ems_codigo is null
and ems.ems_id not in (132)



set dateformat dmy
set language 'spanish'

if object_id('tempdb..#src') is not null
	drop table #src
;with p as(
	select emisor,pat=replace(pat,'$',''),min(fecha2) mnFecha --porque es la fecha más antigua donde aparece esa combinación emisor patrimonio--, max(fecha) mxFecha
	, row_number() over (partition by emisor order by min(fecha2) desc) r --desc porque es la calificación más reciente del emisor
	, count(*) over (partition by emisor order by min(fecha2) desc) c
	from (
		select fecha2=try_cast(replace(replace(fecha,'.',''),'sept','sep') as datetime),* from _temp.pat
	) pat where emisor not in ('','0')
	group by emisor,replace(pat,'$','')
) select emisor,pat=replace(replace(pat,'.',''),',','.'),mnfecha
--c2=count(*) over (partition by emisor)--replace(replace(pat,'$',''),'.',''),
into #src from p
where r=1


insert into BVQ_ADMINISTRACION.VARIABLES_BALANCE(
	ems_id,VBA_FECHA_DESDE,VBA_FECHA_HASTA,VBA_PATRIMONIO_TECNICO
)
output inserted.ems_id,inserted.VBA_FECHA_DESDE
into _temp.bakVba20260211
select id_emisor,mnfecha,hasta=vba_fecha_desde,try_cast(src.pat as float)
from #src src join #map map on src.emisor=map.emisor
join #miss miss on miss.EMS_ID=map.id_emisor

