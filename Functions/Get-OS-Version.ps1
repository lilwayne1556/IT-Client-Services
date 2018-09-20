function Get-OS-Version($ComputerName){
    return $Version = Invoke-Command -ComputerName $ComputerName -ScriptBlock {(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId).ReleaseId}
}