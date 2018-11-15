function Add-Computer($ComputerName){
    # https://technet.microsoft.com/en-us/library/2009.05.scriptingguys.aspx

    $Config = From-XML "Database"

    if(-Not ($Config.Location)){
        $folder = Get-Folder "Select database location"
        Change-XML "Database.Location" $folder
        $Config = From-XML "Database"
    }

    try{
        $LastUser = Get-Last-User $ComputerName
        $MAC = Get-Mac $ComputerName | Out-String
        $SerialNumber = Get-Serial-Number $ComputerName | Out-String
        $OU = Get-OU $ComputerName | Out-String
        $OS = Get-OS $ComputerName | Out-String
        $OSVersion = Get-OS-Version $ComputerName | Out-String
        $Model = Get-Computer-Model $ComputerName | Out-String
        $BIOSVersion = Get-BIOS-Version $ComputerName | Out-String
        $RAM = Get-RAM $ComputerName | Out-String
        $Monitors = Get-Monitors $ComputerName
        $Printers = Get-Printers $ComputerName | Out-String
        $Programs = Get-Programs $ComputerName | Out-String

        $ADUser = From-CatID $ComputerName
        if($ADUser)
        {
            $FirstName = $ADUser.GivenName
            $LastName = $ADUser.Surname
            $Email = $ADUser.UserPrincipalName
            $Owner = "$($FirstName) $($LastName)"
        }

        if(!$FirstName){
            $Owner = $OU
        }
    }
    catch{
        "Do not have access to $($ComputerName)"
        return
    }

    $Database = Connect-Database $Config.Location
    $Table = new-object -com "ADODB.Recordset"
    $Data = Query-Database $ComputerName

    if($Data){
        $Query = "SELECT * FROM Inventory WHERE [Computer Name]='$($ComputerName)'"
        $Table.Open($Query, $Database, 3, 3)
    } else {
        $Table.Open("Select * from Inventory", $Database, 3, 3)
        $Table.AddNew()
    }

    $Table.Fields.Item("Computer Name") = $ComputerName.ToUpper()
    $Table.Fields.Item("Owner") = $Owner
    $Table.Fields.Item("Email") = $Email
    $Table.Fields.Item("Last User") = $LastUser
    $Table.Fields.Item("MAC") = $MAC
    $Table.Fields.Item("Serial Number") = $SerialNumber
    $Table.Fields.Item("OU") = $OU
    $Table.Fields.Item("OS") = $OS
    $Table.Fields.Item("OS Version") = $OSVersion
    $Table.Fields.Item("Model") = $Model
    $Table.Fields.Item("BIOS Version") = $BIOSVersion
    $Table.Fields.Item("RAM(GB)") = $RAM
    $Table.Fields.Item("Monitor") = $Monitors
    $Table.Fields.Item("Printer") = $Printers
    $Table.Fields.Item("Programs") = $Programs
    $Table.Update()

    $Database.Close()
    if($Data){
        Write-Host "$($ComputerName) Updated"
    } else {
        Write-Host "$($ComputerName) Added to database"
    }
}
