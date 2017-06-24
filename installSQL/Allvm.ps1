Import-Module Hyper-V


#$env:USERNAME

$ConfirmPreference="None"

$vm=Get-VM
$vm
#Restart-VM -VMName "testvm" -Wait -Force
#return $vm|ConvertTo-Json
#Get-VMHost #-Credential $credential -ComputerName lhnr90c1hax