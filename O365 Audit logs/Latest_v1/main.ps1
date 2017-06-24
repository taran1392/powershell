




#Set-ExecutionPolicy RemoteSigned
$global:script_path=Split-Path $MyInvocation.InvocationName -Parent
    $global:file="$script_path\passwords.txt"
    
    $f_name="logs_{0:dd}.{0:MM}.{0:yyyy}_{0:hh}{0:mm}.txt" -f (get-date)
    $log_file="$script_path\$f_name"


    ."$Script_path\db.ps1"
    ."$Script_path\html.ps1"
    $global:passwords=@()
  

  function createLog(){
  $obj=New-Object System.object

 $obj= $obj|select Tenant,Status,LogCount,Error
  
  return $obj
  }

  $fetch_logs_scriptblock={
  param($user,$password,$tenant)
  
        $command_script_block={
            param($startdate,$enddate,$resultsize,$sessionid)
           $resultsize=1000
            $logs=@()
            $hasNext=$true
            $sessionid="fetchBILogs"
            do{
    
               $hasNext= Search-UnifiedAuditLog -EndDate $enddate  -RecordType powerbi -StartDate $startdate -SessionId $sessionid -ResultSize $resultsize -SessionCommand ReturnNextPreviewPage
                $logs+=$hasNext
        }while($hasNext)

        $logs     
        }
TRY{

  Import-Module msonline

    $secpasswd = ConvertTo-SecureString $password
    $mycreds = New-Object System.Management.Automation.PSCredential ($user, $secpasswd)
   # Write-Host "connecting..."
    #$mycreds.GetNetworkCredential().UserName
    #$mycreds.GetNetworkCredential().Password
    Connect-MsolService -Credential $mycreds 

    #write-host "connecting to exchange..."
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell-liveid/ -Credential $mycreds -Authentication Basic -AllowRedirection
    #Import-PSSession $Session -AllowClobber


$enddate= (Get-Date)
$startdate= $enddate.AddDays(-15)


#write-host "fetching Power BI audit logs...." -ForegroundColor Yellow
$resultsize=1000
            $hasNext=$true
            $sessionId="fecthPowerBILogs"
            $logs=@()
            while($hasNext){
        $hasNext=Invoke-Command -ScriptBlock $command_script_block -ArgumentList $startdate,$enddate,$resultsize,$sessionid -Session $Session
$logs+=$hasNext
}
 $LOGS 
  
  Get-PSSession|Remove-PSSession
  
  }catch{
  $error[0].Exception
    Write-Error -Message $_
  
  }
  
  
  
  
  
  } #SCRIPTBLOCK ENDS
  
    function verify-file(){
    
        Write-Host "Verifying Password file.." -ForegroundColor Yellow

        if(-not (Test-Path $global:file)){
            Write-Host "failed to fnd the password file... $file"
            exit
        
        }else{
        
            Write-Host "File verified.." -ForegroundColor Green
            Write-Host "reading file contents.." -ForegroundColor Green

            $global:passwords=@()
            Import-Csv $global:file|ForEach-Object{
            $global:passwords+=$_
             
         }
    
        }
    
    
    } #verify function ends


    verify-file
    $jobs=@()
    Write-Host "There is\are $($passwords.count) tenant(s) "
    Write-Host "starting jobs"
    $passwords|ForEach-Object{
    
    
        $j= Start-Job -ScriptBlock $fetch_logs_scriptblock -ArgumentList $_.username,$_.password,$_.tenant -Name $_.tenant
    
        $jobs+=$j    
    
    
    
    }
    Write-Host "$($jobs.count) Jobs have been created"
    Write-Host "waiting for jobs to finish "
    
    $jobs|Wait-Job|Out-Null

    
    
    $powerbi_logs=@()
    $script_logs=@()

    $jobs|ForEach-Object{
        $name=$_.name
        $j=$_
        $slog=createLog
       $slog.tenant=$name
       $slog.status=""

                   if($_.State -eq "completed" -and ($_.ChildJobs[0].Error.Count -eq 0)){
                $logs=$_|Receive-Job 
                Write-Host "`n $($logs.count) Log entries for tenant $($_.name)" -ForegroundColor Green
                
                $slog.logCount=$($logs.count)
                $slog.status="success"
             $powerbi_logs+= $logs|Select-Object @{n="Tenant";e={$name}},recordtype,creationdate,userids,operations,auditdata,@{n="logID";e={$(($_.auditdata|convertfrom-json ).id)}}
                #$logs|ft
                 
            }else{
                 $slog.status="failed"
                Write-Host "failed to get logs from tenant $name `n Following errors occurred .." -ForegroundColor Red
                $j.ChildJobs[0].Error
                $slog.logCount=-1
                 $j.ChildJobs[0].Error|ForEach-Object {

                    $slog.error+="$_.exception`n"
            }
    
     
    }

    $script_logs+=$slog
    }

        $powerbi_logs|Export-Csv $log_file -NoTypeInformation
    

    Writetodb $powerbi_logs

    getHTML -logs $script_logs |Out-File "$script_path\logs.html"

    Write-Host "Logs have been exported to  $log_file"
    Write-Host "HTML log file have been exported to  $script_path\logs.html"


