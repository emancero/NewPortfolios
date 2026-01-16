CREATE view bvq_administracion.ValorEfectivoBonoUtilidad as
    SELECT concepto, valor,por.por_id,convert(date,'20251231') fechaDesde,convert(date,'99991231') fechaHasta
    FROM (VALUES
        ('RIM',                         63482.07),
        ('ACCIDENTES PROFESIONALES',     17916.94),
        ('SEGURO DE VIDA ACTIVOS',      32877.23),
        ('MORTUORIA',                    13882.37),
        ('FONDOS DE RESERVA',            18601.77),
        ('ENFERMEDAD Y MATERNIDAD',       2985.13),
        ('FONDO DE VIVIENDA',           127668.42),
        ('SEGURO DE SALDOS',              7239.69),
        ('SEGURO DE DESGRAVAMEN',         2985.11),
        ('SEGURO DE VIDA CONTRATADO',    13134.56),
        ('IND. PROFESIONALES',                  0.00)
    ) v(concepto, valor)
    join bvq_backoffice.portafolio por on por_codigo=concepto
