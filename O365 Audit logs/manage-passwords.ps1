Set-ExecutionPolicy RemoteSigned 
#script to manage passwords
    #csv file tenant,username,password
    #functions: display_contents
    #           add-user -tenant,username,password
    #           remove-user -tenant
    #           verify-file
    #           read-user


    $global:script_path=Split-Path $MyInvocation.InvocationName -Parent
    $global:file="$script_path\passwords.txt"
    $global:passwords=@()
    function verify-file(){
    
        Write-Host "Verifying Password file.." -ForegroundColor Yellow

        if(-not (Test-Path $global:file)){
            Write-Host "failed to fnd the password file..."
        
        }else{
        
            Write-Host "File verified.." -ForegroundColor Green
            read-users
        }
    
    
    } #verify function ends


    function read-users(){
    $global:passwords=@()
    Import-Csv $global:file|ForEach-Object{
            $global:passwords+=$_
             
         }
    
    
    }

    function display-users(){
        clear-host
        Write-Host "There are $($passwords.count) user entries" -ForegroundColor Yellow
        $passwords|ft tenant,username -AutoSize
    
    
    } #function display ends


    function update-file(){
    
        $global:passwords|Export-Csv -NoTypeInformation -Path $global:file 
        read-users
       

    
    }#function update file ends

    function add-user(){
    
        Write-Host "Adding new user credentials" -ForegroundColor Yellow
       
       
        $tenant=Read-Host "Please enter tenant domain"
        while($tenant -eq $null){
            Write-Host "tenant name cannot be null.." -ForegroundColor Yellow
            $tenant=Read-Host "Please enter tenant domain" 
            
        
        }
        #Write-Host "please enter credentials"
        $cred=Get-Credential -Message "Please enter the credentials for $tenant"

        $obj=New-Object system.object
        $obj|Add-Member -MemberType NoteProperty -Name tenant -Value $tenant
        $obj|Add-Member -MemberType NoteProperty -Name username -Value $cred.username
        $obj|Add-Member -MemberType NoteProperty -Name password -Value $(ConvertFrom-SecureString $cred.password)
    
        $global:passwords+=$obj
       # $obj|Export-Csv -NoTypeInformation|Out-File $global:file -Append
        update-file    


    }

    function remove-user(){
        Write-Host "REMOVING user credentials" -ForegroundColor Yellow
           
            $i=0

            $global:passwords|ForEach-Object{
            Write-Host "      $i $($_.tenant)    $($_.username)"
                $i++            

            }
            $rem=Read-Host "enter the user serial number to remove"

        if($rem -match "^[\d\.]+$"){
        try{
            $user=$global:passwords[$rem]
            
            $global:passwords=$global:passwords|Where-Object{ $_.tenant -ne $user.tenant }        
            Write-Host "Tenant $($user.tenant) has been removed" -ForegroundColor Green
            update-file
            display-users
        }catch{
            write-host "error occured during removing user"
        }
    }else{
    
        Write-Host "Invalid option chosen.." -ForegroundColor red
    
    }
    }



    verify-file


    $continue="y"
    do{
        
        Write-Host -ForegroundColor Yellow "==== MANAGE TENANT PASSWORDS ====" 
        WRITE-HOST "1. DISPLAY-TENANTS"
        WRITE-HOST "2. ADD-TENANT"
        WRITE-HOST "3. REMOVE-TENANT"
        WRITE-HOST "4. EXIT"

        $s=Read-Host "Please select any option"

        Switch($s){
        
        '1'{  display-users   }
        '2'{ add-user }
        '3'{ remove-user}
        '4'{ 
            $continue ="n"
        
        }

        
        
        }

    
    
    }while($continue -like "y*")






