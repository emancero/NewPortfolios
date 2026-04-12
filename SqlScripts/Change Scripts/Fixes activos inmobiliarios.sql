--sp_helptext 'bvq_backoffice.ObtenerPortfolio'
--sp_helptext 'bvq_backoffice.InsertarActivosInmobiliariosISSPOL'
update imb set imb_forma_adquisicion='Compra venta'+iif(imb_tipo='Terreno Zambiza',char(13)+char(10)+'Expropiación con el carácter de utilidad o de interés social','')
from bvq_backoffice.activos_inmobiliarios imb

update  imb set imb_cuenta_contable=cta from(
	values
	('7190101001',	'Terreno Zambiza'),
	('7190101004',	'Terreno MAPRECO'),
	('7190101005',	'Terreno AMBIENSA'),
	('7190101006',	'Terreno UYUMBICHO (ANCHAMAZA)'),
	('7190101002',	'Terreno de Calderón'),
	('7180101001',	'Centro Biblico%el Pacto-Programa S.S.'),
	('7190101003',	'Obra terminada a ser adjudicada-Dep.Quitumbe')
) v (cta,tipo)
left join bvq_backoffice.ACTIVOS_INMOBILIARIOS imb on imb.imb_tipo like tipo

declare @clave varchar(1500)

set @clave='Inmueble: Edificio - Terreno ISSPOL'
delete from [BVQ_BACKOFFICE].[ACTIVOS_INMOBILIARIOS] where imb_tipo=@clave
exec [BVQ_BACKOFFICE].[InsertarActivosInmobiliariosISSPOL]
		@POR_CODIGO='Administradora',--			   VARCHAR(50),
		@IMB_TIPO=@clave,--			   VARCHAR(1500),
		@IMB_PROVINCIA='Pichincha',--		   VARCHAR(300),
		@IMB_UBICACION='Quito',--		   VARCHAR(300),
		@IMB_VALOR_LIBROS=6538477.64,--	   FLOAT = NULL	,
		@IMB_VALOR_AVALUO=null,--	   FLOAT = NULL,
		@IMB_FECHA_ULT_AVALUO=null,--  DATETIME = NULL,
		@IMB_FECHA_ESCRITURA='19961211',--   DATETIME = NULL,
		@IMB_CUENTA_CONTABLE='150101001',--   VARCHAR(100),
		@IMB_FORMA_ADQUISICION='Compra venta',-- VARCHAR(1500),
		@i_lga_id=null

set @clave='Local del Edificio Centenario'
delete from [BVQ_BACKOFFICE].[ACTIVOS_INMOBILIARIOS] where imb_tipo=@clave
exec [BVQ_BACKOFFICE].[InsertarActivosInmobiliariosISSPOL]
		@POR_CODIGO='Administradora',--			   VARCHAR(50),
		@IMB_TIPO=@clave,--			   VARCHAR(1500),
		@IMB_PROVINCIA='Guayas',--		   VARCHAR(300),
		@IMB_UBICACION='Guayaquil',--		   VARCHAR(300),
		@IMB_VALOR_LIBROS=288962.72,--	   FLOAT = NULL	,
		@IMB_VALOR_AVALUO=null,--	   FLOAT = NULL,
		@IMB_FECHA_ULT_AVALUO=null,--  DATETIME = NULL,
		@IMB_FECHA_ESCRITURA=null,--   DATETIME = NULL,
		@IMB_CUENTA_CONTABLE='150101002',--   VARCHAR(100),
		@IMB_FORMA_ADQUISICION='Dación en pago',-- VARCHAR(1500),
		@i_lga_id=null
go
update imb set imb_tipo='Centro Biblico el Pacto-Programa S.S.',imb_valor_libros=3754175.67,imb_cuenta_contable='7180101001'
from bvq_backoffice.activos_inmobiliarios imb
where imb_tipo like 'Centro Biblico%el Pacto-Programa S.S.'


--sp_helptext 'bvq_backoffice.[tfObtenerActivosInmobiliariosISSPOL]'
--select * from sicavtestbatch.bvq_backoffice.ACTIVOS_INMOBILIARIOS