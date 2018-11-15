Function Get-Mac($ComputerName){
    $MacAddress = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-NetAdapter | select Name, MacAddress}
    $Ethernet = $MacAddress | Where-Object {$_.Name -eq "Ethernet"}
    $Wifi = $MacAddress | Where-Object {$_.Name -eq "Wi-Fi"}
    if($Ethernet){
        return $Ethernet.MacAddress.Replace("-", ":")
    } else {
        return $Wifi.MacAddress.Replace("-", ":")
    }
}
