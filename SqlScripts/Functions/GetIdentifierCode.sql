alter function bvq_administracion.GetIdentifierCode(@i_tiv_codigo_vector varchar(50),@i_tiv_codigo_isin varchar(20)) returns char(2) as
begin
	return case when @i_tiv_codigo_vector<>'' then '07'
	when @i_tiv_codigo_isin<>'' then '01'
	else '00'
	end
end
