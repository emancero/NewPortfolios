create procedure BVQ_BACKOFFICE.InsertarPrecioEfectivo
	  @i_tiv_id int
	, @i_por_id int
	, @i_precio float
	, @i_fecha_inicio datetime
	, @i_lga_id int = null
as
begin

	insert into bvq_backoffice.precio_efectivo(TIV_ID, POR_ID, PRE_VALOR, PRE_FECHA_INICIO, PRE_FECHA_FIN)
	select distinct
	  @i_tiv_id
	, tpo.POR_ID
	, @i_precio
	, @i_fecha_inicio
	,(
		select isnull(max(PRE_FECHA_FIN),'99991231')
		FROM BVQ_BACKOFFICE.PRECIO_EFECTIVO where PRE_FECHA_INICIO>@i_fecha_inicio and @i_fecha_inicio<PRE_FECHA_FIN
		and tiv_id=tpo.tiv_id and por_id=tpo.por_id
	)
	from bvq_backoffice.titulos_portafolio tpo where tiv_id=@i_tiv_id
	and (tpo.POR_ID=@i_por_id or @i_por_id is null)

	 EXEC	[BVQ_SEGURIDAD].[RegistrarAuditoria]
		@i_lga_id = @i_lga_id,
		@i_tabla = N'PRECIO_EFECTIVO',
		@i_esquema = N'BVQ_BACKOFFICE',
		@i_operacion = N'I',
		@i_subTipo = N'N',
		@i_columIdName = N'TIV_ID',
		@i_idAfectado = @i_tiv_id--1--@o_vectorId;
	--update pr set PRE_FECHA_FIN=@i_fecha_inicio
	;with a as(
		select rank() over (partition by pr.tiv_id,pr.por_id order by PRE_FECHA_FIN desc) r,pre_id,PRE_FECHA_FIN
		FROM BVQ_BACKOFFICE.PRECIO_EFECTIVO pr
		join bvq_backoffice.titulos_portafolio tpo on tpo.tiv_id=pr.tiv_id and tpo.por_id=pr.por_id
		where PRE_FECHA_INICIO<@i_fecha_inicio-- and @i_fecha_inicio<PRE_FECHA_FIN
		and pr.tiv_id=@i_tiv_id and (pr.POR_ID=@i_por_id or @i_por_id is null)
	)
	update a set PRE_FECHA_FIN=@i_fecha_inicio
	from a where r=1
end
