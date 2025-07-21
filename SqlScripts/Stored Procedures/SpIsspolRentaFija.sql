CREATE PROCEDURE [BVQ_BACKOFFICE].[spIsspolRentaFija] @i_fechaCorte datetime=null, @i_lga_id int=null as    
 begin
 begin tran
  delete from corteslist    
  insert into corteslist(c,cortenum)    
  select @i_fechaCorte,1    
  exec bvq_backoffice.GenerarCompraVentaFlujo    
  exec bvq_administracion.GenerarVectores    
  exec bvq_administracion.PrepararValoracionLinealCache    
  exec bvq_administracion.GenerarTasaValorCompact    
  update bvq_administracion.CodigoCortoSicTit set enc_numero_corto_emision=codigocorto

  if 0=1     
   select     
   FECHA_EVALUACION=@i_fechaCorte    
    
	set transaction isolation level read uncommitted
	select * from BVQ_BACKOFFICE.IsspolRentaFijaView
	order by fecha_valor_de_compra,tpo_ord

  if 1=1     
   SELECT     
   NOTA=INC_DESCRIPCION    
   FROM BVQ_BACKOFFICE.ISSPOL_NOTAS_CXC    
   WHERE @i_fechaCorte between isnull(INC_FECHA_DESDE,0) and isnull(INC_FECHA_HASTA,'9999-12-31T00:00:00')    
   AND INC_ARCHIVO='RF'    
   ORDER BY INC_ORDEN    
 commit tran
 end 
