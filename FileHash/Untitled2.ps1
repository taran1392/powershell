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



#function to generate hash values of files
function generateHashHashValues(){

IMPORT-CSV $fileList|ForEach-Object {

#WRITE-HOST $_ -ForegroundColor Cyan

    $filepath=get-networkFilename -server $_.server  -file $_.filepath

    Write-Host "Calculcating hash value for $filepath"
    

    $hash=(Get-FileHash -Path $filepath).hash

    if(!$fileHashvalues.contains($filepath)){
    
    $fileHashValues.add($filepath,$hash)
    
    }


}}


function ValidateHash(){

Import-Csv $global:fileList|ForEach-Object{



$filepath=get-networkFilename -server $_.server -file $_.filepath

    Write-Host "Calculcating hash value for $filepath"
    

    $hash=(Get-FileHash -Path $filepath).hash

    if($fileHashvalues.contains($filepath)){
    
    #$fileHashValues.add($filepath,$hash)
    

    $oldhash=$fileHashvalues.item($filepath)
    if($hash -like $oldhash){
    
            Write-Host "Hash Values Matched for $filepath" -ForegroundColor Green
    }
    else{
            Write-Host "Hash Values Did not Matched for $filepath"  -ForegroundColor Cyan
    }
    }

    }


}



if(Test-Path $hashfile){


Import-Csv $hashfile|ForEach-Object{

  if(!$global:fileHashValues.Contains($_.filepath)){

  $filehashvalues.add($_.filepath,$_.hash)
  
  }
        

}


ValidateHash




}else{


Write-Host "File containing Hash values doe not exist. Now Gennerating Hash Values for the files" -ForegroundColor Green

generateHashHashValues

$fileHashValues.Keys |select @{n="filepath";e={$_}},@{n="Hash";e={$fileHashValues.Item($_)  }}|Export-Csv $hashfile -NoTypeInformation

Write-Host "Hash Values have been generated and has been exported to $hashfile"


}



Read-Host "Press enter to exit"







 