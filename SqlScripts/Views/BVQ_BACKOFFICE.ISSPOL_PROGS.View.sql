create view BVQ_BACKOFFICE.ISSPOL_PROGS AS
		select 'pagos' IPR_NOMBRE_PROG,1 IPR_ES_CXC union
		select 'toInsert',1 union
		select 'rv',0 union
		select 'rfMinDist',0 union
		select 'cxc22ins',1 union
		select 'cxc12ins',1 union
		select 'pagares',1 union
		select 'oblSums',1 union
		select 'cxcNoMovs',1