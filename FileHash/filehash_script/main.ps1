$script_path=Split-Path $MyInvocation.InvocationName -Parent

$global:hashFile="$script_path\hashFile.txt"  #path of the file containing pre calculated hash values of files 

$global:fileList="$script_path\files.txt"  #csv file conating server,filepath to test hash values

$global:fileHashValues=@{}   # hash table contianing hash values of respective files





function get-networkFilename($server,$file){
#function to convert fileath to network file path
#Write-Host "$server $file" -ForegroundColor Yellow

#Write-Host "$file null $($file -eq $null)"

$d=$file.substring(0,1)
#Write-Host "$d"
$nfs="\\$server\$d`$"+$file.Substring(2,($file.Length-2))

return $nfs




}






$filepath=Read-Host "Please enter the file path"

if(-not (Test-Path $filepath)){


    Write-Host -ForegroundColor Green "PATH: $filepath is not VALID.Please check"

    Read-Host "press enter to exit"
    exit
}


$records=Import-Csv $filepath -Header @('Server','Filepath','oldHash','currenthash','Match','remarks')
$ErrorActionPreference="stop"

$records|ForEach-Object{
$r=$_
 try{

        
        $_.currenthash=(Get-FileHash -Path $(get-networkFilename -server $_.server -file $_.filepath)).hash

        if($_.oldhash)
        {
                    if($_.oldhash -notlike $_.currenthash)
                    { $_.match="No"
                    
                    }else{
                    $_.match="Yes"
                    }
        }else{
        
        
        $_.remarks="OldHashValue does not exist"
        
        }

        }catch{
        $r.remarks=$_.exception
        
        }
}



$outFile="$script_path\{0:yyyy}{0:MM}{0:dd}_{0:hh}{0:mm}{0:ss}.csv" -f $(Get-Date)



$records|Export-Csv $outFile -NoTypeInformation


Write-Host "Results have been exported to file $outFile"
Read-Host "Press enter to exit"








 