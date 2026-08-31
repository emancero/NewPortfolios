CREATE VIEW [BVQ_BACKOFFICE].[DetallePortafolioBursatil] AS
SELECT
    v.htp_id,v.compra_htp_id,
	sector =
    CASE itcsector.itc_valor
        WHEN 'Público - No Financiero'  THEN 'Público'
        WHEN 'Privado - No Financiero'  THEN 'Privado no Financ.'
        WHEN 'Privado - Financiero'     THEN 'Privado Financiero'
        ELSE itcsector.itc_valor
    END,
    v.htp_fecha_operacion,
    v.tiv_tipo_renta,
    v.tvl_nombre,
	tvl_nombre_detallado=tvl_nombre + case when tvl_codigo='PCO' then iif(tasa_cupon>0,' (con cupón)',' (cero cupón)') end,
    v.ems_nombre,
    v.montooper,
    tpo.tpo_precio_ingreso,
    v.valefeoper,
    v.htp_comision_bolsa,
    v.tasa_cupon,
    condicion = COALESCE(
        NULLIF(LTRIM(RTRIM(fnd.FON_CONDICIONES)), ''),
        NULLIF(LTRIM(RTRIM(
            CASE 
                WHEN p.textoCondicion IS NOT NULL 
                    THEN 'Cupones ' + p.textoCondicion + ' de interés y capital'
                ELSE p.nombre
            END
        )), '')
    ),
	interes_a_recibir=(select sum(iamortizacion) from bvq_backoffice.compraventaflujo c where c.htp_id=v.htp_id),
    recursos=v.tpo_recursos,
	dbo.fnDias(v.fecha_compra, v.tiv_fecha_vencimiento, tiv.tiv_tipo_base) 
        AS plazo_dias,
    v.tiv_fecha_vencimiento,
    CASE 
        WHEN v.montoOper > 0 THEN 'Compra' 
        ELSE 'Venta' 
    END AS tipo_operacion,
    'Bursátil' AS tipo_mercado

--select top 200 itcsector.*
FROM bvq_backoffice.ObtenerDetallePortafolioConLiquidezView v
INNER JOIN bvq_backoffice.titulos_portafolio tpo
    ON tpo.tpo_id = v.htp_tpo_id
join bvq_administracion.titulo_valor tiv on tiv.tiv_id=v.tiv_id
left join bvq_administracion.periodicidadSB p on (
	tiv.tiv_tipo_base=354 and p.frec=tiv.tiv_frecuencia
	or tiv.tiv_tipo_base=355 and p.codigo='VC'
	or tiv.tiv_tipo_renta=154 and p.codigo='RV'
)
left join bvq_backoffice.FONDO fnd on fnd.FON_ID = tpo.FON_ID
join bvq_administracion.emisor ems on tiv.tiv_emisor=ems.ems_id
join bvq_administracion.item_catalogo itcsector on ems.ems_sector=itcsector.itc_id
WHERE ISNULL(IPR_ES_CXC,0)=0 
--and tvl_nombre not like 'bonos del estado'
and v.oper = 0 
and v.compra_htp_id=v.htp_id
--and datediff(m,htp_fecha_operacion,'20240801')=0
