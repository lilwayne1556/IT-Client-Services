Function Get-Programs($ComputerName){
    # Find all 32-bit programs
    $Programs32 = Invoke-Command -ComputerName $ComputerName -ScriptBlock { Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName }

    # Find all 64-bit programs
    $Programs64 = Invoke-Command -ComputerName $ComputerName -ScriptBlock { Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName }

    #Combine 32-bit and 64-bit program list
    $Programs = $Programs32 + $Programs64
    return ($Programs | Select-Object -ExpandProperty DisplayName) -join ","
}