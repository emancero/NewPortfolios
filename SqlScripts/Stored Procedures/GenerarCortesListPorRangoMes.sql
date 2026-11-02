CREATE procedure GenerarCortesListPorRangoMes
--declare
	  @i_fechaIni datetime='20250131'
	, @fecha datetime='20251130'
as
	delete from corteslist
	;with a as(
		select dateadd(d,0,@i_fechaIni) i, num=1
		union all select dateadd(m,1,a.i),num+1 from a where dateadd(m,1,a.i)<@fecha
	)
	insert into corteslist(c,cortenum)
	select dateadd(s,86399,convert(datetime,eomonth(i))),num from a
	option(maxrecursion 0)
