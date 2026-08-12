create view bvq_backoffice.EstructuraIsspolErrors as
	select codigo, mensaje from(
	VALUES
		('G04_RF_DIAS_TRANS_MAYOR_CERO', 'Cuando es renta fija y la Fecha de compra G02 no es igual a la fecha de corte, los días transcurridos deben ser mayores a cero'),
		('G04_RV_YIELD_NULO', 'Cuando es renta variable, el valor de YIELD debe ser nulo'),
		('G04_FECHA_ULT_CUPON_IGUAL_CORTE', 'La Fecha de pago último cupón debe ser igual a la fecha de corte'),
		('G04_NUM_LIQ_BLANCO_TX_AVRU', 'El Número de liquidación debe venir en blanco si el tipo de transacción es A, V, R o U'),
		('G04_TIPO_INST_20_21_22_24_MAYOR_CERO', 'Si el Tipo de Instrumento es 20, 21, 22 o 24, el campo debe ser mayor a cero; caso contrario debe ser nulo'),
		('G04_TX_VAUP_VALOR_CAPITAL_CERO', 'Si el tipo de transacción es V, A, U o P, el Valor de capital debe ser cero'),
		('G04_TX_VLERUA_FECHA_ULT_CUPON_NULA', 'Si el tipo de transacción es V, L, E, R, U o A, la Fecha pago último cupón debe ser nula'),
		('G04_TX_LPRUAE_INTERES_ACUM_CERO', 'Si el tipo de transacción es L, P, R, U, A o E, el Interés acumulado debe ser cero'),
		('G04_TX_V_RF_EXC_4_5_8_9_INTERES_CERO', 'Si el tipo de transacción es V y el tipo de instrumento es renta fija, excepto códigos 4, 5, 8 y 9, el interés debe ser cero'),
		('G04_VALOR_MERCADO_MENOS_ACCION_GTE_NOMINAL_G02', 'Valor de mercado menos Valor de acción debe ser mayor o igual al Valor nominal de la estructura G02')
	) v(codigo,mensaje)