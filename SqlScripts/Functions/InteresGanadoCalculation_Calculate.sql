alter function dbo.InteresGanadoCalculation_Calculate(
	@parDate datetime, @latest_inicio datetime, @tvl_descripcion varchar(255)
	, @tiv_tipo_base int, @interes_diario float, @interes_ganado_orig float
)
returns table as return
	with dias as (
		select dias_nasd=
			case when
				(
					case when @tvl_descripcion='PAPEL COMERCIAL' and @parDate>='20251231' then
						@tiv_tipo_base
					else 354 end
				) = 354
			then
				dbo.Days360Nasd(@latest_inicio, @parDate)
			else
				datediff(d,@latest_inicio,@parDate)
			end
	) select interes_ganado=
		case when month(@latest_inicio)=2 and day(@latest_inicio) in (28,29)
			and month(@parDate)=2 and day(@parDate) in (28,29)
			and year(@parDate)=year(@latest_inicio)
		then
			0
		when @latest_inicio<>0 and @interes_diario is not null then
			@interes_diario * dias_nasd
		else
			@interes_ganado_orig
		end
	from dias