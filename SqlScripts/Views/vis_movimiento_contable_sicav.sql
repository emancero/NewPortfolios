/*******************************************************************************
********************************************************************************/
CREATE VIEW [dbo].[vis_movimiento_contable_sicav]  
AS  
  SELECT  per.fecha_desde /*CAST('01/01/2023' AS datetime)*/                                                              AS FECHA,  
         (SELECT CUENTA  
          FROM siisspolweb.siisspolweb.contabilidad.cuenta  
          WHERE ID_CUENTA = A.id_cuenta)                                                        AS [CUENTA CTBLE],  
         /*ISNULL  
           ((SELECT CO.DESCRIPCION  
             FROM siisspolweb.siisspolweb.contabilidad.cuenta c  
                    INNER JOIN  
                  siisspolweb.siisspolweb.contabilidad.centro_costo_ejercicio_cuenta cc  
                  ON c.id_cuenta = cc.id_cuenta AND CC.id_ejercicio = 34 AND CC.id_cuenta = A.id_cuenta  
                    INNER JOIN  
                  siisspolweb.siisspolweb.contabilidad.centro_costo co ON cc.id_centro_costo = co.id_centro_costo), '')*/'' AS [SEGURO RELACIONADO],  
         (SELECT descripcion  
          FROM siisspolweb.siisspolweb.contabilidad.cuenta  
          WHERE ID_CUENTA = a.id_cuenta)                                                        AS [NOMBRE CUENTA CTBLE],  
         CONCAT('INI-', CONVERT(VARCHAR(10), '01/01/2024', 112))                                     AS COMPROBANTE,  
         CONCAT('SALDO INICIAL ', CONVERT(VARCHAR(10), '01/01/2024', 103))                           AS [REFERENCIA_MOV],  
         ''                                                                                     AS REF_ASIENTO,  
         0                                                                                      AS DEBE,  
         0                                                                                      AS HABER,  
         isnull(A.saldo_ini, 0)                                                                 AS SALDO,  
         ''                                                                                     AS CONCEPTO,  
         ''                                                                                     AS BENEFICIARIO,  
         ''                                                                                     AS ESTADO,  
         0                                                                                      AS sec,  
         ''                                                                                     AS [LINEA CONTABLE],  
         ''                                                                                     AS [CUENTA PRESUPUESTARIA],  
         ''                                                                                     AS [DESCRIPCION CUENTA PRESUPUESTARIA],  
         ''                                                                                     AS [CODIGO CENTRO COSTO],  
         ''                                                                   AS [DESCRIPCION CENTRO COSTO],  
         ''                                                                                     AS [NRO.],  
         ''                                                                                     AS [FECHA COMPROMISO],  
         0                                                                                      AS [VALOR PRESUPUESTO COM],  
         ''                                                                                     AS [Cod. Presupuestario],  
         ''                                                                                     AS DESCRIPCION_MOV,  
         0                                                                                      AS [Valor Obligacion],  
         0                                                                                      AS [Valor Compromiso Asiento],  
         ''                                                                                     AS [Fecha Cobro],  
         0                                                                                      AS [Valor Cobro Compromiso],  
         0                                 AS [Valor Cobro Asiento],  
         ''                                                                                     AS [Fecha Pago Compromiso],  
         0                                                                                      AS [Valor Pagado Compromiso],  
         0                                                                                      AS [Valor Pago Asiento],  
         A.creacion_usuario                                                                     AS [CREACION USUARIO],  
         A.modifica_usuario                                                                     AS [MODIFICA USUARIO],  
   id_asiento=null,
   A.id_periodo,
   m_creacion_fecha=null,
   m_modifica_fecha=null
FROM siisspolweb.siisspolweb.contabilidad.saldo A   INNER JOIN siisspolweb.siisspolweb.contabilidad.cuenta 
		ON a.id_cuenta = cuenta.id_cuenta			INNER JOIN siisspolweb.siisspolweb.contabilidad.periodo per  
		ON A.id_periodo = per.id_periodo
  WHERE /*id_periodo =167  
    AND*/ cuenta.movimiento = 1  
  UNION ALL  
  SELECT cast(a.fecha AS DATETIME)                                                               AS FECHA,  
         (SELECT CUENTA FROM siisspolweb.siisspolweb.contabilidad.cuenta WHERE ID_CUENTA = M.id_cuenta)                  AS [CUENTA CTBLE],  
         /*ISNULL((SELECT CO.DESCRIPCION  
                 FROM siisspolweb.siisspolweb.contabilidad.cuenta c  
                        INNER JOIN siisspolweb.siisspolweb.contabilidad.centro_costo_ejercicio_cuenta cc  
                                   ON c.id_cuenta = cc.id_cuenta AND CC.id_ejercicio = 35 AND CC.id_cuenta = M.id_cuenta  
                        INNER JOIN siisspolweb.siisspolweb.contabilidad.centro_costo co ON cc.id_centro_costo = co.id_centro_costo),  
                '')*/''                                                                              AS [SEGURO RELACIONADO],  
         (SELECT descripcion  
          FROM siisspolweb.siisspolweb.contabilidad.cuenta  
          WHERE ID_CUENTA = M.id_cuenta)                                                         AS [NOMBRE CUENTA CTBLE],  
         A.codigo                                                                                AS COMPROBANTE,  
         LTRIM(RTRIM(M.referencia))                                                              AS [REFERENCIA_MOV],  
         A.REFERENCIA                                                                            AS REF_ASIENTO,  
         CASE M.tipo WHEN 'd' THEN M.valor ELSE 0 END                                            AS DEBE,  
         CASE M.tipo WHEN 'c' THEN M.valor ELSE 0 END                                            AS HABER,  
         CASE M.tipo WHEN 'c' THEN M.valor * -1 ELSE M.VALOR END                                 AS SALDO,  
         LTRIM(RTRIM(a.concepto))                                                                AS CONCEPTO,  
         LTRIM(RTRIM(beneficiario))                                                              AS BENEFICIARIO,  
         (SELECT descripcion FROM siisspolweb.siisspolweb.contabilidad.estado_asi WHERE id_estado_asi = A.id_estado_asi) AS ESTADO,  
         M.sec,  
         ISNULL(m.sec, '')                                                                       AS [LINEA CONTABLE],  
         isnull((SELECT CUENTA  
                 FROM siisspolweb.siisspolweb.contabilidad.cuenta_presupuestaria  
                 WHERE id_cuenta_presupuestaria = P.id_cuenta_presupuestaria),  
                '')                                                                              AS [CUENTA PRESUPUESTARIA],  
         isnull((SELECT descripcion  
                 FROM siisspolweb.siisspolweb.contabilidad.cuenta_presupuestaria  
                 WHERE id_cuenta_presupuestaria = P.id_cuenta_presupuestaria),  
                '')                                                                              AS [DESCRIPCION CUENTA PRESUPUESTARIA],  
         isnull((SELECT CODIGO FROM siisspolweb.siisspolweb.contabilidad.centro_costo WHERE id_centro_costo = P.id_centro_costo),  
                '')                              AS [CODIGO CENTRO COSTO],  
         isnull((SELECT descripcion FROM siisspolweb.siisspolweb.contabilidad.centro_costo WHERE id_centro_costo = P.id_centro_costo),  
                '')                                                                              AS [DESCRIPCION CENTRO COSTO],  
         ISNULL(cp.numero, 0)                                                                    AS [NRO.],  
         ISNULL(convert(VARCHAR(10), cp.fecha_compromiso, 103), '')                              AS [FECHA COMPROMISO],  
         ISNULL(cp.valor_compromiso, 0)                                                          AS [VALOR PRESUPUESTO COM],  
         isnull((SELECT CODIGO  
                 FROM siisspolweb.siisspolweb.contabilidad.presupuesto PRE  
                 WHERE PRE.id_presupuesto = isnull(CP.id_presupuesto, 0)  
                   AND pre.id_ejercicio = 34),  
                '')                                                                              AS [Cod. Presupuestario],  
         isnull(LTRIM(RTRIM(P.descripcion)), '')                                                 AS DESCRIPCION_MOV,  
         isnull(P.valor_obligacion, 0)                                                           AS [Valor Obligacion],  
         isnull(P.valor_compromiso, 0)                                                           AS [Valor Compromiso Asiento],  
         ISNULL(convert(VARCHAR(10), cp.fecha_cobro, 103), '')                                   AS [Fecha Cobro],  
         isnull(cp.valor_cobro, 0)                                                               AS [Valor Cobro Compromiso],  
         isnull(P.valor_cobro, 0)                                                                AS [Valor Cobro Asiento],  
         ISNULL(convert(VARCHAR(10), cp.fecha_pagado, 103), '')                                  AS [Fecha Pago Compromiso],  
         isnull(cp.valor_pagado, 0)                                                              AS [Valor Pagado Compromiso],  
         isnull(P.valor_pago, 0)                                                                 AS [Valor Pago Asiento],  
         A.creacion_usuario                                                                      AS [CREACION USUARIO],  
         A.modifica_usuario                                                                      AS [MODIFICA USUARIO],  
   A.id_asiento,
   id_periodo = null,
   m_creacion_fecha=M.creacion_fecha,
   m_modifica_fecha=M.modifica_fecha
  FROM siisspolweb.siisspolweb.contabilidad.asiento A  
         INNER JOIN siisspolweb.siisspolweb.contabilidad.movimiento M ON A.id_asiento = M.id_asiento  
         LEFT JOIN siisspolweb.siisspolweb.contabilidad.movimiento_presupuesto P ON M.id_asiento = P.id_asiento AND M.SEC = P.sec  
         LEFT JOIN siisspolweb.siisspolweb.contabilidad.compromiso_presupuesto cp ON cp.id_compromiso_presupuesto = p.id_compromiso_presupuesto  
  WHERE /*A.fecha BETWEEN '01/01/2024' AND '31/12/2024'  
    AND*/ id_estado_asi <> 'N' 
