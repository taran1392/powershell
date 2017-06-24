 Import-Module ShowUI
 
 $pwdir= Split-Path $MyInvocation.InvocationName -Parent

 ."$pwdir\utility.ps1"
 ."$pwdir\get-reboothistory.ps1"


 #global variables for storing logs

    $MYLogs=@{}


 

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
          
     Write-Host "Q'>>>>>> to Exit."-ForegroundColor Red
}


$l="$env:USERDNSDOMAIN\$env:USERNAME"
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
                   . "$pwdir\logonsessions.exe"
                    read-host "press enter to continue"
                #break
          } '4' {
                    ."$pwdir\Procmon.exe"
               
                #break
          } '5' {
                    
                    getIISlogs -session $session -server $server -cred $cred
                        
                        #iis logs
                   # Write-Host "Sorry this feature is not available yet" -ForegroundColor DarkMagenta
                #break
          } '6' {
              get-Logs -server $server -session $session -cred $cred
                #break 
          } '7' {
                
                get-patchlogs -server $server -session $session -cred $cred

                #break
          } '8' {
                    Write-Host " Task Scheduler `n Sorry this feature is not available yet" -ForegroundColor DarkMagenta

                
          } '9' {
                cls

                #security logs
                read-host "press enter to continue"

                #break
          } '10' {
                
                #services

                get-ServiceList -server $server -session $session -cred $cred
                read-host "press enter to continue"

                #break
          } '11' {
               
               #tasklist

               get-TaskList -server $server -session $session -cred $cred
               read-host "press enter to continue"
               
                #break
          } 
          '12' {
                
                get-RebootHistory -ComputerName $server 
                Read-Host
                #break
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
 
        



