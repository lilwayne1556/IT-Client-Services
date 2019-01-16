<#
.SYNOPSIS
    Move screensavers into their proper locations
.DESCRIPTION
    Will move old screensavers out of the in production folder and move new screensavers into the production folder
.OUTPUTS
    None
.NOTES
    Version:       1.0
    Author:        Wayne Bowie
    Creation Date: 07 Oct 2018
#>

function Move-Each-Image($Path, $Destination, $TypeOfDate)
{
	# Get today's date
	$Date = Get-Date
	
	# Know if we updated the image folder
	$Updated = $FALSE
	
	if (-Not (Test-Path $Path) -or -Not (Test-Path $Destination))
	{
		Throw "The given path is not correct or is offline"
	}
	
	# Determine if we want to use the start or end date
	if ($TypeOfDate -like "Start")
	{
		$DateIndex = 0
	}
	elseif ($TypeOfDate -like "End")
	{
		$DateIndex = 1
	}
	else
	{
		Throw "Wrong type of date"
	}
	
	# Check for we can move a screensaver
	Get-ChildItem -Path $Path | ForEach-Object {
		$Year = $Date.Year
		$Month = $Date.Month
		$Day = $Date.Day
		# Get the first character or space
		$_.Name -match "[ a-zA-Z]" | Out-Null
		
		# Separate the timeframe from the filename
		$Index = $_.Name.IndexOf($Matches[0])
		if ($Index -lt 7)
		{
			# Continue
			return
		}
		$Timeframe = $_.Name.SubString(0, $Index).split("-")
		
		# Separate each section of the starting or ending date
		$ScreensaverDate = $Timeframe[$DateIndex].split("_")
		try
		{
			$ScreensaverMonth = [int]$ScreensaverDate[0]
			$ScreensaverDay = [int]$ScreensaverDate[1]
			$ScreensaverYear = $ScreensaverDate[2]
			
			if ($ScreensaverYear.length -eq 0)
			{
                # For when the year was not set
				$ScreensaverYear = $Year
			}
			elseif ($ScreensaverYear.length -eq 2)
			{
				# Get last two digits of the year
				$Year = [int]$Year.ToString().SubString(2, 2)
			}
			
			# Convert to int
			$ScreensaverYear = [int]$ScreensaverYear
			if (($ScreensaverMonth -lt 1 -or $ScreensaverMonth -gt 12) -or ($ScreensaverDay -lt 1 -or $ScreensaverDay -gt 31) -or ($ScreensaverYear -lt 0))
			{
				# Continue
				return
			}
		}
		catch
		{
			# Continue
			return
		}
		
		# Check if it is past due but new month    If it past due but same month        If it is past due but a new year
		if (($Month -gt $ScreensaverMonth -and $Year -eq $ScreensaverYear) -or ($Month -eq $ScreensaverMonth -and $Day -ge $ScreensaverDay) -or ($Year -gt $ScreensaverYear))
		{
			# Move the wallpaper
			Move-Item -Path "$($Path)\$($_)" -Destination "$($Destination)\$($_)" -Force
			
			$logDir = "$($script:Config.Screensaver.Logs)\$([system.datetime]::Now.ToString("MM_dd_yyyy"))"
			
			# Log the creation of the file
			if (!(Test-Path -Path $logDir))
			{
				New-Item -Path $logDir -ItemType directory
			}
			
			Add-Content "$($logDir)\Moved.txt" "Moved $($_.Name) From $($Path) to $($Destination)`n"
			$Updated = $TRUE
		}
	}
	
	return $Updated
}

if (!(Test-Path -Path "\\nas\its\ITS-US\GP\Screensaver\Script\Config.xml"))
{
	Throw "Configuration file needs to be created"
}
[XML]$Config = Get-Content("\\nas\its\ITS-US\GP\Screensaver\Script\Config.xml")

# Location of the Screensaver execuable
$ApplicationEXE = "C:\Program Files\UNI\UNI Screensaver Manager\UNI Screensaver Manager.exe"
if(!(Test-Path -Path $ApplicationEXE)){
    Throw "UNI Screensaver Manager is not installed"
}

$RemovedOld = Move-Each-Image $Config.Screensaver.InProduction $Config.Screensaver.Old "End"
$AddedNew = Move-Each-Image $Config.Screensaver.Upcoming $Config.Screensaver.InProduction "Start"

if($RemovedOld -or $AddedNew) {
    Start-Process -FilePath $ApplicationEXE -ArgumentList "True ImagesOnly"
}