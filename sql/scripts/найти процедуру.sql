
--4й верный способ
SELECT 
    j.name AS job_name,
    js.step_name,
    js.command
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobsteps js ON j.job_id = js.job_id
WHERE js.command LIKE '%СписокЗадач%';


