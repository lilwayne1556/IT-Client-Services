<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.155
	 Created on:   	11/9/2018 8:35 AM
	 Created by:   	it-bowiewaa
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

$ComputerName = Read-Host "Computer Name: "


$Bitlocker = manage-bde -ComputerName $ComputerName -status | Select-String -Pattern "Percentage Encrypted:"

while (!($Bitlocker | Select-String -Pattern "100.0%") -or !($Bitlocker | Select-String -Pattern "0.0%"))
{
	Write-Host "$($Bitlocker). Waiting one minute"
	Start-Sleep -s 60
	$Bitlocker = manage-bde -ComputerName $ComputerName -status | Select-String -Pattern "Percentage Encrypted:"
}
Write-Host "The drive is fully encrypted or decrypted..."