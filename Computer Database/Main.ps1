# This will be used to replace Samange's inventory system until
# we are able to get a complete replacement for it

# Must be ran as 32 bit for database to work.. 
# This must be ran to enable scripts to be run on 32 bit powrshell
# set-executionpolicy unrestricted 
# https://stackoverflow.com/questions/4037939/powershell-says-execution-of-scripts-is-disabled-on-this-system

# Layout
# 1 (Default). Checklist a machine
# 2. Select Computer to perform operations (allow for regex)
#     2a. Get Hardware Information
#     2b. Get Owner
#     2c. Get Software
#     2d. Edit information
#     2e. Get software from a computer
#         2i. List installed software
#         2ii. Compare between two computers
#     2f. Remove computer
#     2g. Run actions
# 3. Search by Owner
# 4. Search by Hardware information

Push-Location $PSScriptRoot
. .\Functions\Add-Computer.ps1
. .\Functions\Checklist-Helper.ps1
. .\Functions\Connect-Database.ps1
. .\Functions\Get-BIOS-Version.ps1
. .\Functions\Get-Computer-Model.ps1
. .\Functions\Get-Display-Driver.ps1
. .\Functions\Get-Filename.ps1
. .\Functions\Get-Fullname.ps1
. .\Functions\Get-Last-User.ps1
. .\Functions\Get-Mac.ps1
. .\Functions\Get-OS.ps1
. .\Functions\Get-OS-Version.ps1
. .\Functions\Get-OU.ps1
. .\Functions\Get-Printers.ps1
. .\Functions\Get-Programs.ps1
. .\Functions\Get-RAM.ps1
. .\Functions\Get-Serial-Number.ps1
. .\Functions\Get-Unknown-Devices.ps1
. .\Functions\Get-Monitors.ps1
. .\Functions\Is-Online.ps1
. .\Functions\Run-Actions.ps1
. .\Functions\Separate-Owner-Field-Samanage.ps1
. .\Functions\Start-CMClientAction.ps1

$Main = {
    Push-Location $PSScriptRoot
    Clear-Host
"
    1 (Default). Checklist a machine
    2. Select Computer to perform operations (allow for regex)
    3. Search by Owner
    4. Search by Hardware information
    5. Mass import computers (*.csv)
"

    $Selection = Read-Host -Prompt "Please select an option form (1-5)"
    Clear-Host
    if($Selection -imatch "2"){
    }
    elseif ($Selection -imatch "3"){
    }
    elseif ($Selection -imatch "4"){
    }
    elseif ($Selection -imatch "5"){
        #$filename = Get-Filename("Select a CSV file to import", "CSV (*.csv)| *.csv")
        $filename = "C:\Users\bowiewaa\Desktop\hardwares_2018-09-12_08-22-58.csv"
        $ComputerSpreadsheet = Import-Csv $filename

        foreach($Computer in $ComputerSpreadsheet){
            if(-Not (Is-Online $Computer.Name)){
                continue
            }
            if($Computer.Owner){
                $Owner = Separate-Owner-Field-Samanage $Computer.Owner
            }
            else {
                $Owner = ""
            }
            Add-Computer $Computer.Name $Owner
        }
    }
    else{
        Checklist-Helper
    }

}

&$Main
