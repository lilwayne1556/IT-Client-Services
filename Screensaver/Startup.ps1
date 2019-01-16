# Startup script for updating screensavers

if(!(Test-Path \\nas\its\its-us\GP\Screensaver\images)){
    Throw "Cannot access screensaver folder"
}

$Date = [system.datetime]::Now.ToString("MM_dd_yyyy")
$RegPath = "HKLM:\SOFTWARE\UNI\Screensaver"
if (Test-Path -Path $RegPath)
{
	$RegDate = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\UNI\Screensaver -name "LastUpdated"
	if ($RegDate -eq $Date)
	{
		Throw "Screensaver already updated"
	}
}

# Remove all of the current ones
Remove-Item -Path C:\Admin\screensaver -Recurse
New-Item -Path C:\Admin\screensaver -ItemType Directory

# Copy screensavers from the network
Copy-Item \\nas\its\its-us\GP\Screensaver\images\* -Destination C:\Admin\screensaver -Recurse

# Create Reg key
if (!(Test-Path -Path $RegPath))
{
	New-Item -Path $RegPath -Force
}

New-ItemProperty -Path $RegPath -name "LastUpdated" -Value $Date -Force