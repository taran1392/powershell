
function get-patchlogs($server,$session,$cred){

 Write-Host -ForegroundColor Green "Processing $server ..."
   
   $sblock={ 
    
   $ErrorActionPreference = 'SilentlyContinue'
    $TaskText = schtasks.exe /query /fo list /v
    if (-not $?) {
        Write-Warning -Message "$env:COMPUTERNAME`: schtasks.exe failed"
        continue
    }
    $ErrorActionPreference = 'Continue'
    $TaskText = $TaskText -join "`n"
   $tasks= @(
    foreach ($m in @([regex]::Matches($TaskText, '(?ms)^Folder:[\t ]*([^\n]+)\n(.+)'))) {
        $Folder = $m.Groups[1].Value
        foreach ($FolderEntries in @($m.Groups[2].Value -split "\n\n")) {
            foreach ($Inner in $FolderEntries) {
                [regex]::Matches([string] $Inner, '(?m)^((?:Repeat:\s)?(?:Until:\s)?[^:]+):[\t ]+(.*)') |
                    ForEach-Object -Begin { $h = @{}; $h.'Folder' = [string] $Folder  } -Process {
                        $h.($_.Groups[1].Value) = $_.Groups[2].Value
                    } -End { New-Object -TypeName PSObject -Property $h }
            }
        }
    }) | Where-Object { $_.Folder -notlike '\Microsoft*' -and `
        $_.'Run As User' -notmatch '^(?:SYSTEM|LOCAL SERVICE|Everyone|Users|Administrators|INTERACTIVE)$' -and `
        $_.'Task To Run' -notmatch 'COM handler' }

        }


        if($session){
        
            Invoke-Command -ScriptBlock $sblock -Session $session |select "schedule type","Last Run Time","Author","TaskName","Next Run Time","Start Time","Start Date","Comment","Run as User","Task To Run","Status","Scheduled Task State","Logon Mode","Last Result"
        }else{
        
        
        }




 }