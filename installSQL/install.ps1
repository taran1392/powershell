param($user,$password,$server)

#global_variables
$global_variable={
$global:file_share="\\WIN-JTORHGEASRF\C$"
$global:setup_folder="c:\sql_setup"
$global:setup_file="c:\sql_setup\sqlServer\setup.exe"
$global:config_file="c:\sql_setup\config.ini"
}



 $checkDotnetversion={
        $c=Get-ChildItem $env:windir\microsoft.net\framework64\ | ?{$_.name -like "v4*"}
        
        if($c)
        {
            #it contains v4 .net framework
            write-output " .Net version $($c.name) is installed"
            return $true
        }
        
        return $false
        
        



}


$copySetupFiles={
#it will copy .net and sql setup files from file share to c:\sql_setup folder



    $t_f=Get-ChildItem $file_share -Recurse|?{-not (test-path $_.fullname -PathType container)} 
    $t_f=$t_f.count
    $i=1

    robocopy $file_share $setup_folder /MIR /NDL /NJS /NJH | ForEach-Object{
    $data = $_.Split([char]9)
    $data[0]=$data[0] -replace "%",""
    if("$($data[4])" -ne "") 
        { $file = "$($data[4])"} 

    if($data[0] -eq 100 -or $data -like "100*" ){
        $i++
        Write-Progress -Activity "Copying files" -PercentComplete ($i*100/$t_f) -Id 1 -Status "copying file $i of $t_f"
        }
    Write-Progress "Percentage $($data[0])" -Activity "Robocopy" -PercentComplete $data[0] -CurrentOperation "$($file)" -ParentId 1 -ErrorAction SilentlyContinue;  
    }





}



$validate_sql_installation={


    $inst = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
    
    if($inst){
        write-output "MSSQL installation was successful. `n Instances List"
    foreach ($i in $inst)
    {
        $p = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$i
            
        $edition=(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Edition
        $version=(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Version
    
        write-output "Instance Name: $i"
        write-output "Edition: $edition "
        write-output "version: $version"


    }
    }else{
    
    write-output "There are no MSSQL instances on the server."
    write-output "Installation failed.." 

    
    
    }




}




function removeSessions(){
        Get-PSSession |Remove-PSSession
    
    }
    




$mount_fileshare={param($user,$password) net use $file_share /user:$user $password}

function install-sql(){
#$server = "localhost"
param([string][validatenotnullorempty()][parameter(mandatory=$true)]$server,$user,$password)

Write-Output "Installing MSSQL on $server"




#credentials
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$credential= New-Object System.Management.Automation.PSCredential ($user, $secpasswd)



#    $credential=Get-Credential 
    
    Write-Output "Connecting to $server"
    $session=New-PSSession -ComputerName $server -Credential $credential
    if($session -eq $null){
        write-output "Failed to connect to remote Server..."
        write-output "Press ant key to exit.."
        exit


    }    
    

    
    Invoke-Command -ScriptBlock $global_variable -Session $session
    
    
    #mount fileshare
    write-output "Mounting File_share on remote server"
    
    
    $user=$credential.GetNetworkCredential().domain +"\" +$credential.GetNetworkCredential().username
    $password= $credential.GetNetworkCredential().Password
    Invoke-Command -ScriptBlock $mount_fileshare -ArgumentList $user,$password -Session $session    
    $fileshare_accessible=Invoke-Command -ScriptBlock {Test-Path $file_share} -Session $session 
    
    if($fileshare_accessible){
        write-output "Copying setup files to the server"
    
      
      #remove "#" from line 140 to disable file_copy bypass
        # Invoke-Command -ScriptBlock $CopysetupFiles -Session $session 
      
      
      
        write-output "checking .net version"
        $dotNetinstalled=Invoke-Command -ScriptBlock $checkdotnetversion -Session $session
    
        if(-not ($dotnetinstalled)){
            write-output ".Net version 4 is not installed 'n Installing .Net ....."
            Invoke-Command -ScriptBlock {Start-Process -FilePath "$setup_folder\dotnet.EXE" -Wait -ArgumentList "/q /norestart" } -Session $session
            
            $dotNetinstalled=Invoke-Command -ScriptBlock $checkdotnetversion -Session $session
            if($dotNetinstalled){
            write-output ".Net has been Installed..."   
            }else{
            
                write-output "Failed to install .Net on the server `n Aborting installation..."
                Write-Output  "Press any key to exit"
                removeSessions
            
            }
        } 
 
        write-output "Installing  MSSQL Server"
    
        winrs -r:$server -u:$($credential.username) -p:$password "C:\sql_setup\sqlServer\SETUP.EXE /configurationfile=C:\sql_setup\config.ini"


        

        
        


        #validate sql installation
        #write-output "SQL Server has been installed successfully" -ForegroundColor green
        write-output "VALIDATION"
        Invoke-Command -Session $session -ScriptBlock $validate_sql_installation   
        removeSessions
     } else{
        write-output "Failed to mount File_share `aborting Installation..."
        removeSessions
     
     
     }    
}







install-sql -server $server -user $user -password $password 