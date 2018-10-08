function Add-Label($ComputerName){
    # Add computer to label sheet

    $Config = From-XML "Checklist"
    $MacAddress = Get-Mac $ComputerName
    $SerialNumber = Get-Serial-Number $ComputerName

    # Checks if the user configured their label excel sheet location
    if(-Not ($Config.Label.Location)){
        $filename = Get-Filename "Select label excel sheet" "Excel Workbook (*.xlsm, *.xlsx, *.xls)|*.xlsm;*.xlsx;*.xls"
        if(-Not $filename){
            "Failed to get label sheet"
            Wait
            return
        }
        Change-XML "Checklist.Label.Location"  $filename
        $Config = From-XML "Checklist"
    }

    if(Test-Path $Config.Label.Location) {
        $ExcelAppLabel = New-Object -comobject Excel.Application
        $WorkbookLabel = $ExcelAppLabel.Workbooks.Open($Config.Label.Location)
        $Labels = $WorkbookLabel.Worksheets.Item(1)

        # Check if user selects correct spreadsheet
        if($Labels.Cells.Item(1, 1).Value2 -inotmatch "Computer Name" -and $Labels.Cells.Item(1, 2).Value2 -inotmatch "MAC (with colons)" -and $Labels.Cells.Item(1, 3).Value2 -inotmatch "Service Tag") {
            Write-Host "Improper Label Spreadsheet"
            Write-Host "MAC - $($MacAddress)"
            Write-Host "Serial Number - $($SerialNumber)"

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
                    Write-Host "The computer has been added to your label excel sheet"
                    break
                }
            }
        }
    } else {
        Write-Host "MAC - $($MacAddress)"
        Write-Host "Serial Number - $($SerialNumber)"
        Change-XML "Checklist.Label.Location" ""
    }

}
