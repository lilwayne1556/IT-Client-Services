# Custom round fuction as we are using the constricted version of powershell for users which
# does not support [Math]::round, for anything similar
function Round($num, $precision){
    # Convert a numerical type to a String
    [String] $strNum = $num
    $decimal = $strNum.IndexOf(".")
    # Check if there is a decimal
    if($decimal -gt -1){
        # We do this workaround to get the number of decimals we want
        return $strNum.substring(0, ($decimal+$precision+$decimal))
    }

    return $num
}

# Exit the script of we cannot access NAS
if (-Not (Test-Path "\\nas\ITS\ITS-US\allusers\")){
    exit
}

$fso = new-object -ComObject scripting.filesystemobject
#$file =  "\\nas\ITS\ITS-US\allusers\" + [Environment]::MachineName + ".txt"
$file = "test.txt"
$break = "`n"

##################################################################################################
#GENERAL INFORMATION
#Documents the current date, the current user, computer's name, IP and MAC addresses
#total RAM, and the Processor Speed
##################################################################################################

$date = Get-Date
$compSys = Get-WmiObject win32_computersystem

$ipAdd = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter IPEnabled=true
$WMIProc = Get-WmiObject Win32_Processor | Select *
$RAM = (Get-WmiObject -class "cim_physicalmemory" | Measure-Object -Property Capacity -Sum).Sum / 1GB

Write $break | Out-File $file -Append
Write (("#" * 40) + $date + ("#" * 40)) | Out-File $file -Append
Write $break | Out-File $file -Append
Write ("Computer Name: " + $compSys.Name + "." + $compSys.Domain) | Out-File  $file -Append
Write (("MAC: " + $ipAdd.MACAddress) + (" " * 4) + ("IP: " + $ipAdd.IPAddress[0])) | Out-File $file -Append
Write ("User: " + ([Environment]::UserName)) | Out-File $file -Append
write ("RAM: " + $RAM + " GB") | Out-File $file -Append
Write ("Processor Speed: " + $WMIProc.MaxClockSpeed + " MHz") | Out-File $file -Append


##################################################################################################
#PRINTER INFORMATION
#Documents the installed printer as well as the current default printer
##################################################################################################

$printers = Get-WmiObject -Class Win32_Printer | Select *

Write $break | Out-File $file -Append
Write (('*' * 10) + "Installed Printers" + ('*' * 10)) | Out-File $file -Append
Write $break | Out-File $file -Append
Write ("All Installed Printers:") | Out-File $file -Append

foreach ($printer in $printers){
    if($printer.Default){
        Write (("Default Printer: " + $printer.name))  | Out-File $file -Append
    } else {
        Write $printer.name | Out-File $file -Append
    }
}

##################################################################################################
#WMI DATA
#Documents the current Operating System, the Service Pack Level, the Install Date,
#the Service Tag, and the computer Model
##################################################################################################
$OSData = Get-WmiObject Win32_OperatingSystem
$WMIData = Get-WmiObject Win32_ComputerSystemProduct
$Model = Get-WmiObject Win32_ComputerSystem
$BIOS = Get-WmiObject Win32_Bios

Write $break | Out-File $file -Append
Write (("*" * 10) + "WMI DATA" + ("*" * 10)) | Out-File $file -Append
Write $break | Out-File $file -Append
Write ("Operating System: " + $OSData.Caption) | Out-File $file -Append
Write ("Service Pack Level: " + $OSData.CSDVersion) | Out-File $file -Append
$InstallDate = ([WMI]'').ConvertToDateTime($OSData.InstallDate)
Write ("Install Date: " + $InstallDate | Out-File $file -Append)
Write ("Service Tag: " + $WMIData.identifyingnumber) | Out-File $file -Append
Write ("Model: " + $Model.Model) | Out-File $file -Append
Write ("BIOS Version: " + $BIOS.Version) | Out-File $file -Append
Write ("BIOS Info: " + $BIOS.Description) | Out-File $file -Append

##################################################################################################
#Mapped Drives
#Over-Writes the default ".toString()" function of the -PSDrive Class for a faster, more
#customized output. (At the cost of code readablility.)
##################################################################################################

Write $break | Out-File $file -Append
Write (("*" * 10) + "Mapped Drives" + ("*" * 10)) | Out-File $file -Append
$Drives = Get-PSDrive -PSProvider FileSystem

#Data Table Header
$Title = "Name" + (" " * 11) + "Used (GB)" + (" " * 5) + "Free (GB)" + (" " * 4) + "Root"
$underScores = "----" + (" " * 11) + "---------" + (" " * 5) + "---------" + (" " * 4) + "----"

Write $Title | Out-File $file -Append
Write $underScores | Out-File $file -Append

#begin outputting the Data Table for each drive found
foreach($Drive in $Drives){
    $name = $Drive.name

    # We must do the division first before we call the function
    $used = $Drive.used / 1GB
    $free = $Drive.free / 1GB

    # Don't try to round if the number is 0
    if($used -gt 0){
        $used = Round($used, 2)
    }

    if($free -gt 0){
        $free = Round($free, 2)
    }

    # Get the drive letter or remote location of a drive
    if($Drive.DisplayRoot -eq $null){
        $root = $Drive.Root
    } else {
        $root = $Drive.DisplayRoot
    }

    $String = ($name + (" " * (23 - $used.Length)) + $used + (" " * (14 - $free.Length)) + $free + (" " * 4)  + $root)

    Write $String | Out-File $file -Append
}
##################################################################################################
#Registry keys
#Checks to see if the Deployment 4 Registry exists then documents the Data in:
#'Deployment Timestamp', 'Task Sequence Name', 'Task Sequence Version'
#If the Deployment 4 does not exists, skips this sequence
##################################################################################################
if (Test-Path 'HKLM:\Software\microsoft\Deployment 4'){
    Write $break | Out-File $file -Append
    Write (("*" * 10) + "Registry Keys" + ("*" * 10)) | Out-File $file -Append
    Write $break | Out-File $file -Append
    $HKLM = Get-itemProperty -path 'HKLM:\Software\microsoft\Deployment 4'
    $deployTime = ([WMI]'').ConvertToDateTime($HKLM.'Deployment Timestamp')
    Write ("Deployment Timestamp: " + $deployTime) | Out-File $file -Append
    Write ("Task Sequence Name: " + $HKLM.'Task Sequence ID') | Out-File $file -Append
    Write ("Task Sequence Version: " + $HKLM.'Task Sequence Version') | Out-File $file -Append
}


