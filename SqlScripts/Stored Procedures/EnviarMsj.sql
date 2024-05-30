create procedure bvq_administracion.enviarMsj(@i_cola_id int, @i_inst_tipo varchar(500), @i_inst_id int=null, @i_seq int=null,@i_obj varchar(500)) as
begin
	insert into bvq_administracion.msj(cola_id, inst_tipo, inst_id, seq, obj_id)
	values(@i_cola_id, @i_inst_tipo,@i_inst_id,@i_seq,object_id(@i_obj))
end