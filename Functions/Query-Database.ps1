function Query-Database($ComputerName){
    $Config = From-XML "Database"
    if(-Not ($Config.Location)){
        $folder = Get-Folder "Select Database location"
        Change-XML "Database.Location" $folder
        $Config = From-XML "Database"
    }

    $Query = "SELECT * FROM Inventory WHERE [Computer Name]='$($ComputerName)'"

    $Path = $Config.Location
    $Database = New-Object System.Data.OleDb.OleDbConnection
    $Database.ConnectionString = "Provider = Microsoft.ACE.OLEDB.12.0;Data Source=$($Path)"

    $Command = New-Object System.Data.OleDb.OleDbCommand
    $Command.CommandText = $Query
    $Command.Connection = $Database

    $Adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $Command
    $Dataset = New-Object -TypeName System.Data.DataSet
    $Adapter.Fill($Dataset)

    $Database.Close()
    return $Dataset.Tables[0]
}
