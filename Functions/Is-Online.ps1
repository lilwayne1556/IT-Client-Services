function Is-Online($ComputerName){
    return Test-Connection -ComputerName $ComputerName -BufferSize 16 -Count 1 -Quiet
}