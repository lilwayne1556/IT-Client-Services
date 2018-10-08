Function Get-Computer-Model($ComputerName){
    $MachineModel = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_ComputerSystem
    return "$($MachineModel.Manufacturer) $($MachineModel.Model)"
}
