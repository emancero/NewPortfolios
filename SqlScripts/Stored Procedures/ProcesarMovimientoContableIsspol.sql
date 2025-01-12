CREATE procedure [BVQ_BACKOFFICE].[ProcesarMovimientoContableISSPOL]
  @o_resultado int output,  --envío el resultado de la ejecución de la transacción    
  @i_fecha_corte datetime,    
  @i_lga_id int    
AS    
    
BEGIN    
 SET NOCOUNT ON;    
     
  declare @v_fecha_ult_proceso datetime    
    
  select @v_fecha_ult_proceso=max(MOV_FECHA) from [Sicav].[_temp].[isspol_movimiento_contable_fuente]    
    
  --delete from [Sicav].[_temp].[isspol_movimiento_contable_fuente] where datediff(dd,MOV_FECHA,@v_fecha_ult_proceso)=0    
  declare @lsn int    
  SELECT @lsn=LSN_SEQ FROM BVQ_BACKOFFICE.ISSPOL_MOV_LSN    
  exec bvq_backoffice.IsspolLogImportacionMovimientos @i_fecha_corte,'start'
  insert into [_temp].[isspol_movimiento_contable_fuente]    
     ([MOV_FECHA],[MOV_CUENTA_CONTABLE],[MOV_SEGURO_RELACIONADO],[MOV_CUENTA_CONTABLE_NOMBRE],[MOV_COMPROBANTE],[MOV_REFERENCIA],[MOV_REFERENCIA_ASIENTO]
     ,[MOV_DEBE],[MOV_HABER],[MOV_SALDO],[MOV_CONCEPTO],[MOV_BENEFICIARIO],[MOV_ESTADO],[MOV_SEC],[MOV_LINEA CONTABLE]
     ,[MOV_CUENTA_PRESUPUESTARIA],[MOV_CUENTA_PRESUPUESTARIA_DESCRIPCION],[MOV_CCO_CODIGO],[MOV_CCO_DESCRIPCION]    
     ,[MOV_NRO],[MOV_FECHA_COMPROMISO],[MOV_VALOR_PRESUPUESTO_COM],[MOV_CODIGO_PRESUPUESTARIO],[MOV_DESCRIPCION],[MOV_VALOR_OBLIGACION]
     ,[MOV_VALOR_COMPROMISO_ASIENTO],[MOV_FECHA_COBRO],[MOV_VALOR_COBRO_COMPROMISO],[MOV_VALOR_COBRO_ASIENTO],[MOV_FECHA_PAGO_COMPROMISO]
     ,[MOV_VALOR_PAGADO_COMPROMISO],[MOV_VALOR_PAGO_ASIENTO],[MOV_USUARIO_CREACION],[MOV_USUARIO_MODIFICA],MOV_TIPO_MOVIMIENTO
     ,id_asiento)    
    
  select    
   [FECHA],[CUENTA CTBLE],[SEGURO RELACIONADO],[NOMBRE CUENTA CTBLE],[COMPROBANTE],[REFERENCIA_MOV],[REF_ASIENTO]
   ,[DEBE],[HABER],[SALDO],[CONCEPTO],[BENEFICIARIO],[ESTADO],[sec],[LINEA CONTABLE]
   ,[CUENTA PRESUPUESTARIA],[DESCRIPCION CUENTA PRESUPUESTARIA],[CODIGO CENTRO COSTO],[DESCRIPCION CENTRO COSTO]    
   ,[NRO.],[FECHA COMPROMISO],[VALOR PRESUPUESTO COM],[Cod. Presupuestario],[DESCRIPCION_MOV],[Valor Obligacion]
   ,[Valor Compromiso Asiento],[Fecha Cobro],[Valor Cobro Compromiso],[Valor Cobro Asiento],[Fecha Pago Compromiso]
   ,[Valor Pagado Compromiso],[Valor Pago Asiento],[CREACION USUARIO],[MODIFICA USUARIO],case when DEBE>0 then 5174 else 5175 end
   ,id_asiento
    
  from --siisspolweb.siisspolweb.contabilidad.    
  [vis_movimiento_contable_sicav] with (nolock)    
  where     
  id_asiento>isnull(@lsn,0)    
      
  update BVQ_BACKOFFICE.ISSPOL_MOV_LSN set lsn_seq=(select max(id_asiento) from [_temp].[isspol_movimiento_contable_fuente])    
  --datediff(dd,FECHA,@i_fecha_corte)>0    
  --and datediff(dd,FECHA,isnull(@v_fecha_ult_proceso,'1900-01-01'))<=0    
    exec bvq_backoffice.IsspolLogImportacionMovimientos @i_fecha_corte,'end'
  
  /*union    
  select    
   [FECHA],[CUENTA CTBLE],[SEGURO RELACIONADO],[NOMBRE CUENTA CTBLE],[COMPROBANTE],[REFERENCIA_MOV],[REF_ASIENTO],[DEBE],[HABER],[SALDO]    
   ,[CONCEPTO],[BENEFICIARIO],[ESTADO],[sec],[LINEA CONTABLE],[CUENTA PRESUPUESTARIA],[DESCRIPCION CUENTA PRESUPUESTARIA],[CODIGO CENTRO COSTO],[DESCRIPCION CENTRO COSTO]    
   ,[NRO.],[FECHA COMPROMISO],[VALOR PRESUPUESTO COM],[Cod. Presupuestario],[DESCRIPCION_MOV],[Valor Obligacion],[Valor Compromiso Asiento],[Fecha Cobro]    
   ,[Valor Cobro Compromiso],[Valor Cobro Asiento],[Fecha Pago Compromiso],[Valor Pagado Compromiso],[Valor Pago Asiento],[CREACION USUARIO],[MODIFICA USUARIO]    
  from siisspolweb.siisspolweb.contabilidad.[vis_movimiento_contable_2023]    
  where datediff(dd,FECHA,@i_fecha_corte)=0*/    
  --xx exec bvq_backoffice.IsspolProcesarUltimoDia @i_fecha_corte    
   
   --INSERTAR SALDO INICIAL 
   TRUNCATE TABLE BVQ_BACKOFFICE.isspol_saldo_inicial
   insert into BVQ_BACKOFFICE.isspol_saldo_inicial
			  ([MOV_FECHA],[MOV_CUENTA_CONTABLE],[MOV_SEGURO_RELACIONADO],[MOV_CUENTA_CONTABLE_NOMBRE],[MOV_COMPROBANTE],[MOV_REFERENCIA],[MOV_REFERENCIA_ASIENTO]
              ,[MOV_DEBE],[MOV_HABER],[MOV_SALDO],[MOV_CONCEPTO],[MOV_BENEFICIARIO],[MOV_ESTADO],[MOV_SEC],[MOV_LINEACONTABLE]
              ,[MOV_CUENTA_PRESUPUESTARIA],[MOV_CUENTA_PRESUPUESTARIA_DESCRIPCION],[MOV_CCO_CODIGO],[MOV_CCO_DESCRIPCION]
			  ,[MOV_NRO],[MOV_FECHA_COMPROMISO],[MOV_VALOR_PRESUPUESTO_COM],[MOV_CODIGO_PRESUPUESTARIO],[MOV_DESCRIPCION],[MOV_VALOR_OBLIGACION]
              ,[MOV_VALOR_COMPROMISO_ASIENTO],[MOV_FECHA_COBRO],[MOV_VALOR_COBRO_COMPROMISO],[MOV_VALOR_COBRO_ASIENTO]
              ,[MOV_FECHA_PAGO_COMPROMISO],[MOV_VALOR_PAGADO_COMPROMISO],[MOV_VALOR_PAGO_ASIENTO],[MOV_USUARIO_CREACION],[MOV_USUARIO_MODIFICA]
			  ,id_asiento
			  )
 
		select
			[FECHA],[CUENTA CTBLE],[SEGURO RELACIONADO],[NOMBRE CUENTA CTBLE],[COMPROBANTE],[REFERENCIA_MOV],[REF_ASIENTO]
            ,[DEBE],[HABER],[SALDO],[CONCEPTO],[BENEFICIARIO],[ESTADO],[sec],[LINEA CONTABLE]
            ,[CUENTA PRESUPUESTARIA],[DESCRIPCION CUENTA PRESUPUESTARIA],[CODIGO CENTRO COSTO],[DESCRIPCION CENTRO COSTO]
			,[NRO.],[FECHA COMPROMISO],[VALOR PRESUPUESTO COM],[Cod. Presupuestario],[DESCRIPCION_MOV],[Valor Obligacion]
            ,[Valor Compromiso Asiento],[Fecha Cobro],[Valor Cobro Compromiso],[Valor Cobro Asiento]
            ,[Fecha Pago Compromiso],[Valor Pagado Compromiso],[Valor Pago Asiento],[CREACION USUARIO],[MODIFICA USUARIO]
			,id_asiento
 
		from --siisspolweb.siisspolweb.contabilidad.
		[vis_movimiento_contable_sicav] with (nolock)
		where debe=0 and haber=0 and id_periodo >= 155
    
      
  --EXEC [BVQ_BACKOFFICE].[CategorizacionMovimientosISSPOL] @i_fecha_corte,@v_fecha_ult_proceso    
      
END 
