USE msdb;
GO

-- =============================================
-- CONFIGURACIÓN
-- =============================================
DECLARE @dbName NVARCHAR(128) = N'SicavStage'; -- << cambiar aqui el nombre de la DB
-- =============================================

-- 1. Crear el Job
EXEC msdb.dbo.sp_add_job
    @job_name = N'Job_RecargarCarteraCuotaISSPOL';

-- 2. Agregar el paso que ejecuta el comando
DECLARE @cmd NVARCHAR(MAX) = N'bvq_backoffice.RecargarCarteraCuotaISSPOL';

EXEC msdb.dbo.sp_add_jobstep
    @job_name          = N'Job_RecargarCarteraCuotaISSPOL',
    @step_name         = N'Ejecutar RecargarCreditosCarteraISSPOL',
    @subsystem         = N'TSQL',
    @command           = N'exec bvq_backoffice.CargaCreditosCarteraISSPOL2 null',
    @database_name     = @dbName,
    @on_success_action = 1,
    @on_fail_action    = 2;


EXEC msdb.dbo.sp_add_jobstep
    @job_name          = N'Job_RecargarCarteraCuotaISSPOL',
    @step_name         = N'Ejecutar RecargarCarteraCuotaISSPOL',
    @subsystem         = N'TSQL',
    @command           = @cmd,
    @database_name     = @dbName,
    @on_success_action = 1,
    @on_fail_action    = 2;

-- 3. Crear el schedule: todos los días a las 3am
EXEC msdb.dbo.sp_add_schedule
    @schedule_name     = N'Diario_3AM',
    @freq_type         = 4,
    @freq_interval     = 1,
    @active_start_time = 30000;

-- 4. Vincular el schedule al Job
EXEC msdb.dbo.sp_attach_schedule
    @job_name      = N'Job_RecargarCarteraCuotaISSPOL',
    @schedule_name = N'Diario_3AM';

-- 5. Registrar el Job en el servidor local
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Job_RecargarCarteraCuotaISSPOL';