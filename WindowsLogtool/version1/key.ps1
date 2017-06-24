Function TimedPrompt($prompt,$secondsToWait){   
    Write-Host -NoNewline $prompt
    $secondsCounter = 0
    $subCounter = 0
    do{
        start-sleep -Seconds 1d
        $subCounter = $subCounter + 10
        if($subCounter -eq 1000)
        {
            $secondsCounter++
            $subCounter = 0
            Write-Host -NoNewline "."
        }       
        If ($secondsCounter -eq $secondsToWait) { 
            Write-Host "`r`n"
            return $false;
        }
    }While ( (![console]::KeyAvailable) -and ($count -lt $secondsToWait) )

    Write-Host "`r`n"
    return $true;
}


$val = TimedPrompt "Press key to cancel restore; will begin in 3 seconds" 3
Write-Host $val