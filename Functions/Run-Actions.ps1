Function Run-Actions($ComputerName){
    Push-Location $PSScriptRoot
    . .\Start-CMClientAction.ps1
    $AllActions = $FALSE
    while(!$AllActions){
        try {
            for($i = 1; $i -le 49; $i++){
                "$($i)"
                Start-CMClientAction -ComputerName $ComputerName -SCCMClientAction $i
            }
            $AllActions = $TRUE
        } catch {
            "Not all actions are availabe yet, waiting one minute..."
            Start-Sleep -s 60
        }
    }
}