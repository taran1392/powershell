$Server="LHNR90c1hax"
$DB="Master"
$dbUser="Taran"
$pswd="Adecco"


$connectionString = “Server=$server;uid=$dbuser; pwd=$pswd;Database=$DB;Integrated Security=False;”

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

$connection.Open()
$command = $connection.CreateCommand()


$command.commandtext=@"
DECLARE @ts BIGINT;
                    DECLARE @lastNmin TINYINT;
SET @lastNmin = 10;
SELECT @ts =(SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info); 
SELECT TOP(@lastNmin)
SQLProcessUtilization AS [SQLServer_CPU_Utilization], 
SystemIdle AS [System_Idle_Process], 
100 - SystemIdle - SQLProcessUtilization AS [Other_Process_CPU_Utilization], 
DATEADD(ms,-1 *(@ts - [timestamp]),GETDATE())AS [Event_Time] 
FROM (SELECT record.value('(./Record/@id)[1]','int')AS record_id, 
record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]','int')AS [SystemIdle], 
record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]','int')AS [SQLProcessUtilization], 
[timestamp]      
FROM (SELECT[timestamp], convert(xml, record) AS [record]             
FROM sys.dm_os_ring_buffers             
WHERE ring_buffer_type =N'RING_BUFFER_SCHEDULER_MONITOR'AND record LIKE'%%')AS x )AS y 
ORDER BY record_id DESC;  
"@

$r=$command.ExecuteReader()

$tablesh = new-object “System.Data.DataTable”
$tablesh.Load($r)


$connection.Close()



$Server="LHNR90c1hax"
$DB="PerfDb"
$dbUser="Taran"
$pswd="Adecco"

$table="Perf_CPU"

$connectionString = “Server=$server;uid=$dbuser; pwd=$pswd;Database=$DB;Integrated Security=False;”

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

$connection.Open()
$command = $connection.CreateCommand()



$tablesh.Rows|ForEach-Object{

$cdate=$("{0:yyyy}-{0:MM}-{0:dd} {0:HH}:{0:mm}:{0:ss} " -f $_.event_time)
  

$command.CommandText="insert into $table values('{0}','{1}','{2}','{3}','{4}')" -f $server,$_.SQLServer_CPU_Utilization,$_.System_Idle_Process,$_.Other_Process_CPU_Utilization,$cdate


$command.CommandText

$command.ExecuteNonQuery()

}



$connection.Close()

