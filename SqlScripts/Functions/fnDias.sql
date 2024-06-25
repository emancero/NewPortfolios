create function dbo.fnDias(@StartDate DateTime, @EndDate DateTime, @base int) returns float as
begin
	declare @StartDay int=day(@StartDate)
	if @base=354 and datediff(d,@StartDate,EOMONTH(@StartDate))=0
	begin
		if @StartDay>30
			set @StartDate=dateadd(d,30-day(@StartDate),@StartDate)
		set @StartDay=30
	end
	if @base=354 and datediff(d,@EndDate,EOMONTH(@EndDate))=0
		if day(@StartDate)<30
			set @EndDate=dateadd(d,1,EOMONTH(@EndDate))
		else
			set @EndDate=dateadd(d,30-day(@EndDate),@EndDate)

	return
	case
	when @base=354 then
		datediff(m,@StartDate,@EndDate)*30
		+ case when 1=0 and day(@endDate)=31 then 30 else day(@endDate) end
		- case when 1=0 and day(@startDate)=31 then 30 else @StartDay end
	when @base in (355,356) THEN
		datediff(d,@StartDate,@EndDate)
	end
end