Function Change-XML($Nodes, $Value){
    $Path = Get-Config-Path

    $XML = New-Object -TypeName XML
    $XML.Load($Path)

    $x, $y, $z = $Nodes.split(".")
    $XML.Config.$x.$y.$z = $Value

    $XML.Save($Path)
}
