function Get-Monitors($ComputerName){
    $Monitors = Get-WmiObject Win32_PnPEntity -ComputerName $ComputerName | Where {$_.Service -eq "monitor"}
    if($Monitors.length){
        return $Monitors.length
    } else {
        return 1
    }
}
