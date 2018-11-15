# https://stackoverflow.com/questions/43980204/accessing-an-pscustomobject-with-dot-notation-in-a-string
function Get-Nested-Item {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        $InputObject,

        [Parameter(Mandatory=$false, Position=1)]
        [AllowEmptyString()]
        [string]$Path = '',

        [Parameter(Mandatory=$false, Position=2)]
        [string]$Delimiter = '.'
    )

    if ($Path) {
        $child, $rest = $Path.Split($Delimiter, 2)
        Get-Nested-Item $InputObject.$child $rest
    } else {
        $InputObject
    }
}
