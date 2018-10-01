function From-XML($Setting){
    $XMLFile = Get-Config-Path
    if(-Not (Test-Path $XMLFile)){
        throw "XML File doesn't exist"
    }
    [XML] $XML = Get-Content($XMLFile)

    if(-Not ($XML.Config)){
        throw "Not a valid config file"
    }

    if(-Not ($XML.Config.$Setting)){
        throw "Not a valid setting"
    }

    return $XML.Config.$Setting
}
