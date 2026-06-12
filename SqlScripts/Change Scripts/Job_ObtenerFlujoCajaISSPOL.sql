USE msdb;
GO

-- =============================================
-- CONFIGURACIÓN
-- =============================================
DECLARE @dbName NVARCHAR(128) = N'SicavStage'; -- << cambiar aqui el nombre de la DB
-- =============================================

-- 1. Crear el Job
EXEC msdb.dbo.sp_add_job
    @job_name = N'Job_ObtenerFlujoCajaISSPOL';

-- 2. Agregar el paso que ejecuta el SP
DECLARE @cmd NVARCHAR(500) = N'EXEC [BVQ_BACKOFFICE].[ObtenerFlujoCajaISSPOL]
                                    @i_fechaFin = CAST(GETDATE() AS DATE),
                                    @i_lga_id   = NULL;';

EXEC msdb.dbo.sp_add_jobstep
    @job_name          = N'Job_ObtenerFlujoCajaISSPOL',
    @step_name         = N'Ejecutar ObtenerFlujoCajaISSPOL',
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
    @job_name      = N'Job_ObtenerFlujoCajaISSPOL',
    @schedule_name = N'Diario_3AM';

-- 5. Registrar el Job en el servidor local
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Job_ObtenerFlujoCajaISSPOL';
