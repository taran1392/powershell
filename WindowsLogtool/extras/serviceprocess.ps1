
function getService($server){


$s=gwmi win32_service -ComputerName $server
$p=gwmi win32_process -ComputerName $server


$s|select displayname,state,processid,@{n="myval";e={$pid2=$_.processid;$px=$p|?{$_.processid -eq $pid2 };$px.converttodatetime($px.creationdate)}}

}