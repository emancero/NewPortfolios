if not exists(
	select * from INFORMATION_SCHEMA.columns c where
	column_name like 'TIV_CODIGO_ISIN'--='tiv_codigo_isin'
	and table_name='titulo_valor'
	and table_schema='bvq_administracion'
)
	alter table BVQ_ADMINISTRACION.TITULO_VALOR ADD TIV_CODIGO_ISIN varchar(20)

if not exists(
	select * from information_schema.columns c where
	column_name='TIV_FECHA_INSCRIPCION_SIC'
	and table_name='TITULO_VALOR'
	and table_schema='BVQ_ADMINISTRACION'
)
	alter table	BVQ_ADMINISTRACION.TITULO_VALOR add TIV_FECHA_INSCRIPCION_SIC datetime
	/*
select dbo.colstr('bvq_administracion.CAMPO_TABLA_CENTRALIZADA')
insert into bvq_administracion.CAMPO_TABLA_CENTRALIZADA
(CTC_ID,TCE_ID,CTC_NOMBRE,CTC_ESTADO,CTC_VERSION)
select (select max(ctc_id) from bvq_administracion.CAMPO_TABLA_CENTRALIZADA)+1, TCE_ID,CTC_NOMBRE='TIV_FECHA_INSCRIPCION_SIC',CTC_ESTADO,CTC_VERSION
from bvq_administracion.CAMPO_TABLA_CENTRALIZADA where ctc_id=170244--order by ctc_id desc--where tce_id=4
select * from bvq_administracion.CAMPO_TABLA_CENTRALIZADA order by ctc_id desc--where tce_id=4
*/
/*
;
update tiv set TIV_FECHA_ACTUALIZACION=getdate()
--,TIV_FECHA_INSCRIPCION_SIC=fec
from bvq_administracion.titulo_valor tiv join  (
VALUES
(1240, '20100326'),
(2133, '20120330'),
(2444, '20120820'),
(2521, '20130509')
) v(tiv,fec) on tiv.tiv_id=v.tiv
*/