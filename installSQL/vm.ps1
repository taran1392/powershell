Import-Module Hyper-V


#$env:USERNAME

$ConfirmPreference="None"

$vm=Get-VM
$vm|select -ExpandProperty name
#Restart-VM -VMName "testvm" -Wait -Force
#return $vm|ConvertTo-Json
#Get-VMHost #-Credential $credential -ComputerName lhnr90c1hax