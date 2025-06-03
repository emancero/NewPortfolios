create procedure BVQ_BACKOFFICE.ActualizarFechaControlEnvioIsspol
--declare
 @i_fecha datetime='20240614'
,@i_fecha_original datetime='20240612'
,@i_tpo_id int=1
as
begin
	--select tpo_id,datediff(dd,isr_fecha,@i_fecha),*
	update isr set isr_fecha=@i_fecha
	from bvq_backoffice.ISSPOL_RECUPERACION isr
	join bvq_backoffice.titulos_portafolio tpo on isr.isr_numeracion=tpo.tpo_numeracion
	where
	tpo.tpo_id=@i_tpo_id
	and convert(varchar,isr.isr_fecha,20)=convert(varchar,@i_fecha_original,20)
end
