function Get-Printers($ComputerName){

    $Printers = New-Object System.Collections.Generic.HashSet[string]

    # https://serverfault.com/questions/560149/is-there-a-way-to-find-out-what-printers-a-user-has-mapped-remotely
    $results = Invoke-Command -ComputerName $ComputerName -ErrorAction "SilentlyContinue" -ScriptBlock {
        Get-ChildItem Registry::\HKEY_Users |
        Where-Object { $_.PSChildName -NotMatch ".DEFAULT|S-1-5-18|S-1-5-19|S-1-5-20|_Classes" } |
        Select-Object -ExpandProperty PSChildName |
        ForEach-Object {
            (Get-ChildItem Registry::\HKEY_Users\$_\Printers\Connections -Recurse | Select-Object -ExpandProperty Name).split(",")[-1]
        }
    }

    $results | ForEach-Object {
        $Printers.Add($_) | Out-Null
    }

    return $Printers -join ","
}
