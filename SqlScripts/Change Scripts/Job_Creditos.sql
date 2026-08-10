USE msdb;
GO


-- =============================================
-- CONFIGURACIÓN
-- =============================================
DECLARE @dbName NVARCHAR(128) = N'SicavStage'; -- << cambiar aqui el nombre de la DB
-- =============================================

-- 1. Crear el Job
EXEC msdb.dbo.sp_add_job
    @job_name = N'Job_Creditos';

-- 2. Agregar el paso que ejecuta el comando
DECLARE @recargarCartera NVARCHAR(MAX) = N'exec bvq_backoffice.CargaCreditosCarteraISSPOL2 null';
DECLARE @recargarCuotas NVARCHAR(MAX) = N'bvq_backoffice.RecargarCarteraCuotaISSPOL';

EXEC msdb.dbo.sp_add_jobstep
    @job_name          = N'Job_Creditos',
    @step_name         = N'Ejecutar RecargarCreditosCarteraISSPOL',
    @subsystem         = N'TSQL',
    @command           = @recargarCartera,
    @database_name     = @dbName,
    @on_success_action = 3,
    @on_fail_action    = 2;


EXEC msdb.dbo.sp_add_jobstep
    @job_name          = N'Job_Creditos',
    @step_name         = N'Ejecutar RecargarCarteraCuotaISSPOL',
    @subsystem         = N'TSQL',
    @command           = @recargarCuotas,
    @database_name     = @dbName,
    @on_success_action = 1,
    @on_fail_action    = 2;

-- 3. Crear el schedule: todos los días a las 3am
if not exists(
    SELECT *
    FROM msdb.dbo.sysschedules
    WHERE name = 'Creditos'
)
    EXEC msdb.dbo.sp_add_schedule
        @schedule_name     = N'Creditos',
        @freq_type         = 4,
        @freq_interval     = 1,
        @active_start_time = 30000;

-- 4. Vincular el schedule al Job
EXEC msdb.dbo.sp_attach_schedule
    @job_name      = N'Job_Creditos',
    @schedule_name = N'Creditos';

-- 5. Registrar el Job en el servidor local
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Job_Creditos';