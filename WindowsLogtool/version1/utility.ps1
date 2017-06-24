﻿function get-Logs($server,$session,$cred){

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
  
   $logs=Invoke-Command -ScriptBlock $fetch_logs_block -ArgumentList $logname,$after,$before,$max 
  
  
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





function get-RebootHistory2($server,$session,$cred){

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
   
   Write-Host "Reboot history Logs for server:$SERVER  from $after to $($after.adddays(7)) "
#    $logs|sort -Property index |select -Last $max  index,timegenerated,entrytype,message  |ft -AutoSize
    if($session){
        $logs=Invoke-Command -ScriptBlock $rebootLogs_block -ArgumentList $after -Session $session
    }else
    {
        $logs=Invoke-Command -ScriptBlock $rebootLogs_block -ArgumentList $after 
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


function get-LastReboot($server,$session,$cred){

$lastboot_block={
$l=get-EventLog -LogName "system" |?{$_.EventID -eq 1074 -or $_.EventID -eq 6008 -or $_.EventID -eq 6009 }|Select -First 1
$l|select @{n="Last boot time";e={$_.TimeGenerated}},@{n="uptime";e={$($(get-date)-$_.timegenerated)}},@{n="shut dwon Type";e={$_.ReplacementStrings[4]}},@{n="Reason";e={$_.ReplacementStrings[2]}},@{n="User";e={$_.ReplacementStrings[6]}},@{n="Process";e={$_.ReplacementStrings[0]}}
}

Write-Host "fetching last boot information  FOR $SERVER"


if($session){
    $r=Invoke-Command -ScriptBlock $lastboot_block -Session $session


}else{

    $r=Invoke-Command -ScriptBlock $lastboot_block 
    $r|ft
}


}




function getLogonSessions($server,$session,$cred){

if($session){
Invoke-Command -ScriptBlock {qwinsta } -Session $session 
}else{

Invoke-Command -ScriptBlock {qwinsta } 

}


}



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
   
   Write-Host "fetching Logs"
     $logs|sort -Property index |select -Last $max  index,timegenerated,entrytype,message  |ft -AutoSize

    if($session){
        $logs=Invoke-Command -ScriptBlock $Logs_block -ArgumentList $after -Session $session
    }else{
        $logs=Invoke-Command -ScriptBlock $Logs_block -ArgumentList $after 
    
    
    }

     Write-Host "Patch Logs for server:$server  from $after to $($after.adddays(7)) "
# 

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









function get-TaskList($server,$session,$cred){

 Write-Host -ForegroundColor Green "Processing $server ..."
 Write-Host -ForegroundColor Green "Task List for $server"

   
   $sblock={ 
    
   $ErrorActionPreference = 'SilentlyContinue'
    $TaskText = schtasks.exe /query /fo list /v
    if (-not $?) {
        Write-Warning -Message "$env:COMPUTERNAME`: schtasks.exe failed"
        continue
    }
    $ErrorActionPreference = 'Continue'
    $TaskText = $TaskText -join "`n"
   $tasks= @(
    foreach ($m in @([regex]::Matches($TaskText, '(?ms)^Folder:[\t ]*([^\n]+)\n(.+)'))) {
        $Folder = $m.Groups[1].Value
        foreach ($FolderEntries in @($m.Groups[2].Value -split "\n\n")) {
            foreach ($Inner in $FolderEntries) {
                [regex]::Matches([string] $Inner, '(?m)^((?:Repeat:\s)?(?:Until:\s)?[^:]+):[\t ]+(.*)') |
                    ForEach-Object -Begin { $h = @{}; $h.'Folder' = [string] $Folder  } -Process {
                        $h.($_.Groups[1].Value) = $_.Groups[2].Value
                    } -End { New-Object -TypeName PSObject -Property $h }
            }
        }
    }) | Where-Object { $_.Folder -notlike '\Microsoft*' -and `
        $_.'Run As User' -notmatch '^(?:SYSTEM|LOCAL SERVICE|Everyone|Users|Administrators|INTERACTIVE)$' -and `
        $_.'Task To Run' -notmatch 'COM handler' }

        
        $tasks
        
        }


        if($session){
        
            Invoke-Command -ScriptBlock $sblock -Session $session |select "schedule type","Last Run Time","Author","TaskName","Next Run Time","Start Time","Start Date","Comment","Run as User","Task To Run","Status","Scheduled Task State","Logon Mode","Last Result"|ft
        }else{
        
                Invoke-Command -ScriptBlock $sblock|select "schedule type","Last Run Time","Author","TaskName","Next Run Time","Start Time","Start Date","Comment","Run as User","Task To Run","Status","Scheduled Task State","Logon Mode","Last Result"|ft         
        }




 }





 function get-ServiceList($server,$session,$cred){

 Write-Host -ForegroundColor Green "Processing $server ..."
 Write-Host -ForegroundColor Green "Service list for $server"

   
   $sblock={ 
   
           $s= Get-Service |select Name,DisplayName,Starttype,Status|?{$_.StartType -like "auto*"}
   
   $s
   }


   if($session){
        
            Invoke-Command -ScriptBlock $sblock -Session $session|ft
            }
            
      else{
      
      Invoke-Command -ScriptBlock $sblock |ft
      }      
            
            
            }






function getIISlogs($session,$server,$cred){

#fetch sites details

Write-Host "Fetching sites from $server"
    if($server){
    
    $sites =Get-WmiObject -Namespace 'root\webadministration' -Class Site -Authentication 6 -ComputerName $server

    
    }else{
    
    $sites=Get-WmiObject -Namespace 'root\webadministration' -Class Site -Authentication 6
    }

    Write-Host  "View IIS logs on $server"

    $i=0
    $sites|ForEach-Object {
    
    Write-Host "$i) $($_.name)  " 
    $i++
    }

  $x=  Read-Host "Please select the site "

  
    if($x -lt $sites.Count -and $x -ge 0){
    
            $logdir= $sites[$x].logfile.directory + "\w3svc$($sites[$x].id)"
            showLogs2 -session $session -logdir $logdir
            

    }else{
    
        Write-Host "It was not a valid choice"
    
    }
        

}



function showLogs($session,$logdir,$server){

$fileindex=1
$loop=$true
    while($loop){
    
   # Clear-Host

   write-host "retrieving file "
        if($session)
        {    $file= Invoke-Command -ScriptBlock {param($fileindex,$logdir) gci $logdir | sort -Property LastWriteTime -Descending |select -Skip $fileindex -First 1} -ArgumentList $fileindex,$logdir -Session $session 
    
        }else{
        
            $file= gci $logdir | sort -Property LastWriteTime -Descending |select -Skip $fileindex -First 1
        
        
        
        }

        $logdir
        $logindex=0
        $max=20

        
<#        Write-Host "Reading logs.."

            if($session){
                $logs=Invoke-Command -session $session -ScriptBlock {param($f) Get-Content $f  } -ArgumentList $file.FullName
                }else{
                
                $logs=Get-Content $file 
                }

                Write-Host "Logs have been read $($logs.count)"
                #>
        $valid=$true


         $file
        $logindex=0
        while($valid){
            
                Write-Host "Reading logs.."

            if($session){
                $logs=Invoke-Command -session $session -ScriptBlock {param($f,$logindex,$max) Get-Content $f|Select -skip $logindex -first $max  } -ArgumentList $file.FullName,$logindex,$max
                }else{
                
                $logs=-ScriptBlock {param($f,$logindex,$max) Get-Content $f|Select -skip $logindex -first $max  } -ArgumentList $file.FullName,$logindex,$max
               
                }

                Write-Host "Logs have been read $($logs.count)"



               #$l= $logs|select -Skip $logindex -First $max

               $logs|ft

               
        
        $c= Read-Host “Please enter V for(previous page) and N (for Next Page) and  Q to exit”
    
    switch ($c) {
        ‘V’ {

                           $logindex-=$max
                        if($logindex -lt 0){
                        $valid =$false
                        $fileindex-=1
                        }
        
                                Write-Host "P lindex  $logindex  $valid  fileindex $fileindex $lcount $($l.count)"
        }

        'N'{
                                   $logindex+=$max

                                   
                                    if($l.count -lt $max){
                               $valid=$false
                                $fileindex+=1
                                }

                                Write-Host " Next lindex  $logindex  $valid  fileindex $fileindex $lcount $($l.count)"

                                }
        default {

        
                                Write-Host " default lindex  $logindex  $valid  fileindex $fileindex $lcount $($l.count)"
        
         return
        }
                                        
        
        } #switch
        
        
        
        
        
        
        } #log loop ends 
        


    Write-Host " $file  $fileindex"
    #Read-Host
        
        } #outer log loop



}  #function showLogs





function showLogs2($session,$logdir,$server){

$fileindex=1
$loop=$true


    $date=$null
    while( -not $date){
    
        $d=Read-Host "please enter the date for which you want to see logs (yyyy/mm/dd)"

        $date=Get-Date -Date $d
    
    
    
    }


    while($loop){
    
    Clear-Host



   write-host "retrieving log file"
        if($session)
        {    $file= Invoke-Command -ScriptBlock {param($fileindex,$logdir,$date) gci $logdir | ?{$_.lastWritetime -ge $date}| select -First 1 -Skip $fileindex} -ArgumentList $fileindex,$logdir,$date -Session $session 
    
        }else{
        
            $file= gci $logdir |?{$_.lastwritetime -ge $date}|select  -First 1 -Skip $fileindex
        
        
        
        }

        $logdir
        $logindex=0
        $max=20

        <#
        Write-Host "Reading logs.."

            if($session){
                $logs=Invoke-Command -session $session -ScriptBlock {param($f) Get-Content $f  } -ArgumentList $file.FullName
                }else{
                
                $logs=Get-Content $file 
                }

                Write-Host "Logs have been read $($logs.count)"#>

        $valid=$true
        while($valid){

        Write-Host "Log file $($file.name)   "
        $file
        
        
                Write-Host "Reading logs.."

            if($session){
                $logs=Invoke-Command -session $session -ScriptBlock {param($f,$logindex,$max) Get-Content $f|Select -skip $logindex -first $max  } -ArgumentList $file.FullName,$logindex,$max
                }else{
                
                $logs=-ScriptBlock {param($f,$logindex,$max) Get-Content $f|Select -skip $logindex -first $max  } -ArgumentList $file.FullName,$logindex,$max
               
                }

                Write-Host "Logs have been read $($logs.count)"

            
        
#               $l= $logs|select -Skip $logindex -First $max
$l=$logs
               $l|ft

               
        
        $c= Read-Host “Please enter V for(previous page) and N (for Next Page) and  Q to exit”
    
    switch ($c) {
        ‘V’ {

                           $logindex-=$max
                        if($logindex -lt 0){
                        $valid =$false
                        if($fileindex -ne 0){
                        $fileindex-=1}
                        $date=$date.addDays(-1)

                        
                        }
        
                                Write-Host "P lindex  $logindex  $valid  fileindex $fileindex $lcount $($l.count)"
        }

        'N'{
                                   $logindex+=$max

                                   
                                    if($l.count -lt $max){
                               $valid=$false
                                $fileindex+=1
                              $date= $date.addDays(1)
                                }

                                Write-Host " Next lindex  $logindex  $valid  fileindex $fileindex $lcount $($l.count)"

                                }
        default {

        
                                Write-Host " default lindex  $logindex  $valid  fileindex $fileindex $lcount $($l.count)"
        
         return
        }
                                        
        
        } #switch
        
        
        
        
        
        } #log loop ends 
        


    Write-Host " $file  $fileindex"
    #Read-Host
        
        } #outer log loop



}  #function showLogs