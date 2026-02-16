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
if not exists(select 1 from bvq_administracion.EMISION_CALIFICACION where enc_numero_emision='2023.Q.02.003866' and enc_fecha_desde='20231031')
	insert into bvq_administracion.emision_calificacion(enc_id,enc_numero_emision,cal_id,enc_fecha_desde,enc_valor,enc_estado)
	values((select max(enc_id) from bvq_administracion.emision_calificacion)+1,'2023.Q.02.003866',10,'20231031','AAA',21)
