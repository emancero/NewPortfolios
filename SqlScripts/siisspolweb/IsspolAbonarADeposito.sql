CREATE procedure BVQ_BACKOFFICE.IsspolAbonarADeposito @LM_TOTAL money, @AS_USUARIO varchar(50), @AS_EQUIPO varchar(50), @AI_ID_MASIVA_TRANSACCION int as
begin
	UPDATE [siisspolweb].siisspolweb.banco.masivas_transaccion SET
	 saldo=isnull(saldo,valor)-@LM_TOTAL
	,valor_abonado=isnull(valor_abonado,0)+@LM_TOTAL
	,pagado=(CASE WHEN valor-@LM_TOTAL<=0 THEN 1 ELSE 0 END)
	,fecha_pago=GETDATE()
	,observacion='DEPOSITO POR IDENTIFICAR'
	,modifica_usuario=@AS_USUARIO,modifica_fecha=GETDATE(),modifica_equipo=@AS_EQUIPO
	WHERE id_masivas_transaccion=@AI_ID_MASIVA_TRANSACCION and isnull(pagado,0)=0
end