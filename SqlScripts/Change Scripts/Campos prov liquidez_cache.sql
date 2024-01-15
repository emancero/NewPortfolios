IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'tiv_tipo_base'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.liquidez_cache'))
BEGIN
    alter table BVQ_BACKOFFICE.liquidez_cache 
   add tiv_tipo_base int 
END

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'saldo'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.liquidez_cache'))
BEGIN
    alter table BVQ_BACKOFFICE.liquidez_cache 
   add saldo float 
END

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'tiv_interes_irregular'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.liquidez_cache'))
BEGIN
    alter table BVQ_BACKOFFICE.liquidez_cache 
   add tiv_interes_irregular bit 
END

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'tfl_interes'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.liquidez_cache'))
BEGIN
    alter table BVQ_BACKOFFICE.liquidez_cache 
   add tfl_interes float 
END
