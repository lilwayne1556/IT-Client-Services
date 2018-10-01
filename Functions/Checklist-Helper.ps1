 function Checklist-Helper(){
    # Used for repeating script
    $ChecklistScript = {

        # Configuration
        # Gets the config from an XML file
        $Config = From-XML "Checklist"

        # Checks if the user configured default location for checklist spread sheet
        if(-Not ($Config.Default.Location)){
            $filename = Get-Filename "Select default checklist excel sheet" "Excel Workbook (*.xlsm, *.xlsx, *.xls)|*.xlsm;*.xlsx;*.xls"
            if(-Not $filename){
                "Failed to get default spread sheet"
                Wait
                return
            }
            Change-XML "Checklist.Default.Location" $filename
        }

        # Checks if the user configured their label excel sheet location
        if(-Not ($Config.Label.Location)){
            $filename = Get-Filename "Select label excel sheet" "Excel Workbook (*.xlsm, *.xlsx, *.xls)|*.xlsm;*.xlsx;*.xls"
            if(-Not $filename){
                "Failed to get label sheet"
                Wait
                return
            }
            Change-XML "Checklist.Label.Location"  $filename
        }

        # Checks if the user configured their checklist folder location
        if(-Not ($Config.Folder.Location)){
            $folder = Get-Folder "Select Checklist folder"
            if(-Not $folder){
                "Failed to get checklist folder"
                Wait
                return
            }
            Change-XML "Checklist.Folder.Location" $folder
        }

        # Get any changes that might have occured
        $Config = From-XML "Checklist"

        # Prompt for Computer Name
        $ComputerName = Read-Host -Prompt 'Input the computer name: '
        $ComputerName = $ComputerName.ToUpper().Trim()

        # Checks if computer is online
        if(-Not (Is-Online $ComputerName)){
            "The computer is offline or the name is wrong"
            Start-Sleep -s 3
            .$ChecklistScript
        }

        # Get Mac
        $MacAddress = Get-Mac $ComputerName

        # Get Serial Number
        $SerialNumber = Get-Serial-Number $ComputerName

        # Check if a checklist exists
        if(Test-Path "$($Config.Folder.Location)\$($ComputerName).xlsm") {
            $Override = Read-Host -Prompt "Checklist exists, Override? (Y/n)"
            if($Override[0] -imatch "n"){
                .$ChecklistScript
            }
        }

        # Add computer to label sheet
        if(Test-Path $Config.Label.Location) {
            $ExcelAppLabel = New-Object -comobject Excel.Application
            $WorkbookLabel = $ExcelAppLabel.Workbooks.Open($Config.Label.Location)
            $Labels = $WorkbookLabel.Worksheets.Item(1)

            # Check if user selects correct spreadsheet
            if($Labels.Cells.Item(1, 1).Value2 -inotmatch "Computer Name" -and $Labels.Cells.Item(1, 2).Value2 -inotmatch "MAC (with colons)" -and $Labels.Cells.Item(1, 3).Value2 -inotmatch "Service Tag") {
                "Improper Label Spreadsheet"
                "MAC - $($MacAddress)"
                "Serial Number - $($SerialNumber)"

                # Remove filename if the excel sheet is not a proper one
                Change-XML "Checklist.Label.Location" ""
            } else {
                for($row=1; $row -lt $Labels.Rows.Count; $row++){
                    if(!$Labels.Cells.Item($row, 1).Value2 -and !$Labels.Cells.Item($row, 2).Value2 -and !$Labels.Cells.Item($row, 3).Value2){
                        $Labels.Cells.Item($row, 1) = $ComputerName
                        $Labels.Cells.Item($row, 2) = $MacAddress.ToUpper()
                        $Labels.Cells.Item($row, 3) = $SerialNumber.ToUpper()

                        # Don't add last column if it isn't apart of the spread sheet
                        if($Labels.Cells.Item(1, 4).Value2) {
                            $Labels.Cells.Item($row, 4) = "University of Northern Iowa"
                        }
                        $WorkbookLabel.Save()
                        $ExcelAppLabel.Workbooks.Close()
                        $ExcelAppLabel.Quit()
                        "The computer has been added to your label excel sheet"
                        break
                    }
                }
            }
        } else {
            "MAC - $($MacAddress)"
            "Serial Number - $($SerialNumber)"
            Change-XML "Checklist.Label.Location" ""
        }

        $FirstName, $LastName, $Email = Get-Owner

        "Please make computer label now"
        Start-Sleep -s 2

        # Start Remote Session
        mstsc /v:$ComputerName

        # Create excel sheet https://blogs.technet.microsoft.com/heyscriptingguy/2006/09/08/how-can-i-use-windows-powershell-to-automate-microsoft-excel/
        $ExcelApp = New-Object -comobject Excel.Application
        $ExcelApp.Visible = $TRUE

        # Open existing checklist
        $Workbook = $ExcelApp.Workbooks.Open($Config.Default.Location)
        $Workbook.SaveAs("$($Config.Folder.Location)\$($ComputerName).xlsm")

        # Select proper sheet in the workbook
        $Checklist = $Workbook.WorkSheets.Item(1)


        $Fullname = Get-Fullname $env:username
        $Checklist.Cells.Item(2, 3) = "$($Fullname)"

        # Get machine model
        $MachineModel = Get-Computer-Model $ComputerName
        $Checklist.Cells.Item(5, 3) = "$($MachineModel)"

        # User should have made the label...
        $Checklist.Cells.Item(6, 3) = "Labeled"

        # Check Useless boxes
        $CheckBoxes = $Checklist.CheckBoxes()
        for ($i=1; $i -lt 12; $i++) {
            $CheckBoxes[$i].Value = 1
        }

        $OU = Get-OU $ComputerName
        $CheckBoxes[12].Value = 1
        $CheckBoxes[13].Value = 1
        $Checklist.Cells.Item(31, 3) = "\\UNI\...\$($OU)"

        # Run all SCCM Actions https://gallery.technet.microsoft.com/scriptcenter/Start-SCCM-Client-Actions-d3d84c3c
        Run-Actions $ComputerName
        $CheckBoxes[14].Value = 1
        $CheckBoxes[15].Value = 1
        $CheckBoxes[16].Value = 1
        "All actions are available"

        # Check if laptop
        if($ComputerName -imatch '-L[0-9]*$'){
            $laptop = Read-Host -Prompt "Is this a laptop? (Y/n)"
            if($laptop[0] -inotmatch "n"){
                $typeLaptop = Read-Host -Prompt "Is this a Individual laptop(Y/n)"
                $Checkboxes[25].Value = 1
                $Password = "laptop#12345678"

                if($typeLaptop[0] -imatch "n"){
                    # Departmental laptop
                    $DepartmentName = $ComputerName.Split("-")[0]
                    $Username = $DepartmentName.ToLower()
                } else {
                    # Individual laptop
                    $localFirstName = $FirstName
                    $localLastName = $LastName
                    $Username = $localFirstName.ToLower()
                }

                # Create local user https://myitblog.co.uk/powershell/script-to-create-local-administrator-account-on-remote-domain-machine/
                $comp = [ADSI]"WinNT://$($ComputerName)"
                #Check if username exists
                Try {
                    $users = $comp.psbase.children | select -expand name
                    if ($users -like $Username) {
                        Write-Host "$($Username) already exists."
                        $Checkboxes[26].Value = 1
                        $Checkboxes[27].Value = 1
                        $Checkboxes[28].Value = 1
                        $Checkboxes[29].Value = 1
                        $Checkboxes[31].Value = 1

                    } else {
                        #Create the account
                        $User = $comp.Create("User", $Username)
                        $User.SetPassword($Password)
                        $User.Put("Description","Use when off campus for longer than two weeks")
                        if($localFirstName){
                            $Fullname = "$($localFirstName) $($localLastName)"

                            $User.Put("Fullname","$fullname")
                            $User.passwordExpired = 1;
                            $User.SetInfo()

                            $Checkboxes[32].Value = 1
                            $Checkboxes[33].Value = 1
                            $Checkboxes[34].Value = 1
                        }

                        #Set password to never expire
                        #And set user cannot change password
                        if($DepartmentName){
                            $ADS_UF_DONT_EXPIRE_PASSWD = 0x10000
                            $ADS_UF_PASSWD_CANT_CHANGE = 0x40
                            $User.userflags = $ADS_UF_DONT_EXPIRE_PASSWD + $ADS_UF_PASSWD_CANT_CHANGE
                            $User.SetInfo()

                            $Checkboxes[26].Value = 1
                            $Checkboxes[27].Value = 1
                            $Checkboxes[28].Value = 1
                            $Checkboxes[29].Value = 1
                            $Checkboxes[31].Value = 1
                        }

                        "The user, $($Username) has been created. Please create a label now."
                    }
                } Catch {
                    Write-Host "Error creating $($Username) on $($ComputerName):  $($Error[0].Exception.Message)"
                }
            }
        }

        # Check for proper display drivers
        Get-Display-Driver $ComputerName | Select-String "Microsoft"

        # Get unknown devices
        $UnknownDevices = Get-Unknown-Devices $ComputerName

        if($DisplayDriver) {
            "Display Driver is wrong"
        } else {
            $CheckBoxes[22].Value = 1
        }

        if($UnknownDevices) {
            "There are unknown devices"
        } else {
            $CheckBoxes[23].Value = 1
        }

        if(!$DisplayDriver -and !$UnknownDevices) {
            "Proper drivers are installed"
        }

        $Programs = Get-Programs $ComputerName

        # Check if programs are available
        if($Programs | Select-String -Pattern "7-Zip") {
            $CheckBoxes[36].Value = 1
        }

        if($Programs | Select-String -Pattern "Reader"){
            $CheckBoxes[37].Value = 1
        }

        if($Programs | Select-String -Pattern "Adobe Flash Player"){
            $CheckBoxes[38].Value = 1
        }

        if($Programs | Select-String -Pattern "Bomgar"){
            $CheckBoxes[20].Value = 1
            $CheckBoxes[39].Value = 1
        }

        if($Programs | Select-String -Pattern "Google Chrome"){
            $CheckBoxes[40].Value = 1
        }

        if($Programs | Select-String -Pattern "Java"){
            $CheckBoxes[41].Value = 1
        }

        if($Programs | Select-String -Pattern "Local Administrator Password Solution"){
            $CheckBoxes[42].Value = 1
        }

        if($Programs | Select-String -Pattern "MDOP MBAM"){
            $CheckBoxes[43].Value = 1
        }

        if($Programs | Select-String -Pattern "Microsoft Office Professional Plus 2016"){
            $CheckBoxes[44].Value = 1
        }

        if($Programs | Select-String -Pattern "Firefox"){
            $CheckBoxes[45].Value = 1
        }

        if($Programs | Select-String -Pattern "Samanage Agent"){
            $CheckBoxes[17].Value = 1
            $CheckBoxes[46].Value = 1
        }

        if($Programs | Select-String -Pattern "Spirion"){
            $CheckBoxes[47].Value = 1
        }

        if($Programs | Select-String -Pattern "VLC"){
            $CheckBoxes[49].Value = 1
        }

        if($Programs | Select-String -Pattern "WinSCP"){
            $CheckBoxes[55].Value = 1
        }

        if($Programs | Select-String -Pattern "Symantec Encryption"){
            $CheckBoxes[54].Value = 1
        }
        $Workbook.Save()

        # FM Checkbox number is 61

        # Add computer to database
        Add-Computer $ComputerName "$($FirstName) $($LastName)" $Email

        # Bitlocker Status
        $Bitlocker = manage-bde -ComputerName $ComputerName -status | Select-String -Pattern "Percentage Encrypted:"

        while(!($Bitlocker | Select-String -Pattern "100.0%")){
            "$($Bitlocker). Waiting one minute"
            Start-Sleep -s 60
            $Bitlocker = manage-bde -ComputerName $ComputerName -status | Select-String -Pattern "Percentage Encrypted:"
        }
        "The drive is fully bitlocked"
        $CheckBoxes[24].Value = 1

        $Workbook.Save()
        Read-Host "Checklist Completed. Press ENTER to exit..."
    }
    &$ChecklistScript
}
