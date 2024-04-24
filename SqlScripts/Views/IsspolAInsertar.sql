CREATE view bvq_backoffice.IsspolAInsertar as
	select --t.fecha_vencimiento,fecha,total_inversion,fecha_vencimiento,*
	 NOMBRE=
		TPO_NUMERACION
	,TIV_ID
	,FECHA=htp_fecha_operacion
	,TOTAL_INVERSION=sum(round(precioCompra*htp_compra,2))
	,OBSERVACIONES='COMITÉ DE INVERSIONES'--TPO_OBJETO
	,CREACION_FECHA=getdate()
	,CREACION_USUARIO=null--'mtorresa'
	,CREACION_EQUIPO='192.168.2.225'
	,MODIFICA_FECHA=getdate()
	,MODIFICA_USUARIO=null--'mtorresa'
	,MODIFICA_EQUIPO='192.168.2.225'
	--,ID_TITULO=it.id_titulo
	,valor_inversion_titulo=sum(round(precioCompra*htp_compra,2))
	,comision=sum(comisionBolsa)
	,comision_operador=sum(comisionOperador)
	,estado_inversion=0
	--,r
	,tiv_tipo_valor
	,idEmisor
	,id_tipo_papel
	,id_seguro_tipo=dbo.stringagg(rtrim(id_seguro_tipo),',')
	,fondos=dbo.stringagg(rtrim(por_codigo),',')
	,pju_identificacion,tiv_fecha_vencimiento,tiv_clase,tiv_fecha_emision,tiv_tasa_interes,tiv_tipo_renta,tfl_fecha_inicio
	,ems_nombre
	,tvl_nombre
	,tipo_papel
	,interes_transcurrido=sum(itrans)
	,valor_nominal=sum(htp_compra)
	,plazoVencer
	--,it.identificacion
	from bvq_backoffice.IsspolSicav a
	/*left join intSis it
	on v.pju_identificacion=it.identificacion
	and (tvl_codigo='FI' and it.fecha=fecha_operacion or it.fecha_vencimiento=tiv_fecha_vencimiento)*/
	
	--where r<=2
	group by 
	EMS_CODIGO,htp_fecha_operacion,TPO_OBJETO
	--,id_titulo
	,tiv_tipo_valor,pju_identificacion,tiv_fecha_vencimiento
	,tiv_clase,tiv_fecha_emision,tiv_tasa_interes,tiv_tipo_renta,tfl_fecha_inicio,tpo_numeracion,tiv_id
	,idEmisor,id_tipo_papel,ems_nombre,tvl_nombre,tipo_papel,plazoVencer--,itrans
