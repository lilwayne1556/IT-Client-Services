<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.155
	 Created on:   	10/23/2018 9:30 AM
	 Created by:   	it-bowiewaa
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

function Update-Calendar($Config, $CalendarStart, $CalendarEnd, $Filename)
{
	Write-Host $CalendarStart, $CalendarEnd, $Filename
	# Using Google's API we can add a calendar event
	$refreshTokenParams = @{
		client_id = $Config.Screensaver.API.Client_ID;
		client_secret = $Config.Screensaver.API.Client_Secret;
		refresh_token = $Config.Screensaver.API.Refresh_Token;
		grant_type = "refresh_token";
	}
	
	$RefreshedToken = Invoke-WebRequest "https://accounts.google.com/o/oauth2/token" -Method POST -Body $refreshTokenParams | ConvertFrom-Json
	$AccessToken = $refreshedToken.access_token
	
	# Has to be in JSON format or else it won't work
	# Dates are in YYYY-MM-dd format
	$request = @{
		end = @{
			date = $CalendarEnd;
		};
		start = @{
			date = $CalendarStart;
		};
		summary = $Filename;
	} | ConvertTo-Json
	
	$requestUri = "https://www.googleapis.com/calendar/v3/calendars/primary/events"
	
	Invoke-WebRequest -Uri $requestUri -Method POST -Headers @{ Authorization = "Bearer $($AccessToken)" } -Body $request -ContentType 'application/json'
}
 

[XML]$Config = Get-Content("\\nas\its\ITS-US\GP\Screensaver\Script\Config.xml")
$Path = "\\nas\its\ITS-US\GP\Screensaver\upcoming images"

Get-ChildItem -Path $Path | ForEach-Object {
	$NameDate = $_.Name.split(" ", 2)
	if ($NameDate[0] -eq "Background")
	{
		return
	}
	
	$Date = $NameDate[0].split("-")
	$Start = $Date[0].split("_") | ForEach-Object {[int] $_}
	$End = $Date[1].split("_") | ForEach-Object { [int]$_ }
	
	Update-Calendar $Config "2018-$($Start[0].ToString('00'))-$($Start[1].ToString('00'))" "2018-$($End[0].ToString('00'))-$($End[1].ToString('00'))" $NameDate[1]
}