$folder="D:\extra"   #test folder




function get-networkFilename($server,$file){


$nfs="\\$server\$($file[0])`$"+$file.Substring(2,($file.Length-2))

return $nfs




}

$hashfile="d:\projects\filehash.txt"  #file containing hash values


$filehash=@{}




Import-Csv $hashfile|ForEach-Object{
$filehash.add($_.filename,$_.hash)

}




<#

this script is used to validate hash values of files in a particular folder

#>

function validateHashValues($folder,$filehash){

   Get-ChildItem $folder|ForEach-Object {



            $h=Get-FileHash $_.fullname

        if($filehash.Contains($_.fullname)){
            #$filehash.add($_.fullname,$h.hash)
            
            #verify hash values

                $currentHash=$h.hash
                $oldhash=$filehash.Item($_.fullname)
                if($currentHash -eq $oldhash){
                        
                        Write-Host " Hash values MATCHED for file $($_.FullName)" -ForegroundColor Green
                }else{
                
                
                        
                        Write-Host " Hash values NOT MATCHED for file $($_.FullName)" -ForegroundColor Red
                
                
                }

            
            }else{
            
                    Write-Host "New File $($_.fullname)"
            
            }


    }     




}



