function Get-Unknown-Devices($ComputerName){
    return Get-WmiObject Win32_PNPEntity -ComputerName $ComputerName | Where-Object{$_.ConfigManagerErrorCode -ne 0} | Select Name, DeviceID
}