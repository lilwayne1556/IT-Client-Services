function Get-Printers
{
	param
	(
		[parameter(Mandatory = $true)]
		[String]$ComputerName,
	
		[parameter(Mandatory = $false)]
		[string]$filterNameBy = "*",
	
		[parameter(Mandatory = $false)]
		[switch]$ByIP
	)
	#Query Server for printers
	$printers = Get-Printer -ComputerName $ComputerName | where { $_.Name -Match "SCC*" }
	$ports = Get-PrinterPort -ComputerName $ComputerName
	#Generate mappings based on portnames
	$mappings = @()
	foreach ($printer in $printers) {
		foreach ($port in $ports) {
			if ($port.Name -like $printer.PortName)	{
				$mappings += New-Object -TypeName PSObject -Property @{ PrinterName = $printer.Name; Address = $port.PrinterHostAddress }
			}
		}
	}
	
	if ($ByIP) {
		foreach ($printer in $mappings) {
			if (-not [bool]($printer.Address -as [ipAddress])) {
				$printer.Address = (Resolve-DnsName $printer.Address).IPAddress
			}
		}
	}
	return $mappings
}