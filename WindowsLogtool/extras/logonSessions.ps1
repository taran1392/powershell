

function getLogonSessions($server,$session,$cred){

if($session){
Invoke-Command -ScriptBlock {qwinsta } -Session $session 
}else{

Invoke-Command -ScriptBlock {qwinsta } -Credential $cred

}


}