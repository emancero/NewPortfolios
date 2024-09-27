create procedure BVQ_BACKOFFICE.ObtenerReferenciasDeposito
	@i_id_masivas_transaccion int, @i_lga_id int=null
as
begin
	select refValor=sum(lre.valor)
	,valorDeposito=max(mt.valor)
	,referencia=max(lre.referencia)
	,titulos=dbo.stringagg(
		lre.tpo_numeracion+':'+format(lre.valor,'c2','es-EC')
		,', ')
	--select lre.*,*
	from BVQ_BACKOFFICE.Liquidez_Referencias_table lre
	join siisspolweb.siisspolweb.banco.masivas_transaccion mt on mt.id_masivas_transaccion=lre.idMasivasTransaccion
	WHERE
	--tpo_numeracion=@i_tpo_numeracion AND tiv_id=@i_tiv_id AND datediff(hh,lre.fecha,@i_fecha)=0
	--and
	lre.idMasivasTransaccion=@i_id_masivas_transaccion
	and lre_estado=1
	and 1=1
	group by lre.idMasivasTransaccion
	--having sum(lre.valor)>max(mt.valor)
end
