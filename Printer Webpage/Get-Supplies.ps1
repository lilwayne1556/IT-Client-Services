# Supply Information 43.11.1.1.*
# Error message, if any 43.18.1.1.*

function Get-Supplies
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true,
			 ValueFromPipelineByPropertyName = $true,
			 ParameterSetName = "Address")]
		[alias("FQDN","NameHost", "IP")]
		[String]$Address,
	
		[Parameter(Mandatory = $True)]
		[String]$TreeAddress="",
	
		[Parameter(Mandatory = $false)]
		[ValidateRange(0, [int]::MaxValue)]
		[Int]$Retries=0,
	
		[Parameter(Mandatory = $false)]
		[ValidateRange(1, [int]::MaxValue)]
		[Int]$Timeout = 300,
		
		[Parameter(Mandatory = $false)]
		[String]$Community = "public"
	)

	BEGIN
	{
		$snmp = New-Object -ComObject olePrn.OleSNMP
	}
	PROCESS
	{
		#Open SNMP Connection
		$snmp.open($Address, $Community, $Retries, $Timeout)

		#Get supply Information
		try
		{
			$Tree = $snmp.gettree($TreeAddress)
		}
		catch [System.Runtime.InteropServices.COMException]
		{
			Write-Error -Exception (New-Object System.TimeoutException("A timeout has occurred when contacting $Address"))
		}
		
	    return $Tree
	}
	END
	{
		$snmp.close()
	}
}