function Connect-Database($Database){
    # https://technet.microsoft.com/en-us/library/2009.05.scriptingguys.aspx

    $Connection = New-Object -com "ADODB.Connection"
    $Connection.Open("Provider = Microsoft.ACE.OLEDB.12.0;Data Source=$Database")

    return $Connection
}