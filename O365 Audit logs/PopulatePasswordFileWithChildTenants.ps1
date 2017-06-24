

#import the MSOnline module to allow connectivity to Office 365.


function add-tenantToPasswordFile($tenant){
    
        Write-Host "Adding new user credentials" -ForegroundColor Yellow
       
       
       # $tenant=Read-Host "Please enter tenant domain"
        while($tenant -eq $null){
            Write-Host "tenant name cannot be null.." -ForegroundColor Yellow
            $tenant=Read-Host "Please enter tenant domain" 
            
        
        }
        #Write-Host "please enter credentials"
        $cred=Get-Credential -Message "Please enter the credentials for $tenant"
        if($cred){

        $obj=New-Object system.object
        $obj|Add-Member -MemberType NoteProperty -Name tenant -Value $tenant
        $obj|Add-Member -MemberType NoteProperty -Name username -Value $cred.username
        $obj|Add-Member -MemberType NoteProperty -Name password -Value $(ConvertFrom-SecureString $cred.password)
    
        $global:passwords+=$obj
        $obj|Export-Csv -NoTypeInformation -Append -Path $passwordFile
     
          }


    }

    
$global:script_path=$PSScriptRoot 
    $global:passwordFile="$script_path\passwords.txt"


    


    ."$script_path\manage-passwords_Ver_2.ps1"

Import-Module MSOnline

# This is the partner admin user name to be used to run the report.

$UserName = "boaz@excelandoltd.onmicrosoft.com"

# These are the locations for the report output and error log.

$OutputFile = "c:\test\ReportOutput.csv"

$ErrorFile = "c:\test\Errors.txt"

# This is the report to run and all the necessary parameters.

$LinesToSkip = 0

# This is the prompt for the password of the partner admin user name.

$Cred = get-credential -Credential $UserName

# Establish a Windows PowerShell session with Office 365.

Connect-MsolService -Credential $Cred

# Get all the contracts for the signed-in partner.  
# Contracts define the AOBO/DAP relationship between the partner and the customers.

$Contracts = Get-MsolPartnerContract -All

Write-Host "Found $($Contracts.Count) customers for this Partner."



#get-tenants from password file
    $storedTenants=Import-Csv $passwordFile


  # $storedTenants=Import-Csv "$script_path\password2.txt"
    $savedTenantName=$storedTenants|select -ExpandProperty tenant



    

$missingTenants=$Contracts|Where-Object { $savedTenantName -notcontains $_.defaultdomainName}



Write-Output "There are $($missingTenants.count) tenants missing in the tenant password file"

Write-Output "Please enter the information for missing tenants"
#add missing tenant to the password file
$missingTenants|ForEach-Object {
    
        add-tenantToPasswordFile -tenant $_.defaultdomainname

}




    $check=Import-Csv $passwordFile 

    Write-Host "Now there are $($check.count) tenants in the password file"

#now run the script to fetch logs

    powershell.exe -file "$script_path\main.ps1" -executionpolicy bypass 




