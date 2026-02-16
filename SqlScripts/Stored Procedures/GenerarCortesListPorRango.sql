create procedure GenerarCortesListPorRango
	  @i_fechaIni datetime
	, @fecha datetime
as
	delete from corteslist
	;with a as(select @i_fechaIni i, num=1 union all select dateadd(d,1,a.i),num+1 from a where a.i<@fecha)
	insert into corteslist(c,cortenum)
	select i,num from a
	option(maxrecursion 0)
