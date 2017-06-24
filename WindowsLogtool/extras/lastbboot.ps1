function get-LastReboot($server,$session,$cred){

$lastboot_block={
$l=get-EventLog -LogName "system" |?{$_.EventID -eq 1074 -or $_.EventID -eq 6008 -or $_.EventID -eq 6009 }|select -First 1
$l|select @{n="Last boot time";e={$_.TimeGenerated}},@{n="uptime";e={$($(get-date)-$_.timegenerated)}},@{n="shut dwon Type";e={$_.ReplacementStrings[4]}},@{n="Reason";e={$_.ReplacementStrings[2]}},@{n="User";e={$_.ReplacementStrings[6]}},@{n="Process";e={$_.ReplacementStrings[0]}}
}

if($session){
    Invoke-Command -ScriptBlock $lastboot_block -Session $session


}else{

    Invoke-Command -ScriptBlock $lastboot_block -Credential $cred

}


}
