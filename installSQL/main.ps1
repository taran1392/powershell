
$sp=Split-Path $MyInvocation.InvocationName -Parent


Import-Module $sp\showui




function ConvertTo-Scriptblock  {
<#
 Function to Convert a String into a Script Block
#>
	Param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = '',
            ValueFromPipeline = $true)]
            [string]$string 
        )
       $scriptBlock = [scriptblock]::Create($string)
       return $scriptBlock
}


$userinput= StackPanel -ControlName 'Install SQL' -Width 300 -Height 350 { 
    New-Label -VisualStyle 'MediumText' "Server" -Margin 10          
    New-TextBox -Padding  5 -Name Server -Margin 10 -HorizontalScrollBarVisibility Auto -VerticalScrollBarVisibility Auto
    New-Label -VisualStyle 'MediumText' "UserName" -Margin 10         
    New-TextBox -Padding  5 -Name Username -Margin 10
    New-Label -VisualStyle 'MediumText' "Password" -Margin 10          
    New-TextBox -Padding  5 -Name password -Margin 10

            
    New-Button "Install Sql"  -margin 10 -On_Click {            
        Get-ParentControl |            
            Set-UIValue -passThru |             
            Close-Control            
    }            
}  -Show


$user=$userinput.Username
$password=$userinput.password
$server=$userinput.server

$sp


if($user -eq $null -or $password -eq $null -or $server -eq $null){


Write-Host "One of the input is missing.Please run the script again." -ForegroundColor Green

Read-Host "press any key to exit"

Exit
}




$prog= New-Window  {  StackPanel -ControlName 'Installing SQL' -Width 520 -Height 500 { 
    New-TextBox -Padding  5 -Name Server -Margin 10 -Width 500 -Height 400 -TextWrapping Wrap -HorizontalScrollBarVisibility Auto -VerticalScrollBarVisibility Auto
    

            
               
} } -ShowInTaskbar -AsJob -Title "Installing MSSQL " -Width 530
#start-install job

$j=Start-Job -FilePath "$sp\install.ps1" -ArgumentList $user,$password,$server






while($j.State -like "Running"){


$logs=$j|Receive-Job
if($logs){
$log=""
$logs|ForEach-Object{
$log+="$_ `t"
}

$c=@"
 `$s=`$window.content.children[0];`$s.text+="`n`$(get-date) {0}";  
"@ -f $log

$C="$c"

$SC=ConvertTo-Scriptblock -string $C

#$SC
$prog|Update-WPFJob -Command $SC
}
sleep -Seconds 1

}



$log=$j|Receive-Job
$log
$c=@"
 `$s=`$window.content.children[0];`$s.text+="``n `$(get-date) {0}";  
"@ -f $log

$C="$c"

$SC=ConvertTo-Scriptblock -string $C

#$SC
$prog|Update-WPFJob -Command $SC




Read-Host "press any key to exit.."