Function Get-Serial-Number($ComputerName){
    $SerialNumber = Invoke-Command -ComputerName $ComputerName -ScriptBlock {get-ciminstance win32_bios}
    $SerialNumber = $SerialNumber.SerialNumber
    return $SerialNumber.ToUpper()
}