if not exists(
	select * from INFORMATION_SCHEMA.columns where column_name='FON_ACCIONES_REALIZADAS'
)
	alter table BVQ_BACKOFFICE.FONDO ADD FON_ACCIONES_REALIZADAS varchar(max)
go

if not exists(
	select fon.fon_id
	from bvq_backoffice.portafoliocorte pc
	join bvq_backoffice.titulos_portafolio tpo on pc.httpo_id=tpo.tpo_id
	join bvq_backoffice.fondo fon on fon.fon_id=tpo.fon_id
	where ipr_es_cxc=1-- and ems_nombre like '%tesla%'
	group by fon.fon_id--and fecha_compra='20230131'
	having count(distinct pc.tpo_objeto)>1
)
BEGIN
	with a as(
		select fon.fon_id,pc.tpo_objeto
		from bvq_backoffice.portafoliocorte pc
		join bvq_backoffice.titulos_portafolio tpo on pc.httpo_id=tpo.tpo_id
		join bvq_backoffice.fondo fon on fon.fon_id=tpo.fon_id
		where ipr_es_cxc=1-- and ems_nombre like '%tesla%'
		group by fon.fon_id,pc.tpo_objeto--and fecha_compra='20230131'
	)
	update fon set FON_ACCIONES_REALIZADAS=TPO_OBJETO
	from a join bvq_backoffice.fondo fon on fon.fon_id=a.fon_id
	--having count(distinct tpo.tpo_objeto)>1
END
else
	raiserror ('tpo_objeto no es único para un fondo',16,1)

--order by tpo.fon_id
--select * from sys.procedures where name like 'obtener%ydetallep%'
--sp_helptext 'bvq_backoffice.ObtenerTodosSaldoYDetallePortafolio'