 
 $pwdir= Split-Path $MyInvocation.InvocationName -Parent

 Import-Module -Name "$pwdir\showui\showui.psm1" 


 $maintFile="d:\mainton"


 ""|Out-File $maintFile

 ."$pwdir\utility.ps1"
 ."$pwdir\get-reboothistory.ps1"



 #global log varible

    $global:myLogs=@{}


 

 $host.ui.RawUI.WindowTitle="current user: $env:USERNAME"

 function Show-Menu
{
    param (
           $Title = 'WINDOWS_MUST_GATHER_TOOL'
     )
     cls
     $heading = "Green"  
    # $env:COMPUTERNAME ; $env:PROCESSOR_ARCHITECTURE

    
     Write-Host "************WINTEL_ADMIN_TROUBLESHOOTING_CONSOLE************" -ForegroundColor $heading
     
     Write-Host "Enter '1'  RUN_DSA" -ForegroundColor $heading
     
     Write-Host "Enter '2'  MPS_REPORT" -ForegroundColor $heading
     
     Write-Host "Enter '3'  Logon-Sessions" -ForegroundColor $heading
     
     Write-Host "Enter '4'  Process_monitor" -ForegroundColor $heading

     Write-Host "Enter '5'  IIS LOGS" -ForegroundColor $heading

     Write-Host "Enter '6'  Event Logs" -ForegroundColor $heading
    
     Write-Host "Enter '7'  CBS_Logs & Windows_Patch_Logs" -ForegroundColor $heading

     Write-Host "Enter '8'  Task_Schedular" -ForegroundColor $heading

     Write-Host "Enter '9'  System_uptime & Who Rebooted the Server" -ForegroundColor $heading

     Write-Host "Enter '10' Export_Services" -ForegroundColor $heading

     Write-Host "Enter '11' Export_Task_List" -ForegroundColor $heading

     Write-Host "Enter '12' Reboot_Hstory" -ForegroundColor $heading
     Write-Host "Enter '13' CBS logs" -ForegroundColor $heading
          
     Write-Host "Q'>>>>>> to Exit."-ForegroundColor Red
}


$l="$env:USERDNSDOMAIN\$env:USERNAME"
Write-Host "Please enter Admin credentials as some feature will need to be run as System Account"
$global:adminCred=Get-Credential


$global:Spassword=$adminCred.getNetworkCredential().password

Write-Host "$l username"
    $server =Read-Host "Enter Server name  (press enter if you want to run on $env:COMPUTERNAME )"

    if($server){
        
        
        $session = New-PSSession -ComputerName $server -Credential $l
        
        if($session){
                       
        
        }else{

            #session error

            Write-Host " failed to create session .Press any key to exit"
            Read-Host
            exit
        
        
        
        }





        }else{
        
        
        $server=$env:COMPUTERNAME
        
        
        }
    




    $valid = $TRUE


 while($valid)
{    
     Show-Menu
     Write-Host "Current User: $env:USERNAME"
     $input = Read-Host "Please make a selection" 
     
     switch ($input)
     {
          '1' {
                    Write-Host "Sorry this feature is not available yet" -ForegroundColor DarkMagenta
               #break
          } '2' {
                 Write-Host "DSA report  Sorry this feature is not available yet" -ForegroundColor DarkMagenta
               

                #break
          } '3' {
               
                   # getLogonSessions -server $server -session $session -cred $cred
                  ."$pwdir\psExec.exe"  -u "administrator" -p $Spassword  powershell.exe -command "`$s=$pwdir\logonsessions.exe;`$s|out-file $pwdir\logonsession.txt"
                    
                    if(Test-Path "$pwdir\logonsession.txt"){
                        $logonlogs=Get-Content "$pwdir\logonsession.txt"

                        add-Logs -logname "LogonSessions" -logs $logonlogs
                 
                    
                    }else{
                    
                        Write-Host "Failed to get Logon Sessions "
                    }
                    
                    read-host "press enter to continue"
                #break
          } '4' {
                     ."$pwdir\psExec.exe"  -u "administrator" -p $Spassword  "$pwdir\Procmon.exe"
               
                #break
          } '5' {
                    
                    getIISlogs -session $session -server $server -cred $cred
                        
                        #iis logs
                   # Write-Host "Sorry this feature is not available yet" -ForegroundColor DarkMagenta
                #break
          } '6' {

                    #eventLogs
              get-Logs -server $server -session $session -cred $cred
                #break 
          } '7' {
                
                get-patchlogs -server $server -session $session -cred $cred

                #break
          } '8' {

                        ."$env:windir\system32\taskschd.msc " /s
                    Write-Host " Task Scheduler `n Sorry this feature is not available yet" -ForegroundColor DarkMagenta

                
          } '9' {
                cls

                #security logs
                read-host "press enter to continue"

                #break
          } '10' {
                
                #services

                $services=get-ServiceList -server $server -session $session -cred $cred
                
                

                add-Logs -logname "Services" -logs $services

                    $services|ft
                read-host "press enter to continue"

                #break
          } '11' {
               
               #tasklist

               $tasks=get-TaskList -server $server -session $session -cred $cred
               
              

               add-Logs -logname "TaskList" -logs $tasks
               $tasks|ft
               read-host "press enter to continue"
               
                #break
          } 
          '12' {
                
               $rebootLogs= get-RebootHistory -ComputerName $server
               
               $rebootLogs
               
               
               add-Logs -logname "Reboot Logs" -logs $rebootLogs
                Read-Host "Press Enter to continue"
                #break
          } 
          13{
          
            showCBSLogs -session $session -server $server 
          }

           'q' {
           Write-Host "quiting"
           $valid = $FALSE
                    
                #break
          } default {
                "Input cannot be determined`n`n"
                #$valid = $FALSE;
                
          }
     
 }    
}
 
        



export-Logs 

Remove-Item $maintFile




