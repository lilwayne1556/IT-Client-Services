# This will be used to replace Samange's inventory system until
# we are able to get a complete replacement for it

# Must be ran as 32 bit for database to work as we only have 32 bit version of Office
# If we get 64 bit version, then use 64 bit powershell
# This must be ran to enable scripts to be run on 32 bit powrshell
# set-executionpolicy unrestricted
# https://stackoverflow.com/questions/4037939/powershell-says-execution-of-scripts-is-disabled-on-this-system

# Layout
# 1 (Default). Checklist a machine
# 2. Select Computer to perform operations (allow for regex) "Check if computer is either online or in the database, If not in the database then ask to add it"
#     2a. Get Hardware Information "MAC, Serial, Make, Model, BIOS Version, RAM, Monitor"
#     2b. Get Owner "Return from database if exists"
#     2c. Run actions
#     2d. Edit information
#     2e. Get Software
#         2i. List installed software
#         2ii. Compare between two computers
#     2f. Remove computer from Database
# 3. Search by Owner
# 4. Search by Hardware information "MAC, Serial, Make, Model"

. .\..\Include.ps1

Start-Sleep -s 5
$Main = {
    Push-Location $PSScriptRoot

    Clear-Host
"
    1 (Default). Checklist a machine
    2 (WIP). Select Computer to perform operations (allow for regex)
    3 (WIP). Search by Owner
    4 (WIP). Search by Hardware information
    5 (WIP). Mass import computers (*.csv)
"

    $Selection = Read-Host -Prompt "Please select an option from (1-5) "
    Clear-Host
    switch($Selection){
        2 {
            $ComputerName = Read-Host -Prompt "Input Computer Name: "
            # Check whether the computer is in the database or online

            $ComputerName = $ComputerName.ToUpper()

            $Data = Query-Database $ComputerName
            if(!(Is-Online $ComputerName) -And !($Data)){
                "Invalid Computer Name or Offline"
                .$Main
            }

            if(!($Data)){
                Add-Computer $ComputerName
                $Data = Query-Database $ComputerName
            }

            # The user might want to do multiple actions for some computer
            while($True){
                Clear-Host
"
    Computer Name: $($ComputerName)
    1. Get Hardware Information
    2. Get Owner
    3. Run actions
    4. Edit information
    5. Get Software
    6. Remove computer from Database
    7. Go back
"

                $Selection = Read-Host -Prompt "Please select an option from (1-7) "
                Clear-Host

                switch($Selection){
                    1 {
                        # Get Hardware Info
"
    Model - $($Data[1]."Model")
    MAC - $($Data[1]."MAC")
    Serial Number - $($Data[1]."Serial Number")
    RAM - $($Data[1]."RAM(GB)")
    OS - $($Data[1]."OS")
    OS Version - $($Data[1]."OS Version")
"
                        Wait
                    }

                    2 {
                        # Get Owner
"
    Computer Owner - $($Data[1]."Owner")
"
                        Wait
                    }

                    3 {
                        # Run Actions
                        Run-Actions $ComputerName
                        "Actions have been successfully ran"
                        Wait
                    }

                    4 {
                        # Edit Information

                    }

                    5 {
                        # Get Software

                    }

                    6 {
                        # Remove from Database

                    }

                    7 {
                        # Go back
                        .$Main
                    }
                }
            }

        }
        5 {
            $filename = Get-Filename("Select a CSV file to import", "CSV (*.csv)| *.csv")
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
        default {Checklist-Helper}
    }

    .$Main
}

&$Main
