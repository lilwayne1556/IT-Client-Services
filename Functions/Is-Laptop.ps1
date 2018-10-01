function Is-Laptop($ComputerName){
    $hardwareType = (Get-WmiObject -Class Win32_ComputerSystem).PCSystemType

    # Check if laptop
    if($hardwareType -eq 2){
        return $true
    }

    return $false
}
