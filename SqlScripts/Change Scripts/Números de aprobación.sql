select tpo.tpo_id,fon.fon_id,i.id_inversion,id_int_inversion,ii=ii.nombre,i_nombre=i.nombre,fon.fon_numeracion,htp.htp_id
--update fon set fon_id_int_inversion=207,fon_numeracion='FPM-2025-11-07-2'
--update tpo set tpo_numeracion='FPM-2025-11-07-2'
--update htp set tpo_numeracion='FPM-2025-11-07-2'
--select htp_numeracion,*
from
siisspolweb.siisspolweb.inversion.inversion i
right join siisspolweb.siisspolweb.inversion.int_inversion ii
	left join bvq_backoffice.fondo fon on fon.FON_NUMERACION=ii.nombre--ID_INT_INVERSION=ii.id_int_inversion
	left join bvq_backoffice.titulos_portafolio tpo on tpo.fon_id=fon.fon_id
	left join bvq_backoffice.historico_titulos_portafolio htp on htp.htp_tpo_id=tpo.tpo_id
on ii.id_inversion=i.id_inversion
where 1=1--i.id_inversion is null and htp.htp_id is not null
and fon.fon_id_int_inversion is null


use sicavtestbatch

select tpo_numeracion,* 
from bvq_backoffice.fondo fon
join (
	select distinct tpo.fon_id,ipr_es_cxc,tpo_numeracion from bvq_backoffice.titulos_portafolio tpo
	left join bvq_backoffice.isspol_progs ipr on tpo.TPO_PROG=IPR_NOMBRE_PROG
) tpo
on tpo.fon_id=fon.fon_id
join siisspolweb.siisspolweb.inversion.inversion i on i.nombre=fon.fon_numeracion
where isnull(ipr_es_cxc,0)=0
and fon_numero_resolucion is null

sp_helptext '[BVQ_BACKOFFICE].[IsspolComprobanteRecuperacion]'


select tpo_prog,* from bvq_backoffice.fondo fon
join bvq_backoffice.titulos_portafolio tpo on tpo.fon_id=fon.fon_id

select * from bvq_backoffice.fondo where FON_ID_INT_INVERSION in (207,206)
select tpo_numeracion,fon_id,* from bvq_backoffice.titulos_portafolio tpo
where fon_id in (1008,1009)

select htp_numeracion,*

update htp set htp_numeracion='FPM-2025-11-07-2'
from bvq_backoffice.HISTORICO_TITULOS_PORTAFOLIO htp where htp_tpo_id=2427
--select htp_numeracion,* 
update tpo set tpo_numeracion='FPM-2025-11-07-2',fon_id=1009
--select tpo_numeracion,* 
from bvq_backoffice.TITULOS_PORTAFOLIO tpo where tpo_id=2427
--select tpo_numeracion,* 
update tpo set tpo_numeracion='FPM-2025-11-07',fon_id=1008
from bvq_backoffice.TITULOS_PORTAFOLIO tpo where tpo_id=2428

update isr set isr_numeracion='FPM-2025-11-07-2' from bvq_backoffice.ISSPOL_RECUPERACION isr where isr_numeracion like 'fpm%'



--select * from siisspolweb.siisspolweb.inversion.inversion where nombre like 'fpm%'