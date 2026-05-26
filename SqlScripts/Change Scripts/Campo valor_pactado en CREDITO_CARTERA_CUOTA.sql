IF NOT EXISTS(
    select * from sys.columns
    where object_id=object_id('BVQ_BACKOFFICE.CREDITO_CARTERA_CUOTA')
    and name='valor_pactado'
)
BEGIN
    ALTER TABLE [BVQ_BACKOFFICE].[CREDITO_CARTERA_CUOTA]
    ADD valor_pactado MONEY NULL;
END