function Get-RAM($ComputerName){
    $RAM = (Get-WmiObject -class "cim_physicalmemory" -ComputerName $ComputerName | Measure-Object -Property Capacity -Sum).Sum / 1GB
    return $RAM
}