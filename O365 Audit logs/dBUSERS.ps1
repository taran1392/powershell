function writeToDB($users){

#max no. of insertions in a single query
$maxInsterions=800    #max value can be 1024 , but please keep it 900 at max.otherwise insertion might fail due to timeout error


       
$Server="nfis6m61ls.database.windows.net"
$DB="PBIUsers"
$dbUser="PBImaster"
$pswd="6gCmQEwcRp6nS2my"


$connectionString = “Server=$server;uid=$dbuser; pwd=$pswd;Database=$DB;Integrated Security=False;”

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

$connection.Open()

if($connection.State -like "*closed*" ){

Write-Output "Unable to connect to DB.Please try again after sometime"
return

}

$table="o365Users"
$stagingtable="o365UsersStagingTable"



$command = $connection.CreateCommand()
$command.CommandText="delete from $stagingtable"
$s=$command.ExecuteNonQuery()

$today="{0:MM}/{0:dd}/{0:yyyy} {0:HH}:{0:mm}" -f $(get-date)

$command = $connection.CreateCommand()
$command.CommandText="update $table set deleted='$today' where deleted=NULL"

$command.CommandText
$s=$command.ExecuteNonQuery()


$phash=@{}
$max=$maxInsterions

#insert logs into staging table
$i=0

$count=0

for($i=0;$i -lt $users.count;){

Write-Progress -Activity "Inserting records to db Staging Table" -PercentComplete $($i*100/$users.count)
        
        $command = $connection.CreateCommand()


        

        


$query="insert into $stagingtable values "

$sqlvalid=$false

$in=0

#while($in -lt $max -and $index -lt $logs.count ){

$total=0
$users|select -Skip $i -First $max|ForEach-Object {
$total++

$k="$($_.tenant)_$($_.logid)"
 #$cdate=$("{0:yyyy}-{0:MM}-{0:dd} {0:HH}:{0:mm}:{0:ss} " -f $_.creationdate)
        $sqlvalid=$true

        $v=@"
            ('{0}','{1}','{2}','{3}','{4}','{5}','{6}'),
"@ -f "office",$_.whencreated,$_.licenses,$_.userprincipalname,'','',''
        $query+=$v
        $in++
   

}

Write-Host "read $in  index $i" -ForegroundColor Green



#Write-Host $query

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
    $command.commandTimeout=120;
    $command.CommandText = @" 
merge $table as T 
using (select distinct * from $stagingtable) as S
On (T.office=S.office and T.userprincipalname=S.userprincipalname)
        when matched then
                update set T.updated='{0}',T.deleted=NULL,T.licenses=S.licenses
        when not matched then 
                insert(office,WhenCreated,licenses,userprincipalname,created) values (S.office,S.whencreated,S.licenses,S.userprincipalname,'{0}');
    
"@ -f $today


#$command.CommandText
    $countr=0
    try{
    #$command.CommandText
        $countr=$command.ExecuteNonQuery()
        }catch {

        Write-Host $_
        }


Write-Host "$countr new records have been added\updated to DB"
$connection.close()



}





$query = @“
Create table o365Users(

office varchar(255),
WhenCreated datetime,
licenses varchar(255),
userprincipalname varchar(255),
updated datetime,
created datetime,
deleted datetime

PRIMARY KEY(office,userprincipalname)



)

"@



<#$query = “SELECT * FROM Person”

$command = $connection.CreateCommand()
$command.CommandText = $query

$result = $command.ExecuteReader()


$tablesh = new-object “System.Data.DataTable”
$table.Load($result)#>


