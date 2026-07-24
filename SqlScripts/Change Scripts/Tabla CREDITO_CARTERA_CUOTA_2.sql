CREATE TABLE bvq_backoffice.credito_cartera_cuota_2 (
    --por_codigo       VARCHAR(50),
    id_credito          VARCHAR(20),
    id_numero_cuota     INT,
    id_cuenta           INT,
    id_rubro            VARCHAR,
    id_estado           CHAR,
    fecha_vencimiento   DATE,
    fecha_corte         DATE,
    valor_pactado       MONEY,
    total               MONEY,
    saldo               MONEY,
    pagada              BIT
)