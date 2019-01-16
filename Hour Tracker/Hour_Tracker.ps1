function Hour_Tracker(){
    param(
        [String[]] $UserNames = "bowiewaa",
        [String[]] $ComputerNames = @("it-itt108-1", "it-itt108-2","it-itt108-3","it-itt108-4","it-itt108-5","it-itt108-6","it-itt108-7","it-itt108-8")
    )

    Begin
    {
        $Date = (Get-Date).AddDays(-14)

        $Computers = @();
        foreach($Computer in $ComputerNames)
        {
            if(Test-Connection $Computer)
            {
                $Computers += $Computer
            }
        }

        $Users = @();
        foreach($User in $UserNames)
        {
            if(Get-ADUser -Filter {samAccountName -like $User})
            {
                $Users += $User
            }
        }

        Write-Host $Computers
    }

    Process{
        foreach($Computer in $Computers)
        {
            Get-EventLog -ComputerName $Computer -LogName "Security" -After $Date | ForEach-Object {
                # Sucessful logon
                if($_.EventID -eq 4624)
                {
                    Write-Host $_.EventID
                }
            }
        }
    }
}

Hour_Tracker