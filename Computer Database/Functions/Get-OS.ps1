function Get-OS($ComputerName){
    return (Get-WmiObject -ComputerName $ComputerName -Class Win32_OperatingSystem).Caption
}