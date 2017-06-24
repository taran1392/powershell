$folder="D:\extra"


#lets regenerate hash values

$nHashfile="d:\projects\filehash.txt"


$nfilehash=@{}


Get-ChildItem $folder|ForEach-Object {



$h=Get-FileHash $_.fullname

$nfilehash.add($_.fullname,$h.hash)

}




$nfilehash.Keys |select @{n="filename";e={$_}},@{n="Hash";e={$nfilehash.Item($_)  }}|Export-Csv $nHashfile -NoTypeInformation