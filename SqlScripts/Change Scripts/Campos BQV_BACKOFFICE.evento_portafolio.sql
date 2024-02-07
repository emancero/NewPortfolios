IF not EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'evp_referencia'
          AND Object_ID = Object_ID(N'BVQ_BACKOFFICE.evento_portafolio'))
BEGIN
    alter table BVQ_BACKOFFICE.evento_portafolio 
   add evp_referencia varchar(15) 
END 