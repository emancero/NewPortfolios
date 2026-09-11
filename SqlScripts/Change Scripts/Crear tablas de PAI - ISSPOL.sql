--------------------------------------------------------------------------
-- Script de creacion de tablas: BVQ_BACKOFFICE (SQL Server)
-- Modulo: PAI (Tipo Inversion / Fondo / Tabla / General / Monto)
--------------------------------------------------------------------------

--------------------------------------------------------------------------
-- 0. BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO
--------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO') AND type = N'U')
BEGIN
    CREATE TABLE BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO
    (
        PCP_ID INT IDENTITY(1,1) NOT NULL,
        PCP_TIPO VARCHAR(20) NOT NULL,   -- 'TIPO_INVERSION' | 'FONDO'
        PCP_NOMBRE VARCHAR(200) NOT NULL,
        PCP_CODIGO VARCHAR(50) NOT NULL,
        CONSTRAINT PK_PAI_CODIGO_PRESTABLECIDO PRIMARY KEY (PCP_ID)
    );
END
GO

--------------------------------------------------------------------------
-- Seed: BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO — Tipos de Inversión
--------------------------------------------------------------------------
INSERT INTO BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO (PCP_TIPO, PCP_NOMBRE, PCP_CODIGO)
SELECT v.PCP_TIPO, v.PCP_NOMBRE, v.PCP_CODIGO
FROM (VALUES
    ('TIPO_INVERSION', N'Bonos del Estado', 'BON'),
    ('TIPO_INVERSION', N'Cert. Tesorería', 'CET'),
    ('TIPO_INVERSION', N'Cert. Inversión/Cert. Depósito/Póliza Acumulación', 'IFI'),
    ('TIPO_INVERSION', N'Obligaciones/Obligaciones Conv. Acciones OCAs', 'OGG'),
    ('TIPO_INVERSION', N'Papel Comercial', 'PCO'),
    ('TIPO_INVERSION', N'Reporto Bursátil', 'REP'),
    ('TIPO_INVERSION', N'Titularizaciones VTC', 'TIT'),
    ('TIPO_INVERSION', N'Facturas Comerciales', 'FCO'),
    ('TIPO_INVERSION', N'Acciones', 'ACC'),
    ('TIPO_INVERSION', N'Cesión Derechos Fiduciarios', 'CDF'),
    ('TIPO_INVERSION', N'Fondos de Inversión Colectivo/Cotizados', 'CPT'),
    ('TIPO_INVERSION', N'Fondos de Inversión Administrados', 'FIA'),
    ('TIPO_INVERSION', N'Valores Titularización Participación VTP', 'VTP'),
    ('TIPO_INVERSION', N'Propiedades de Inversión', 'PIN')
) AS v(PCP_TIPO, PCP_NOMBRE, PCP_CODIGO)
WHERE NOT EXISTS (
    SELECT 1 FROM BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO t
    WHERE t.PCP_TIPO = v.PCP_TIPO AND t.PCP_NOMBRE = v.PCP_NOMBRE
);
GO

--------------------------------------------------------------------------
-- Seed: BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO — Fondos
--------------------------------------------------------------------------
INSERT INTO BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO (PCP_TIPO, PCP_NOMBRE, PCP_CODIGO)
SELECT v.PCP_TIPO, v.PCP_NOMBRE, v.PCP_CODIGO
FROM (VALUES
    ('FONDO', N'RIM', 'RIM'),
    ('FONDO', N'ACC. PROF.', 'ACC_PROF'),
    ('FONDO', N'SEG. VIDA ACT.', 'SEG_VIDA_ACT'),
    ('FONDO', N'MORTUORIA', 'MORTUORIA'),
    ('FONDO', N'F. RESERVA', 'RESERVA'),
    ('FONDO', N'ENF. Y MAT.', 'ENF_MAT'),
    ('FONDO', N'F. VIVIENDA', 'VIVIENDA'),
    ('FONDO', N'SEG. SALDOS', 'SEG_SALDOS'),
    ('FONDO', N'SEG. DESGRAV', 'SEG_DESGRAV'),
    ('FONDO', N'SEG. VIDA CONT.', 'SEG_VIDA_CONT'),
    ('FONDO', N'IND. PROF.', 'IND_PROF'),
    ('FONDO', N'CESANTIA', 'CESANTIA'),
    ('FONDO', N'RIM-MORTUORIA', 'RIM_MORTUORIA'),
    ('FONDO', N'SEG. VIDA-ACC. PROF.', 'SEG_VIDA_ACC_PROF')
) AS v(PCP_TIPO, PCP_NOMBRE, PCP_CODIGO)
WHERE NOT EXISTS (
    SELECT 1 FROM BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO t
    WHERE t.PCP_TIPO = v.PCP_TIPO AND t.PCP_NOMBRE = v.PCP_NOMBRE
);
GO

--------------------------------------------------------------------------
-- 1. BVQ_BACKOFFICE.PAI_CODIGO_TIPO_VALOR
--------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_CODIGO_TIPO_VALOR') AND type = N'U')
BEGIN
    CREATE TABLE BVQ_BACKOFFICE.PAI_CODIGO_TIPO_VALOR
    (
        PCTV_ID INT IDENTITY(1,1) NOT NULL,
        PCP_ID INT NOT NULL,
        TVL_ID INT NOT NULL,
        CONSTRAINT PK_PAI_CODIGO_TIPO_VALOR PRIMARY KEY (PCTV_ID),
        CONSTRAINT FK_PCTV_CODIGO_PRESTABLECIDO
            FOREIGN KEY (PCP_ID) REFERENCES BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO (PCP_ID),
        CONSTRAINT FK_PCTV_TIPO_VALOR
            FOREIGN KEY (TVL_ID) REFERENCES BVQ_ADMINISTRACION.TIPO_VALOR (TVL_ID)
    );
END
GO

--------------------------------------------------------------------------
-- Seed: BVQ_BACKOFFICE.PAI_CODIGO_TIPO_VALOR — Tipos de Inversión -> Tipo de Valor
--------------------------------------------------------------------------
INSERT INTO BVQ_BACKOFFICE.PAI_CODIGO_TIPO_VALOR (PCP_ID, TVL_ID)
SELECT p.PCP_ID, v.TVL_ID
FROM (VALUES
    (N'Bonos del Estado', 3),
    (N'Cert. Tesorería', 13),
    (N'Cert. Inversión/Cert. Depósito/Póliza Acumulación', 6),
    (N'Cert. Inversión/Cert. Depósito/Póliza Acumulación', 5),
    (N'Cert. Inversión/Cert. Depósito/Póliza Acumulación', 11),
    (N'Obligaciones/Obligaciones Conv. Acciones OCAs', 9),
    (N'Obligaciones/Obligaciones Conv. Acciones OCAs', 18),
    (N'Papel Comercial', 10),
    (N'Reporto Bursátil', 30),
    (N'Titularizaciones VTC', 20),
    (N'Facturas Comerciales', 27),
    (N'Acciones', 1),
    (N'Cesión Derechos Fiduciarios', 10000002),
    (N'Valores Titularización Participación VTP', 33)
) AS v(PCP_NOMBRE, TVL_ID)
INNER JOIN BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO p
    ON p.PCP_TIPO = 'TIPO_INVERSION' AND p.PCP_NOMBRE = v.PCP_NOMBRE
WHERE NOT EXISTS (
    SELECT 1 FROM BVQ_BACKOFFICE.PAI_CODIGO_TIPO_VALOR t
    WHERE t.PCP_ID = p.PCP_ID AND t.TVL_ID = v.TVL_ID
);
GO

--------------------------------------------------------------------------
-- 2. BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO
--------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO') AND type = N'U')
BEGIN
    CREATE TABLE BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO
    (
        PCPO_ID INT IDENTITY(1,1) NOT NULL,
        PCP_ID INT NOT NULL,
        POR_ID INT NOT NULL,
        CONSTRAINT PK_PAI_CODIGO_PORTAFOLIO PRIMARY KEY (PCPO_ID),
        CONSTRAINT FK_PCPO_CODIGO_PRESTABLECIDO
            FOREIGN KEY (PCP_ID) REFERENCES BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO (PCP_ID),
        CONSTRAINT FK_PCPO_PORTAFOLIO
            FOREIGN KEY (POR_ID) REFERENCES BVQ_BACKOFFICE.PORTAFOLIO (POR_ID)
    );
END
GO

--------------------------------------------------------------------------
-- Seed: BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO — Fondos -> Portafolio
--------------------------------------------------------------------------
INSERT INTO BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO (PCP_ID, POR_ID)
SELECT p.PCP_ID, v.POR_ID
FROM (VALUES
    (N'RIM', 9),
    (N'ACC. PROF.', 2),
    (N'SEG. VIDA ACT.', 13),
    (N'MORTUORIA', 8),
    (N'F. RESERVA', 6),
    (N'ENF. Y MAT.', 4),
    (N'F. VIVIENDA', 5),
    (N'SEG. SALDOS', 12),
    (N'SEG. DESGRAV', 11),
    (N'SEG. VIDA CONT.', 14),
    (N'IND. PROF.', 7),
    (N'CESANTIA', 3),
    (N'RIM-MORTUORIA', 10),
    (N'SEG. VIDA-ACC. PROF.', 15)
) AS v(PCP_NOMBRE, POR_ID)
INNER JOIN BVQ_BACKOFFICE.PAI_CODIGO_PRESTABLECIDO p
    ON p.PCP_TIPO = 'FONDO' AND p.PCP_NOMBRE = v.PCP_NOMBRE
WHERE NOT EXISTS (
    SELECT 1 FROM BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO t
    WHERE t.PCP_ID = p.PCP_ID AND t.POR_ID = v.POR_ID
);
GO

--------------------------------------------------------------------------
-- 3. BVQ_BACKOFFICE.PAI_GENERAL
--------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_GENERAL') AND type = N'U')
BEGIN
    CREATE TABLE BVQ_BACKOFFICE.PAI_GENERAL
    (
        PAI_ID INT IDENTITY(1,1) NOT NULL,
        PAI_PERIODO VARCHAR(100) NULL,
        CONSTRAINT PK_PAI_GENERAL PRIMARY KEY (PAI_ID)
    );
END
GO

--------------------------------------------------------------------------
-- 4. BVQ_BACKOFFICE.PAI_TABLA
--------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_TABLA') AND type = N'U')
BEGIN
    CREATE TABLE BVQ_BACKOFFICE.PAI_TABLA
    (
        TAB_ID INT IDENTITY(1,1) NOT NULL,
        PAI_ID INT NOT NULL,
        TAB_NOMBRE VARCHAR(500) NOT NULL,
        TAB_ORDEN INT NOT NULL DEFAULT (0),
        CONSTRAINT PK_PAI_TABLA PRIMARY KEY (TAB_ID),
        CONSTRAINT FK_TAB_PAI_GENERAL
            FOREIGN KEY (PAI_ID) REFERENCES BVQ_BACKOFFICE.PAI_GENERAL (PAI_ID)
    );
END
GO

--------------------------------------------------------------------------
-- 5. BVQ_BACKOFFICE.PAI_TIPO_INVERSION
--------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_TIPO_INVERSION') AND type = N'U')
BEGIN
    CREATE TABLE BVQ_BACKOFFICE.PAI_TIPO_INVERSION
    (
        TIP_ID INT IDENTITY(1,1) NOT NULL,
        TAB_ID INT NOT NULL,
        TIP_NOMBRE VARCHAR(200) NOT NULL,
        TIP_CODIGO VARCHAR(50) NOT NULL,
        TIP_ORDEN INT NOT NULL DEFAULT (0),
        CONSTRAINT PK_PAI_TIPO_INVERSION PRIMARY KEY (TIP_ID),
        CONSTRAINT FK_TIP_PAI_TABLA
            FOREIGN KEY (TAB_ID) REFERENCES BVQ_BACKOFFICE.PAI_TABLA (TAB_ID)
    );
END
GO

--------------------------------------------------------------------------
-- 6. BVQ_BACKOFFICE.PAI_FONDO
--------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_FONDO') AND type = N'U')
BEGIN
    CREATE TABLE BVQ_BACKOFFICE.PAI_FONDO
    (
        FOP_ID INT IDENTITY(1,1) NOT NULL,
        TAB_ID INT NOT NULL,
        FOP_NOMBRE VARCHAR(200) NOT NULL,
        FOP_CODIGO VARCHAR(50) NOT NULL,
        FOP_ORDEN INT NOT NULL DEFAULT (0),
        CONSTRAINT PK_PAI_FONDO PRIMARY KEY (FOP_ID),
        CONSTRAINT FK_FOP_PAI_TABLA
            FOREIGN KEY (TAB_ID) REFERENCES BVQ_BACKOFFICE.PAI_TABLA (TAB_ID)
    );
END
GO

--------------------------------------------------------------------------
-- 7. BVQ_BACKOFFICE.PAI_MONTO
--------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_MONTO') AND type = N'U')
BEGIN
    CREATE TABLE BVQ_BACKOFFICE.PAI_MONTO
    (
        PAIM_ID INT IDENTITY(1,1) NOT NULL,
        TAB_ID INT NOT NULL,
        TIP_ID INT NOT NULL,
        FOP_ID INT NOT NULL,
        PAIM_MONTO FLOAT NULL,
        CONSTRAINT PK_PAI_MONTO PRIMARY KEY (PAIM_ID),
        CONSTRAINT FK_PAIM_PAI_TABLA
            FOREIGN KEY (TAB_ID) REFERENCES BVQ_BACKOFFICE.PAI_TABLA (TAB_ID),
        CONSTRAINT FK_PAIM_PAI_TIPO_INVERSION
            FOREIGN KEY (TIP_ID) REFERENCES BVQ_BACKOFFICE.PAI_TIPO_INVERSION (TIP_ID),
        CONSTRAINT FK_PAIM_PAI_FONDO
            FOREIGN KEY (FOP_ID) REFERENCES BVQ_BACKOFFICE.PAI_FONDO (FOP_ID)
    );
END
GO

--------------------------------------------------------------------------
-- Indices sobre las FK de PAI_TABLA
--------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TAB_PAI_ID' AND object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_TABLA'))
    CREATE INDEX IX_TAB_PAI_ID ON BVQ_BACKOFFICE.PAI_TABLA (PAI_ID);
GO

--------------------------------------------------------------------------
-- Indices sobre las FK de PAI_TIPO_INVERSION y PAI_FONDO
--------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_TIP_TAB_ID' AND object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_TIPO_INVERSION'))
    CREATE INDEX IX_TIP_TAB_ID ON BVQ_BACKOFFICE.PAI_TIPO_INVERSION (TAB_ID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FOP_TAB_ID' AND object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_FONDO'))
    CREATE INDEX IX_FOP_TAB_ID ON BVQ_BACKOFFICE.PAI_FONDO (TAB_ID);
GO

--------------------------------------------------------------------------
-- Indices sobre las FK de PAI_MONTO
--------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PAIM_TAB_ID' AND object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_MONTO'))
    CREATE INDEX IX_PAIM_TAB_ID ON BVQ_BACKOFFICE.PAI_MONTO (TAB_ID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PAIM_TIP_ID' AND object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_MONTO'))
    CREATE INDEX IX_PAIM_TIP_ID ON BVQ_BACKOFFICE.PAI_MONTO (TIP_ID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PAIM_FOP_ID' AND object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_MONTO'))
    CREATE INDEX IX_PAIM_FOP_ID ON BVQ_BACKOFFICE.PAI_MONTO (FOP_ID);
GO

--------------------------------------------------------------------------
-- Indices sobre las FK de PAI_CODIGO_TIPO_VALOR y PAI_CODIGO_PORTAFOLIO
--------------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PCTV_PCP_ID' AND object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_CODIGO_TIPO_VALOR'))
    CREATE INDEX IX_PCTV_PCP_ID ON BVQ_BACKOFFICE.PAI_CODIGO_TIPO_VALOR (PCP_ID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PCTV_TVL_ID' AND object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_CODIGO_TIPO_VALOR'))
    CREATE INDEX IX_PCTV_TVL_ID ON BVQ_BACKOFFICE.PAI_CODIGO_TIPO_VALOR (TVL_ID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PCPO_PCP_ID' AND object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO'))
    CREATE INDEX IX_PCPO_PCP_ID ON BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO (PCP_ID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_PCPO_POR_ID' AND object_id = OBJECT_ID(N'BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO'))
    CREATE INDEX IX_PCPO_POR_ID ON BVQ_BACKOFFICE.PAI_CODIGO_PORTAFOLIO (POR_ID);
GO
