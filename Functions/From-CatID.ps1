<#
.SYNOPSIS
    Get the CatID from a computer name
.DESCRIPTION
    If there is a computer name with a CatID within it then it will try to retrieve infomation about that person
.PARAMETER
    Required: A computer name that is out standard
.OUTPUTS
    ADUser object
.NOTES
    Version:        1.0
    Author:         Wayne Bowie
    Creation Date:  8/3/2018
    Purpose/Change: Initial script development

.EXAMPLE
    Get-CatID "FM-BOUTOTT-1"
#>

Function From-CatID()
{
    param(
        [parameter(Mandatory=$TRUE,
        Position=0,
        ParameterSetName="ComputerName")]
        [String[]]
        $ComputerName
    )

    process
    {
        $ComputerName.split("-") | ForEach {
            $ADUser = Get-ADUser -Filter {SamAccountName -like $_}
            if($ADUser)
            {
                return $ADUser
            }
        }
    }
}
