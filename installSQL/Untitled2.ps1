$script_path=Split-Path $MyInvocation.InvocationName -Parent

$global:hashFile="$script_path\hashFile.txt"  #path of the file containing pre calculated hash values of files 

$global:fileList="$script_path\files.txt"  #csv file conating server,filepath to test hash values

$global:fileHashValues=@{}   # hash table contianing hash values of respective files





function get-networkFilename($server,$file){
#function to convert fileath to network file path


$nfs="\\$server\$($file[0])`$"+$file.Substring(2,($file.Length-2))

return $nfs




}



#function to generate hash values of files
function generateHashHashValues(){

$fileList|ForEach-Object {

    $filepath=get-networkFilename $_.server,$_.filepath

    Write-Host "Calculcating hash value for $filepath"
    

    $hash=(Get-FileHash -Path $filepath).hash

    if(!$fileHashvalues.contains($filepath)){
    
    $fileHashValues.add($filepath,$hash)
    
    }


}}


function ValidateHash(){

Import-Csv $global:fileList|ForEach-Object{

$filepath=get-networkFilename $_.server,$_.filepath

    Write-Host "Calculcating hash value for $filepath"
    

    $hash=(Get-FileHash -Path $filepath).hash

    if($fileHashvalues.contains($filepath)){
    
    #$fileHashValues.add($filepath,$hash)
    

    $oldhash=$fileHashvalues.item($filepath)
    if($hash -like $fileHashvalues){
    
            Write-Host "Hash Values Matched for $filepath"
    }
    else{
            Write-Host "Hash Values Did not Matched for $filepath"
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

generateHashHashValues
}








 