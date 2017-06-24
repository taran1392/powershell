function get-patchlogs($server,$session,$cred){

$getEventInput = StackPanel -ControlName 'Get-EventLogsSinceDate' {            
    New-Label -VisualStyle 'MediumText' "Get Patch Logs Since..."            
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
$Logs_block={
param($after)

Get-HotFix |?{$_.InstalledOn -ge $after -and $_.InstalledOn -lt $after.addDays(7)}


}


$max=30
while($again){


Clear-Host
   
   Write-Host "Patch Logs for server:  from $after to $($after.adddays(7)) "
#    $logs|sort -Property index |select -Last $max  index,timegenerated,entrytype,message  |ft -AutoSize

    if($session){
        $logs=Invoke-Command -ScriptBlock $Logs_block -ArgumentList $after -Session $session
    }else{
        $logs=Invoke-Command -ScriptBlock $Logs_block -ArgumentList $after -Credential $cred
    
    
    }

    $logs|sort -Property installedOn|ft -Wrap

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

}




















}