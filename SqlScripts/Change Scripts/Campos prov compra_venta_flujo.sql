IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'saldo'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.compra_venta_flujo'))
BEGIN
    alter table BVQ_BACKOFFICE.compra_venta_flujo 
   add saldo float 
END

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'tiv_interes_irregular'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.compra_venta_flujo'))
BEGIN
    alter table BVQ_BACKOFFICE.compra_venta_flujo 
   add tiv_interes_irregular bit 
END

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'tfl_interes'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.compra_venta_flujo'))
BEGIN
    alter table BVQ_BACKOFFICE.compra_venta_flujo 
   add tfl_interes float 
END

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'FON_ID'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.compra_venta_flujo'))
BEGIN
    alter table BVQ_BACKOFFICE.compra_venta_flujo 
   add FON_ID int
END

if NOT EXISTS (SELECT 1 FROM sys.columns 
          WHERE Name = N'HTP_TIENE_VALNOM'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.compra_venta_flujo'))
begin
	 alter table bvq_backoffice.compra_venta_flujo
    add HTP_TIENE_VALNOM bit
end
