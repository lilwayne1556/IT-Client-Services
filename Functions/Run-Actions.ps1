Function Run-Actions($ComputerName){
    $AllActions = $FALSE
    while(!$AllActions){
        try {
            for($i = 1; $i -le 49; $i++){
                Start-CMClientAction -ComputerName $ComputerName -SCCMClientAction $i
            }
            $AllActions = $TRUE
        } catch {
            "Not all actions are availabe yet, waiting one minute..."
            Start-Sleep -s 60
        }
    }
}
