create view BVQ_BACKOFFICE.ISSPOL_PROGS AS
		select 'pagos' IPR_NOMBRE_PROG,1 IPR_ES_CXC,8 IPR_SCRIPT_ORD union
		select 'toInsert',1,4 union
		select 'rv',0,2 union
		select 'rfMinDist',0,1 union
		select 'cxc22ins',1,5 union
		select 'cxc12ins',1,6 union
		select 'pagares',1,9 union
		select 'oblSums',1,3 union
		select 'cxcNoMovs',1,7 union
		select 'normal',1,10
