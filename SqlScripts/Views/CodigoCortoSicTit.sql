create view bvq_administracion.CodigoCortoSicTit as
	with a as(
		select
		lastNum=case when charindex(	'.'	,reverse(replace(enc_numero_emision,'-','.')))>0 then
		right(
			replace(enc_numero_emision,'-','.')
			,charindex(	'.'	,reverse(replace(enc_numero_emision,'-','.')))-1
		)
		end
		,enc_numero_emision,enc_numero_corto_emision
		from bvq_administracion.emision_calificacion
	) select codigoCorto=case when isnumeric(lastNum)=1 then '02'+right('00000'+lastNum,5) else enc_numero_emision end,enc_numero_emision,enc_numero_corto_emision
	from a
