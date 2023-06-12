﻿CREATE TABLE [BVQ_BACKOFFICE].[RETRASO]
(
	[RETR_ID] INT NOT NULL PRIMARY KEY IDENTITY, 
    [RETR_TPO_ID] INT NOT NULL, 
    [RETR_FECHA_ESPERADA] DATETIME NOT NULL, 
    [RETR_FECHA_COBRO] DATETIME NOT NULL, 
    [RETR_CAPITAL] BIT NOT NULL, 
    [RETR_INTERES] BIT NOT NULL 
)
