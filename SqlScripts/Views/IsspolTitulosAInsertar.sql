CREATE view bvq_backoffice.IsspolTitulosAInsertar as
	select
	AI_ID_EMISOR=ins.idEmisor,
	AI_TIPO_RENTA=case when tiv_tipo_renta=153 then 1 else 2 end,
	AS_ID_PAPEL=ins.id_tipo_papel,--null,--t.tipopapel,
	AI_CLASE=ascii(upper(tiv_clase))-64,
	AI_MONEDA='D',
	AS_NOMBRE=ins.nombre,
	AS_CODIGO=ins.nombre,
	AI_UBICACION_GEO=280,
	AS_DESCRIPCION='',--nombre del tipo de papel
	AD_FECHA_INICIO=tfl_fecha_inicio,
	AD_FECHA_EMISION=tiv_fecha_emision,--nombre del tipo de papel
	AD_FECHA_VENC=tiv_fecha_vencimiento,--nombre del tipo de papel
	AI_PLAZO_VENCER=plazoVencer,--datediff(d,tiv_fecha_emision,tiv_fecha_vencimiento),
	AM_PORCENT_RENTAB=NULL,
	AB_TIENE_CUPON=0,
	AB_DESMATERIALIZADO=1,
	AN_TASA_VIGENCIA=tiv_tasa_interes,
	AM_VALOR_NOMINAL=valor_nominal,
	AM_VALOR_EFECTIVO=total_inversion,
	AM_PRECIO=0,
	AI_PERIODO_GRACIA=case when tiv_tipo_renta=153 then 0 else null end,
	AB_COMERCIAL=0,
	AB_ANUALIDAD=0,
	AB_CAPITAL=0,
	AB_TASA_VARIABLE=0,
	AB_LLENADO_MANUAL= case when tiv_tipo_valor in (9,20,3) then 1 else 0 end,
	AS_SERIE_DOCUMENTAL='',
	AS_FRECUENCIA_INT=NULL,
	AS_FRECUENCIA_CAP=case when tiv_tipo_valor in (9,20) then 'TR' when tiv_tipo_valor in (3) then 'SE' when tiv_tipo_renta=153 then 'VC' end,
	AS_ESTADO='Registrado',
	--AS_CREACION_USUARIO='mtorresa',
	AS_CREACION_EQUIPO=CREACION_EQUIPO,
	AM_COMISION=NULL,
	AM_COMISION_OPERADOR=0,
	AI_TITULO_PADRE=NULL,
	AB_ES_365=0,
	AB_MODIFICA_INTERES=0,
	AB_ES_NUEVO=1,
	AS_EMS_NOMBRE=EMS_NOMBRE,
	tiv_id
	--select top 1 tiv_tipo_valor,t.tipopapel
	from bvq_backoffice.IsspolAInsertar ins
	--left join
	--siisspolweb.siisspolweb.inversion.vis_titulo t on e.idemisor=t.idemisor
	--and t.fechaVencimiento=tst.tiv_fecha_vencimiento
	--where
	--t.idtitulo is not null
	--and
	--tiv_fecha_vencimiento>dateadd(m,1,getdate())