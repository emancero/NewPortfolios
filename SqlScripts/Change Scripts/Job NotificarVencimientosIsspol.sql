USE msdb;
GO

DECLARE @dbName NVARCHAR(128) = N'SicavStage';
DECLARE @JobId BINARY(16);
DECLARE @JobName SYSNAME = N'Job_NotificarVencimientosISSPOL';

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = @JobName)
    EXEC msdb.dbo.sp_delete_job @job_name = @JobName;

EXEC msdb.dbo.sp_add_job
    @job_name = @JobName,
    @enabled = 1,
    @description = N'Envía notificación diaria por correo de vencimientos de títulos (ISSPOL).',
    @job_id = @JobId OUTPUT;

EXEC msdb.dbo.sp_add_jobstep
    @job_id = @JobId,
    @step_id = 1,
    @step_name = N'Ejecutar NotificarVencimientosIsspol',
    @subsystem = N'TSQL',
    @database_name = @dbName,
    @command = N'EXEC bvq_backoffice.NotificarVencimientosIsspol @FechaIni = GETDATE(), @FechaFin = GETDATE();',
    @on_success_action = 1,  -- Quit the job reporting success
    @on_fail_action = 2,  -- Quit the job reporting failure
    @retry_attempts = 0;

EXEC msdb.dbo.sp_add_jobschedule
    @job_id = @JobId,
    @name = N'Diario_08am',
    @freq_type = 4,       -- diario
    @freq_interval = 1,       -- cada 1 día
    @freq_subday_type = 1,       -- una sola vez al día
    @active_start_time = 080000;  -- 08:00:00

EXEC msdb.dbo.sp_add_jobserver
    @job_name =@JobName;
GO
