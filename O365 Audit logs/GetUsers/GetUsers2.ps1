#script_folder
    $script_path=Split-Path $MyInvocation.InvocationName -Parent

    #import dbScript
    ."\$script_path\dBUsers.ps1"



# Import the MSOnline module to allow connectivity to Office 365.



$folder = "C:\test\2017-05-07\"  #New-Item -ItemType Directory C:\test\$(Get-Date -Format yyyy-MM-dd)

echo $folder
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

# For each of the contracts (customers), run the specified report and output the information.

foreach ($c in $contracts) { 

    # Get the initial domain for the customer.

    $InitialDomain = Get-MsolDomain -TenantId $c.TenantId | Where {$_.IsInitial -eq $true}

    Write-Host "Running report for $($InitialDomain.Name)"

    # Invoke-Command establishes a Windows PowerShell session based on the URL,
    # runs the command, and closes the Windows PowerShell session.
    
    #$ReportInfo = Invoke-Command -ConnectionUri $DelegatedOrgURL -Credential $Cred -Authentication Basic -ConfigurationName Microsoft.Exchange -AllowRedirection -ScriptBlock $ScriptBlock -HideComputerName

    #Get-MsolUser -expandproperty Licenses -tenantId $c.TenantId | Export-Csv -Path "c:\test\ $($InitialDomain.Name).csv" 

    $ReportInfo = Get-MsolUser -All -tenantId $c.TenantId | Select-Object office,WhenCreated,@{name="licenses";expression={$_.licenses.accountskuid}},userprincipalname | Export-Csv -Path "$($folder)\$($InitialDomain.Name).csv" 


    # If Invoke-Command returned information (that is, it's not NULL), format and output the information.
    
    If ($ReportInfo) {

        Write-Host "Writing report information for $($InitialDomain.Name) to $OutputFile"  -foregroundcolor green

        # Convert the report data to CSV format.
        # For the first time, don't skip any lines, so include the header.
        # For all other times, skip the first line (so don't rewrite the header).
        
        $OutputInfo = $ReportInfo |  ConvertTo-CSV -NoTypeInformation | Select -Skip $LinesToSkip

        Out-File $OutputFile -InputObject $OutputInfo -Append

        $LinesToSkip = 1

    } else {

        # If Invoke-Command didn't return and report data, log an error.
        
        Write-Host "No report information for $($InitialDomain.Name)." -foregroundcolor yellow
           
        Out-File $ErrorFile  -InputObject @("No report information for $($InitialDomain.Name).") -Append
    }

}




#Write users to DB
$users=Import-Csv $OutputFile

writeToDB -users $users




