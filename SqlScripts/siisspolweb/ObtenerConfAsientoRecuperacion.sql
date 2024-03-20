﻿CREATE PROCEDURE  [BVQ_BACKOFFICE].[ObtenerConfAsientoRecuperacion]
	--@AI_INVERSION INT,
	@AS_NOMBRE VARCHAR(200),
	@AD_FECHA_ORIGINAL DATETIME=null,
	@AD_FECHA  DATE,
	@AS_USARIO VARCHAR(100),                                                
	@AS_EQUIPO VARCHAR(100),
	@AS_MOV_CUENTA VARCHAR(MAX) OUT,
	@AS_MOV_TIPO VARCHAR(MAX) OUT,
	@AS_MOV_VALOR VARCHAR(MAX) OUT,
	@AS_MOV_REFERENCIA VARCHAR(MAX) OUT,
	@AS_MSJ  VARCHAR(500) OUTPUT
AS
begin
DECLARE @LS_FECHA_ACTUAL  DATETIME

	SELECT
		 @AS_MOV_CUENTA = COALESCE(@AS_MOV_CUENTA + ';', '') + convert(varchar(100), icr.[codigo_lista_rubro] ),
		 @AS_MOV_TIPO = COALESCE(@AS_MOV_TIPO + ';', '') + convert(varchar(100),icr.[tipo_rubro_movimiento] ),
		 @AS_MOV_VALOR = COALESCE(@AS_MOV_VALOR + ';', '') + convert(varchar(100),CAST(coalesce(debe, haber) AS money) ),
		 @AS_MOV_REFERENCIA= COALESCE(@AS_MOV_REFERENCIA + ';', '') +  convert(varchar(100),isnull(ref.referencia,'') ) 
	from bvq_backoffice.IsspolComprobanteRecuperacion icr
	left join bvq_backoffice.Liquidez_Referencias_table ref
	on icr.tpo_numeracion=ref.tpo_numeracion and icr.fecha=ref.fecha
		and icr.ri in ('DIDENT','DIDENT02')
		and round(debe,0)=round(ref.valor,0)
	where icr.tpo_numeracion=--'MDF-2013-04-25-2'
		@AS_NOMBRE
	and icr.fecha=--'20231201'
		@AD_FECHA
	and (
		@AD_FECHA_ORIGINAL is null
		OR icr.htp_fecha_operacion=@AD_FECHA_ORIGINAL
	)
	order by deterioro,rubroOrd,tipo desc,por_ord  


	--mensaje de error si no encuentra la cuenta ----------------------------------------
	SELECT @as_msj =
	       'No se ha configurado la cuenta contable para el seguro ' + isnull(icr.descripcion, '') + ',   con codigo: ' + isnull(LR.codigo, '')
	from bvq_backoffice.IsspolComprobanteRecuperacion icr
	LEFT JOIN [siisspolweb].siisspolweb.comun.vis_catalogo_tipo VCT ON VCT.grupoCodigo= 'CDF' AND VCT.valor = CAST( icr.id_cuenta AS varchar(10))
	INNER JOIN [siisspolweb].siisspolweb.contautom.lista_rubro LR
		ON LR.codigo=icr.CODIGO_LISTA_RUBRO
				--icr.codigo_configuracion
				--+ case when icr.codigo_configuracion='DIDENT' then '' else VCT.tipoCodigo end
	LEFT OUTER JOIN [siisspolweb].siisspolweb.contautom.lista_rubro_detalle D ON D.id_lista_rubro = LR.id_lista_rubro
	--WHERE r.id_inversion  = @AI_INVERSION AND r.fecha_recuperacion = @AD_FECHA
	where tpo_numeracion=--'MDF-2013-04-25-2'
		@AS_NOMBRE
	and icr.fecha=--'20231201'
		@AD_FECHA
	GROUP BY LR.codigo, D.id_cuenta_contable,  icr.descripcion
	HAVING D.id_cuenta_contable IS NULL

	IF @as_msj LIKE '%NXD'
	BEGIN
		SET @as_msj = @as_msj + ' (AL DEBE)'

	END
	
	IF @as_msj LIKE '%NXC'
	BEGIN 
		SET @as_msj = @as_msj + ' (AL HABER)'

	END 
	    
	IF (@as_msj IS NOT NULL )
	BEGIN
		exec bvq_administracion.IsspolFormatoMensajeValidacion @as_msj,3,@as_msj output
		RETURN -1
	END
	--fin mensaje de error si no encuentra la cuenta -------------------------------------

	RETURN 1
	
end
