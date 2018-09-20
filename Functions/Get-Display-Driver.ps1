Function Get-Display-Driver($ComputerName){
    return Get-WmiObject Win32_VideoController -Computer $ComputerName | Select Name
}