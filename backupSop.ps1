
function isSecondAttempt($sessionId){

#description-function will check whether this is the attempt to restarta failed backup session
<#working
    Will search for session id in Table 'BackupSessionInfo' [INC#,oldSessionId,newSessionId] from Service-now 
    if there is already a ticket then output yes
    otherwise false




    #>







}



function restartFailedBackup($sessionId,$cellManager){

#Description-function will attempt to restart the failed backup Session

<# working
    1.Check if it is secondAttempt to restart the backup
        if yes then get the error logs of failed session and put it in the ticket
        if No then restart the backup session , insert new SessionId to BackupSessionInfo table
        Periodically chec
#>



    if(!(isSecondAttempt -sessionId $sessionId))
    {
          
                       
    }else{
    
    
    
    }





}

