IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'tiv_tipo_base'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.evtTemp'))
BEGIN
    alter table BVQ_BACKOFFICE.evtTemp 
   add tiv_tipo_base int 
END

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'saldo'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.evtTemp'))
BEGIN
    alter table BVQ_BACKOFFICE.evtTemp 
   add saldo float 
END

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'tiv_interes_irregular'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.evtTemp'))
BEGIN
    alter table BVQ_BACKOFFICE.evtTemp 
   add tiv_interes_irregular bit 
END

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'tfl_interes'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.evtTemp'))
BEGIN
    alter table BVQ_BACKOFFICE.evtTemp 
   add tfl_interes float 
END

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'provision'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.evtTemp'))
BEGIN
    alter table BVQ_BACKOFFICE.evtTemp 
   add provision float 
END

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'itrans'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.evtTemp'))
BEGIN
    alter table BVQ_BACKOFFICE.evtTemp 
   add itrans float 
END

IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'evp_referencia'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.evtTemp'))
BEGIN
    alter table BVQ_BACKOFFICE.evtTemp
   add evp_referencia varchar(15) 
END 

/*IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'originalProvision'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.evtTemp'))
BEGIN
    alter table BVQ_BACKOFFICE.evtTemp
   add originalProvision float 
END*/
