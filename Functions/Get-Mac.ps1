Function Get-Mac($ComputerName){
    $MacAddress = Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-NetAdapter | select MacAddress}
    return $MacAddress.MacAddress.Replace("-", ":")
}