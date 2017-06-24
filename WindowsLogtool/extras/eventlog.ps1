function get-Logs($server,$session,$cred){

$getEventInput = StackPanel -ControlName 'Get-EventLogsSinceDate' {            
    New-Label -VisualStyle 'MediumText' "Get Event Logs Since..."            
    New-ComboBox -IsEditable:$false -SelectedIndex 0 -Name LogName @("Application", "Security", "System", "Setup")            
    Select-Date -Name After            
    New-Button "Get Events" -On_Click {            
        Get-ParentControl |            
            Set-UIValue -passThru |             
            Close-Control            
    }            
} -show            
            
#Get-EventLog @getEventInput 


$after=$getEventInput.after
$logname=$getEventInput.LogName
$1ogs=@()
$again=$true

#$server='whn121aa388609'

$fetch_logs_block={

param($logname,$after,$before, $max)
if($after -ne $null){
        $logs=get-EventLog -LogName $logname -After $after |select -last $max

        }
        if($before -ne $null)
        {
        $logs=get-EventLog -LogName $logname -Before $before |select -First $max
            
        }


$logs

}



$index=1

$after
$before=$null

$max=30
while($again){

      

Clear-Host
   
   Write-Host "fetching logs.."
   if($session){
   $logs=Invoke-Command -ScriptBlock $fetch_logs_block -ArgumentList $logname,$after,$before,$max -Session $session
  }else{
  
   $logs=Invoke-Command -ScriptBlock $fetch_logs_block -ArgumentList $logname,$after,$before,$max -Credential $cred
  
  
  }
  
   Write-Host "$logname  Logs for server :$server "
    $logs|sort -Property index |select -Last $max  index,timegenerated,entrytype,message  |ft -AutoSize



    $c= Read-Host “Please enter V for(previous page) and N (for Next Page)”
    
    switch($c){
        ‘V’ {
                #    $after= ($logs|select -Last 40|select -First 1).timegenerated
                           if($logs.count -eq $max){
                            $before=($logs|Measure-Object -Property timegenerated -Minimum).Minimum
                            $after=$null}else{
                            
                                $after=($logs|Measure-Object -Property timegenerated -Maximum).maximum
                                           
                            }
          
            break;
            }
         'N'{       
                if($logs.count -eq $max){
                           
                 $after=($logs|Measure-Object -Property timegenerated -Maximum).maximum
                            $before=$null
                    }else{
                    
                            $before=($logs|Measure-Object -Property timegenerated -Minimum).Minimum
                    
                    
                    }
                    break
                }
        default    {
            $again =$false
    }
    }

}




}