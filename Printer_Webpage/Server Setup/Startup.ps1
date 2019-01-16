Push-Location $PSScriptRoot
Start-Sleep -s 5

New-PSDrive -Name P -PSProvider FileSystem -Root "\\fsa.uni.edu\IT-CS\Waynes_Scripts\IT-Client-Services\Printer_Webpage" -Persist

workflow RunScripts {
    parallel {
        InlineScript { &"P:\PowerShell\Start-Webserver.ps1" }
        InlineScript { &"P:\PowerShell\Update-Printers.ps1" }
    }
}

RunScripts