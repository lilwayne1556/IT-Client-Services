<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.155
	 Created on:   	11/6/2018 9:54 AM
	 Created by:   	it-bowiewaa
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

function Insert-Header($Header)
{
	return "`n" + (" " * (($MAX_WIDTH/2 - $Header.Length)/2)) + $Header + "`n" + "-" * (($MAX_WIDTH - $Header.Length)) + "`n"
}

function Dell-Warranty($SerialNumber)
{
    $apiKey = "634259b0-ea73-4604-86d0-92b50d334fc1"
	
	$URL = "https://api.dell.com/support/assetinfo/v4/getassetwarranty/$($SerialNumber)?apikey=$($Apikey)"
	
	$Request = Invoke-RestMethod -URI $URL -Method GET -ContentType 'Application/xml'
	
	# Extract Warranty Info
	$Warranty = $Request.AssetWarrantyDTO.AssetWarrantyResponse.AssetWarrantyResponse.AssetEntitlementData.AssetEntitlement |`
	Where-Object ServiceLevelDescription -NE 'Dell Digitial Delivery'
	

	if ($Warranty -is [array]){
        $EndDate = ($Warranty[0].EndDate).Substring(0,10)
    }
    else
	{
        if ($Warranty -is [object]){
        $EndDate = ($Warranty.EndDate).Substring(0,10)
        }
        else
        {
        $EndDate = "Expired"
        }
	}
	
	return $EndDate
}

$MAX_WIDTH = 50

# Check if NAS is up
$dir = "\\nas\its\ITS-US\allusers"
if (!(Test-Path $dir))
{
	exit
}


# Holds information to be put into a file
$Info = ""


# Current Date
$Date = Get-Date -Format g
$Info += ("#" * ($MAX_WIDTH - ($Date.length)))`
		+ " " + $Date + " "`
		+ ("#" * ($MAX_WIDTH - ($Date.length)))`
		+ "`n`n"


# Computer Info
$ComputerSys = Get-WmiObject win32_ComputerSystem
$Network = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter IPEnabled=true


$Info += "Computer Name: " + $ComputerSys.Name + "." + $ComputerSys.Domain + "`n"`
		+ "MAC: " + $Network.MACAddress + "`n"`
		+ "IP: " + $Network.IPAddress[0] + "`n"`
		+ "User: " + [Environment]::UserName + "`n`n"


# Hardware information
$OS = Get-WmiObject Win32_OperatingSystem
$OSVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"| Select-Object -ExpandProperty ReleaseId)
$BIOS = Get-WmiObject Win32_Bios
$RAM = (Get-WmiObject -class "cim_physicalmemory" | Measure-Object -Property Capacity -Sum).Sum / 1GB


$Info += Insert-Header("Computer Information")
$Info += "Model: $($computerSys.Model)`n"`
		+ "Serial Number: $($BIOS.SerialNumber)`n"`
		+ "RAM: $($RAM)GB`n"`
		+ "OS: $($OS.Caption)`n"`
		+ "OS Version: $($OSVersion)`n"`
		+ "BIOS: $($BIOS.Manufacturer)  - $($BIOS.Description)`n"`
        + "Warranty Ends: $(Dell-Warranty $BIOS.SerialNumber) `n`n"`

if (Test-Path "HKLM:\Software\Microsoft\Deployment 4")
{
    $Info += Insert-Header("Deployment Information")
	$HKLM = Get-ItemProperty -path "HKLM:\Software\Microsoft\Deployment 4"
	$Info += "Deployment Time: " + ([WMI]'').ConvertToDateTime($HKLM.'Deployment Timestamp') + "`n"`
	+ "Deployment Name: " + $HKLM.'Task Sequence ID' + " - " + $HKLM.'Task Sequence Version' + "`n`n"
}


# Mapped Drives
$Info += Insert-Header("Mapped Drives")
$Info += (Get-PSDrive -PSProvider FileSystem) |`
		Select-Object Name,`
		@{ Name = "Used (GB)"; Expression = { ($_.Used / 1GB).toString("####.##") } },`
		@{ Name = "Free (GB)"; Expression = { ($_.Free / 1GB).toString("####.##") } },`
		@{ Name = "Root"; Expression = { if ($_.DisplayRoot) { $_.DisplayRoot } else { $_.Root } } } |`
		Out-String


# Mapped Printers
$Info += Insert-Header("Installed Printers")
$Info += Get-Printer | Select-Object -ExpandProperty Name | Out-String


# Get the OU of the computer
$OU = ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine" |`
		Select-Object -ExpandProperty Distinguished-Name) -split "," |`
		Where-Object { $_ -match "OU" -and $_ -cmatch "^[^a-z]*$" -and $_ -notmatch "UNI"}).substring(3)

$Info