if not exists(select * from bvq_seguridad.funcionalidad where fun_nombre='Créditos' and fun_padre is null)
begin
	insert into bvq_seguridad.funcionalidad(MOD_ID,FUN_NOMBRE,FUN_TIPO,FUN_CODIGO,FUN_ESTADO,FUN_AUDITAR,FUN_ORDEN)
	values(
	6,'Créditos',88,'CREDITOS_ISSPOL',82,1,86)

	insert into bvq_seguridad.funcionalidad(MOD_ID,FUN_NOMBRE,FUN_TIPO,FUN_CODIGO,FUN_ESTADO,FUN_NOMBRE_DLL
	,FUN_NOMBRE_CLASE,FUN_PADRE,FUN_AUDITAR,FUN_ORDEN,FUN_ES_VERSION2)
	select 6,nombre,89,codigo,82,nombre_dll, clase
	, (select * from bvq_seguridad.funcionalidad where fun_nombre='Créditos' and fun_padre is null)
	,1,orden,null
	from(
	values
		(10,'Cartera de Créditos','CRED_CARTERA','Bvq.Sipla.Portfolio.Module.dll','Bvq.Sipla.Portfolio.Module.CarteraCreditosView'),
		(20,'Flujo de Caja','CRED_FLUJO','Bvq.Sipla.Portfolio.Module.dll','Bvq.Sipla.Portfolio.Module.CashFlowReportView'),
		(30,'Tasa Promedio Ponderada','CRED_TASA_PROMEDIO','Bvq.Sipla.Portfolio.Module.dll','Bvq.Sipla.Portfolio.Module.TasaPromedioPonderadaView'),
		(40,'Tasa de Mora','CRED_TASA_MORA','Bvq.Sipla.Portfolio.Module.dll','Bvq.Sipla.Portfolio.Module.TasaMoraView'),
		(50,'Tasa Interna de Retorno','ISSPOL_TIR','Bvq.Sipla.Isspol.Module.dll','Bvq.Sipla.Isspol.Module.TasaInternaRetornoView')
	) v (orden, nombre, codigo, nombre_dll, clase)
end