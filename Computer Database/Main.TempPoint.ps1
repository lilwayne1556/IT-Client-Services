# This will be used to replace Samange's inventory system until
# we are able to get a complete replacement for it

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

Push-Location $PSScriptRoot
. ..\Include.ps1

Start-Sleep -s 5
$Main = {

    Clear-Host
Write-Host "
    1. Checklist a machine
    2. Select Computer to perform operations
    3. Mass add computers to database (*.csv)
"

    $Selection = Read-Host -Prompt "Please select an option from (1-3) "
    Clear-Host
    switch($Selection){
		1 {
			Checklist-Helper
		}
		2 {
            $ComputerName = Read-Host -Prompt "Input Computer Name: "
            # Check whether the computer is in the database or online

            $ComputerName = $ComputerName.ToUpper()

            $Data = Query-Database $ComputerName
            if(!(Is-Online $ComputerName) -And !($Data)){
                Write-Host "Invalid Computer Name or Offline"
                .$Main
            }

            if(!($Data)){
                Add-Computer $ComputerName
                $Data = Query-Database $ComputerName
            }

            # The user might want to do multiple actions for some computer
            while($True){
                Clear-Host
Write-Host "
    Computer Name: $($ComputerName)
    1. Get Hardware Information
    2. Get Owner
    3. Get Software
    4. Run Actions
    5. Edit Information
    6. Print Label
    7. Remove Computer from Database
    8. Go back
"

                $Selection = Read-Host -Prompt "Please select an option from (1-8) "
                Clear-Host

                switch($Selection){
                    1 {
                        # Get Hardware Info
Write-Host "
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
Write-Host "
    Computer Owner - $($Data[1]."Owner")
    Email - $($Data[1]."Email")
"
                        Wait
                    }

                    3 {
                        # Get Software

                    }

                    4 {
                        # Run Actions
                        Run-Actions $ComputerName
                        Write-Host "Actions have been successfully ran"
                        Wait
                    }

                    5 {
                        # Edit Information

                    }

                    6 {
                        Add-Label $ComputerName
                        Wait
                    }

                    7 {
                        # Remove from Database

                    }

                    8 { .$Main }
                }
            }

        }
        3 {
            Write-Host "Name sure the Computer Name column is named 'Name'"
            Wait
            $filename = Get-Filename("Select a CSV file to import", "CSV (*.csv)| *.csv")
            $ComputerSpreadsheet = Import-CSV $filename

            if(!$ComputerSpreadsheet.Name){
                Write-Host "Invalid CSV Spreadsheet, Rename computer name column to Name"
                .$Main
            }

            foreach($Computer in $ComputerSpreadsheet){
                Add-Computer $Computer.Name
            }
		}
	}
	
    .$Main
}

&$Main
