function Get-BIOS-Version($ComputerName){
    $BIOSInfo = Get-WmiObject Win32_bios -ComputerName $ComputerName
    return $BIOSInfo.SMBIOSBIOSVersion
}