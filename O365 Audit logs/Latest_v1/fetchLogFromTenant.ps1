
#script to fetch powerbi auditlogs

#param([String]$tenantName)

#$PSScriptRoot


$global:script_path=Split-Path $MyInvocation.InvocationName -Parent
    $global:passwordFile="$script_path\passwords.txt"

    ."$Script_path\html.ps1"
    ."$Script_path\db.ps1"


 $fetch_logs_scriptblock={
  param($user,$password,$tenant)
        $command_script_block={
            param($startdate,$enddate,$resultsize,$sessionid)
            
        
            Search-UnifiedAuditLog -EndDate $enddate  -RecordType powerbi -StartDate $startdate -ResultSize $resultsize -SessionId $sessionid  
           
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
$startdate= $enddate.AddDays(-30)


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
  
  }
    

    $tenantName=Read-Host "Enter the name of tenant"



  $tenant=  Import-Csv $passwordFile|Where-Object { $_.tenant -like "*$tenantName*"}

  if($tenant){
  
  #tenant found in the file
    try { 

    Write-Output "Fetching Logs.."
    $logs=Invoke-Command -ScriptBlock $fetch_logs_scriptblock -ArgumentList $tenant.username,$tenant.password,$tenant.tenant
    $logs= $logs|Select-Object @{n="Tenant";e={$($tenant.tenant)}},recordtype,creationdate,userids,operations,auditdata,@{n="logID";e={$(($_.auditdata|convertfrom-json ).id)}}
                #$logs|ft
    #$logs|Out-GridView


    #export-html
     #getHTML -logs $($logs|select RecordType,CreationDate,UserIds,Operations,AuditData)|Out-File "$script_path\$tenantname.html"
     
     #export logs to db   
      writeToDB -logs $logs


    }catch{
    
        Write-Output "failed to get Logs from tenant $tenant"
        $_
    }



  }else{
  
    #tenant not found exiting now
  Write-Output "tenant not found"
  
  }