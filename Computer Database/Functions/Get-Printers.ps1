function Get-Printers($ComputerName){

    $printers = New-Object System.Collections.ArrayList

    # https://serverfault.com/questions/560149/is-there-a-way-to-find-out-what-printers-a-user-has-mapped-remotely
    Get-ChildItem Registry::\HKEY_Users |
    Where-Object { $_.PSChildName -NotMatch ".DEFAULT|S-1-5-18|S-1-5-19|S-1-5-20|_Classes" } |
    Select-Object -ExpandProperty PSChildName |
    ForEach-Object { Get-ChildItem Registry::\HKEY_Users\$_\Printers\Connections -Recurse | Select-Object -ExpandProperty Name }
    return (Get-WmiObject -Class Win32_Printer -ComputerName $ComputerName | Select-Object -ExpandProperty Name) -join ","
}
