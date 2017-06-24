function writeToDB($logs){

#max no. of insertions in a single query
$maxInsterions=800    #max value can be 1024 , but please keep it 900 at max.otherwise insertion might fail due to timeout error


       
$Server="nfis6m61ls.database.windows.net"
$DB="PowerBILogs"
$dbUser="auditadmin"
$pswd="h0aLDCLj"


$connectionString = “Server=$server;uid=$dbuser; pwd=$pswd;Database=$DB;Integrated Security=False;”

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

$connection.Open()

if($connection.State -like "*closed*" ){

Write-Output "Unable to connect to DB.Please try again after sometime"
return

}

$table="o365AuditLogs"
$stagingtable="o365AuditLogsStagingTable2"

#delete old logs from staging table

$command = $connection.CreateCommand()
$command.CommandText="delete from $stagingtable"
$s=$command.ExecuteNonQuery()

$phash=@{}
$max=$maxInsterions

#insert logs into staging table
$i=0

$count=0

for($i=0;$i -lt $logs.count;){

Write-Progress -Activity "Inserting records to db Staging Table" -PercentComplete $($i*100/$logs.count)
        
        $command = $connection.CreateCommand()


        

        


$query="insert into $stagingtable values "

$sqlvalid=$false

$in=0

#while($in -lt $max -and $index -lt $logs.count ){

$total=0
$logs|select -Skip $i -First $max|ForEach-Object {
$total++

$k="$($_.tenant)_$($_.logid)"
 #$cdate=$("{0:yyyy}-{0:MM}-{0:dd} {0:HH}:{0:mm}:{0:ss} " -f $_.creationdate)
        $sqlvalid=$true

        $auditdata=$_.auditdata
        $auditdata=$auditdata.replace("'","''")
        $v=@"
            ('{0}','{1}','{2}','{3}','{4}',N'{5}','{6}'),
"@ -f $_.tenant,$_.creationDate,$_.recordtype,$_.userids,$_.operations,$auditdata,$_.logid
        $query+=$v
        $in++
   

}

Write-Host "read $in  index $i" -ForegroundColor Green





    $command.CommandText=$query.Substring(0,$query.Length-1)

try{

    $c=$command.ExecuteNonQuery()
    $i+=$c
    Write-Host "written $c" -ForegroundColor Blue
    $count+=$c
    Write-Host "MAX $max" -ForegroundColor Yellow
    $max*=2 
    

    if($max -ge $maxInsterions){
        $max=$maxInsterions
    }
   }catch{


        $_
        $query
    
        if($max -eq 1){
        $i++
        }
        $max=$max/2


        if($connection.State -like "*closed*"){
        
         Write-Output "DB connection got closed or treminated."
         Write-Host "Trying to Open the connection again"

            try{
            
            $connection.Open()
            }catch{
            
            Write-Host "Failed to open connection again. PLease try again after sometime"

            return
            }


        }
    
    }
    


}






#$command.CommandText






    $command = $connection.CreateCommand()
    $command.commandTimeout=100;
    $command.CommandText = @" 
    insert into $table select * from $stagingtable as B Where not exists (select * from $table where logid=B.logid and tenant=B.tenant)
"@
    $countr=0
    try{
    #$command.CommandText
        $countr=$command.ExecuteNonQuery()
        }catch {

        Write-Host $_
        }


Write-Host "$countr new records have been added to DB"
$connection.close()



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



<#$query = “SELECT * FROM Person”

$command = $connection.CreateCommand()
$command.CommandText = $query

$result = $command.ExecuteReader()


$tablesh = new-object “System.Data.DataTable”
$table.Load($result)#>