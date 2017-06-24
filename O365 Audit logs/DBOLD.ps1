function writeToDB($logs){


$Server="nfis6m61ls.database.windows.net"
 $DB="PowerBILogs"
  $dbUser="auditadmin"
  $pswd="h0aLDCLj"


$connectionString = “Server=$server;uid=$dbuser; pwd=$pswd;Database=$DB;Integrated Security=False;”

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

$connection.Open()


$table="o365AuditLogs"
$stagingtable="o365AuditLogsStagingTable"

#delete old logs from staging table

$command = $connection.CreateCommand()
$command.CommandText="delete from $stagingtable"
$s=$command.ExecuteNonQuery()


#insert logs into staging table
$i=0
$logs|ForEach-Object{

Write-Progress -Activity "Inserting records to db" -PercentComplete $($i*100/$logs.count)
        
        $command = $connection.CreateCommand()


        $cdate="{0:yyyy}-{0:MM}-{0:dd} {0:HH}:{0:mm}:{0:ss} " -f $_.creationdate

        $command.CommandText = @" 
        insert into $stagingtable
         values('{0}','{1}','{2}','{3}','{4}','{5}','{6}') 
"@ -f $_.tenant,$_.cdate,$_.recordtype,$_.userids,$_.operations,$_.auditdata,$_.logid



#$command.CommandText

$c=$command.ExecuteNonQuery()
$i++
}



$query = @“
Create table o365AuditLogsStagingTable (

tenant varchar(255),
createdOn datetime,
recordtype varchar(255),
userId varchar(255),
operation varchar(1000),
auditdata varchar(max),
logID varchar(1000),

PRIMARY KEY(tenant,logID)



)




#merge
"@

$command = $connection.CreateCommand()
$command.CommandText = @" 
insert into $table select * from $stagingtable as B where not exists (select * from $table where logid=B.logid and tenant=B.tenant)
"@

#$command.CommandText
$l=$command.ExecuteNonQuery()



Write-Host "$l new records have been added or updated to DB"
$connection.close()
}






<#$query = “SELECT * FROM Person”

$command = $connection.CreateCommand()
$command.CommandText = $query

$result = $command.ExecuteReader()


$table = new-object “System.Data.DataTable”
$table.Load($result)#>