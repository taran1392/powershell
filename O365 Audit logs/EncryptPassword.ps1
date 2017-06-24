

#script to geneate encrypted passwords


$pwdir=Split-Path -Parent  $MyInvocation.InvocationName

Write-Host "Script to generate Encryted Credentials" -ForegroundColor Yellow
       
      
        #Write-Host "please enter credentials"
        $cred=Get-Credential -Message "Please enter the credentials to encrypt"

        $obj=New-Object system.object
        $obj|Add-Member -MemberType NoteProperty -Name username -Value $cred.username
        $obj|Add-Member -MemberType NoteProperty -Name password -Value $(ConvertFrom-SecureString $cred.password)

        write-host "Username: $($obj.username)"
        write-host "Username: $($obj.password)"

        $obj.username|Out-File "$pwdir\password.txt" 
        $obj.password|Out-File "$pwdir\password.txt" -Append 


        Write-Host "Passowrd has been saved in the file $pwdir\password.txt"



        
    