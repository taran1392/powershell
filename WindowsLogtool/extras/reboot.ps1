function get-RebootHistory($server,$session,$cred){

$getEventInput = StackPanel -ControlName 'Get-EventLogsSinceDate' {            
    New-Label -VisualStyle 'MediumText' "Get Reboot Logs Since..."            
    Select-Date -Name After            
    New-Button "Get Events" -On_Click {            
        Get-ParentControl |            
            Set-UIValue -passThru |             
            Close-Control            
    }            
} -show            
            
#Get-EventLog @getEventInput 


$after=$getEventInput.after
$logname="system"
$1ogs=@()
$again=$true


#$logs+=Get-EventLog -After $after -LogName $logname -Newest 20
$index=1

$after
$before=$null
$rebootLogs_block={
param($after)
get-EventLog -LogName System -After $after -Before $after.addDays(7) |?{$_.EventID -eq 1074 -or $_.EventID -eq 6008 -or $_.EventID -eq 6009 }
}


$max=30
while($again){


Clear-Host
   
   Write-Host "Reboot history Logs for server:  from $after to $($after.adddays(7)) "
#    $logs|sort -Property index |select -Last $max  index,timegenerated,entrytype,message  |ft -AutoSize
    if($session){
        $logs=Invoke-Command -ScriptBlock $rebootLogs_block -ArgumentList $after -Session $session
    }else
    {
        $logs=Invoke-Command -ScriptBlock $rebootLogs_block -ArgumentList $after -Credential $cred
    }
    $logs|sort -Property index|select TimeGenerated,@{n="shut dwon Type";e={$_.ReplacementStrings[4]}},@{n="Reason";e={$_.ReplacementStrings[2]}},@{n="User";e={$_.ReplacementStrings[6]}},@{n="Process";e={$_.ReplacementStrings[0]}}|ft -AutoSize


    $c= Read-Host “Please enter V for(previous page) and N (for Next Page)”
    
    switch($c){
        ‘V’ {
                #    $after= ($logs|select -Last 40|select -First 1).timegenerated

                $after=$after.adddays(-7)
          
            break;
            }
         'N'{       
                $after=$after.adddays(7)
                    break
                }
        default    {
            $again =$false
    }
    }

}}