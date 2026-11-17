create function bvq_backoffice.tfObtenerRetencionPorFecha(@i_fecha datetime)
returns table as return
	SELECT CRL_VALOR
	FROM [BVQ_BACKOFFICE].[CONFIGURACION_RETENCION_LIQ]
	where [CRL_ESTADO]='A'
    and CRL_CODIGO='RET'
    and CRL_FECHA_INICIO<=@i_fecha and (CRL_FECHA_FIN>=@i_fecha OR CRL_FECHA_FIN IS NULL)
;
