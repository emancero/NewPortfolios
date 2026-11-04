if object_id('bvq_backoffice.log_ultimo_vencimiento_pagado_evp_def') is null
	create table bvq_backoffice.log_ultimo_vencimiento_pagado_evp_def(fecha datetime, htp_id int, i_lga_id int, fecha_actualizacion datetime default (getdate()));
if object_id('bvq_backoffice.log_ultimo_vencimiento_pagado_def') is null
	create table bvq_backoffice.log_ultimo_vencimiento_pagado_def(def_id int, fecha datetime ,i_lga_id int, fecha_actualizacion datetime default (getdate()));
