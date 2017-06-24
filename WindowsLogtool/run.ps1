$pwdir= Split-Path $MyInvocation.InvocationName -Parent
$pwdir


#$cred=Get-Credential -Message "Run Script as User"



#Start-Process powershell.exe -ArgumentList "-file $pwdir\main.ps1" -Verb runAs

cd $pwdir
$f="$pwd\main.ps1"

"$pwdir/psexec.exe  -i -s  cmd /c powershell.exe  -executionpolicy unrestricted -noexit -file $f"   

."$pwdir/psexec.exe"  -i -s  cmd /c powershell.exe  -executionpolicy unrestricted -noexit -file $f   


<#



MPS
x DSA x
procmon
IIS logs
CBS

merge last boot time nad reboot logs  |use  the microsoft technet script 

run security log through system account

logon sessions   




#>