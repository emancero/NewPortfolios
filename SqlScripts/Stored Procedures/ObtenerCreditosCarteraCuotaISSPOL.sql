CREATE PROCEDURE [BVQ_BACKOFFICE].[ObtenerCreditosCarteraCuotaISSPOL]
    @i_fechaCorte DATE,
    @i_portafolio NVARCHAR(200) = NULL,
    @i_anio INT = NULL,
    @i_mes INT = NULL,
    @i_dia INT = NULL,
    @i_segmento VARCHAR(200) = NULL,
    @i_producto VARCHAR(200) = NULL,
    @i_tasa FLOAT = NULL,
    @i_id_rubro VARCHAR(200) = NULL,
    @i_estado CHAR(10) = NULL,
    @i_lga_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        ccc.id_credito,
        por_codigo=fon.por_codigo,--descripcion,
        ccc.fecha_vencimiento,
        ccc.producto,
        ccc.segmento,
        cupon=sum(round(ccc.total,2)-round(ccc.abono,2))+sum(case when datediff(d,@i_fechaCorte,ccc.fecha_pago)>=1 then ccc.abono else 0 end)
    FROM [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA_FULL] ccc
	join bvq_backoffice.creditos_cartera cr on ccc.id_credito=cr.crc_numero_operacion and crc_fecha_cierre=@i_fechaCorte-- and DATEDIFF(M, @i_fecha_corte, CRC_FECHA_CIERRE) = 0
		join 
		bvq_backoffice.[FONDO_HOMOLOGACION] fon on fon.id_cuenta=cr.crc_id_cuenta-- on ltrim(rtrim(ccc.por_codigo))=ltrim(rtrim(fon.fon_descripcion_credito))
    WHERE
        ccc.total > 0.05
        AND DATEDIFF(d, @i_fechaCorte, ccc.fecha_vencimiento) >= 1
        AND (@i_portafolio IS NULL OR fon.por_codigo = @i_portafolio)
        AND (@i_anio IS NULL OR YEAR(ccc.fecha_vencimiento) = @i_anio)
        AND (@i_mes IS NULL OR MONTH(ccc.fecha_vencimiento) = @i_mes)
        AND (@i_dia IS NULL OR DAY(ccc.fecha_vencimiento) = @i_dia)
        AND (@i_segmento IS NULL OR ccc.segmento = @i_segmento)
        AND (@i_producto IS NULL OR ccc.producto = @i_producto)
        AND (@i_tasa IS NULL OR ccc.tasa = @i_tasa)
        AND (@i_id_rubro IS NULL OR ccc.id_rubro = @i_id_rubro)
        AND (@i_estado IS NULL OR ccc.estado = @i_estado)
    GROUP BY
        ccc.id_credito,
        fon.por_codigo,--descripcion,
        CONVERT(DATE, ccc.fecha_vencimiento),
        ccc.producto,
        ccc.segmento
END