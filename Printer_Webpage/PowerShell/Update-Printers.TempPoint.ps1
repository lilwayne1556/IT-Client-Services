Push-Location $PSScriptRoot
. .\Get-Supplies.ps1
. .\Get-Printers.ps1
. .\Get-Average.ps1

while($True){
    $Printers = @()

    Get-Printers -ComputerName penguin | ForEach-Object {
        $Printer = New-Object -TypeName PSObject
        $Printer | Add-Member -MemberType NoteProperty -Name "Printer Name" -Value $_.PrinterName -PassThru | `
                Add-Member -MemberType NoteProperty -Name "Address" -Value $_.Address

        # Toner, Imaging Unit, Maintenance Kit, Roller Kit
        $ReusableSuppliesDesc = Get-Supplies -Address $_.Address -TreeAddress 43.11.1.1.6
        $ReusableSuppliesCurrent = Get-Supplies -Address $_.Address -TreeAddress .1.3.6.1.4.1.674.10898.100.6.4.4.1.1.16.1
        $ReusableSuppliesMax = Get-Supplies -Address $_.Address -TreeAddress 43.11.1.1.8
        $Printer = Get-Average $Printer $ReusableSuppliesDesc $ReusableSuppliesCurrent $ReusableSuppliesMax

        # Paper Count
        $PaperDesc = "1", "2-4", "5-10", "11-20", "21-30", "31-50"
        $PaperJobs = Get-Supplies -Address $_.Address -TreeAddress .1.3.6.1.4.1.674.10898.100.6.4.2.5.1.5.1
        $PaperCount = Get-Supplies -Address $_.Address -TreeAddress .1.3.6.1.4.1.674.10898.100.6.4.2.5.1.4.1
        $Printer = Get-Average $Printer $PaperDesc $PaperCount $PaperJobs

        # Size on Cart
        $SizeOnCart = Get-Supplies -Address $_.Address -TreeAddress .1.3.6.1.4.1.674.10898.100.6.4.4.1.1.17.1
        $Printer | Add-Member -MemberType NoteProperty -Name "Size On Cart" -Value $SizeOnCart[4]

        $Printers += $Printer
    }

    $Printers | ConvertTo-JSON -Compress | Out-File "../public/data/printers.json" -Encoding ASCII

    # Update every 10 minutes
    Start-Sleep -s 600
}