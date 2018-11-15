$SecurityGroup = "IT-CS-Computers-ITT108 Bullpen"

Get-ADGroupMember -Identity $SecurityGroup | ForEach-Object {
	$ComputerName = $_.Name
	if (Test-Connection -ComputerName $ComputerName -BufferSize 16 -Count 1 -Quiet)
	{
		Invoke-Command -Cn $ComputerName -ScriptBlock {
			if (!(Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\BurntToast\0.6.2"))
			{
				Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
				Install-Module BurntToast -RequiredVersion 0.6.2
			}
		}
		
		# Fixes an issue with notifications not working on 1607 due to UWP
		Copy-Item "\\nas\its\ITS-US\Ustechs\Wayne's Script\IT-Client-Services\Messaging System\XML" `
				  "\\$($ComputerName)\c$\Program Files\WindowsPowerShell\Modules\BurntToast\0.6.2\lib\Microsoft.Toolkit.Uwp.Notifications" -Recurse -Force
		
		Invoke-Command -Cn $ComputerName -ScriptBlock {
			try
			{
				New-BurntToastNotification -Text "Hello - Wayne", "This is a test with buttons!" -Button (New-BTButton -Content "Google" -Arguments "https://google.com")
			}
			catch
			{
				Write-Host "No one logged into $env:COMPUTERNAME"
			}
		}
		
	}
	else
	{
		Write-Host "$ComputerName is offline"
	}
}