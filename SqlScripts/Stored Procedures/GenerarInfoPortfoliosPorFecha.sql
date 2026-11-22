create procedure bvq_backoffice.GenerarInfoPortfoliosPorFecha
--declare
    @i_start datetime = '2026-05-01T23:59:59', @i_end datetime = '2026-05-31T23:59:59'
as
begin
    truncate table _temp.ObtenerInfoPortfoliosPorFecha
    declare @v_cierre datetime = @i_start
    while @v_cierre<=@i_end
    begin
        print  @v_cierre
        INSERT INTO _temp.ObtenerInfoPortfoliosPorFecha
        (
            comitente, ems_nombre, tvl_descripcion, renta, tta_nombre,
            por_tipo_nombre, por_codigo, tiv_precio, por_id, tiv_id,
            tiv_tasa_interes, tiv_fecha_emision, tiv_fecha_vencimiento, htp_numeracion, tfcorte,
            fecha_compra, htp_precio_compra, valefeoper, htp_compra, liq_rendimiento,
            accrual, latest_inicio, tpo_tipo_valoracion, sal, dias_al_corte,
            prox_capital, prox_interes, POR_DESCRIPCION, SBP_DESCRIPCION, VALOR_UNITARIO,
            VALOR_NOMINAL, IPR_ES_CXC, TPO_ACTA, VALOR_EFECTIVO, TIPO_RENTA,
            ESTADO, Por_ord, httpo_id, tpo_recursos, TPO_PRECIO_REGISTRO_VALOR_EFECTIVO,
            TPO_TABLA_AMORTIZACION, CALIFICACION_DE_RIESGO, PRECIO_DE_HOY, INTERES_GANADO, prEfectivo,
            YIELD, NUEVO_VALOR_NOMINAL, SECTOR, INTERES_GANADO_2, tiv_tipo_base,
            NOMBRE_BONO, TPO_F1, SECTOR2
        )
        EXEC bvq_backoffice.ObtenerInfoPortfoliosPorFecha @v_cierre,null
        set @v_cierre = dateadd(s,86399,cast(eomonth(@v_cierre,1)as datetime))
    end
end
