function Get-Last-User($ComputerName){
    return (Get-WmiObject -ComputerName $ComputerName -Class win32_process | Where-Object name -Match explorer).getowner().user
}