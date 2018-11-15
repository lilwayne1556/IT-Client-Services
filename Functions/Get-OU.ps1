Function Get-OU($ComputerName){
    # Check OU https://gallery.technet.microsoft.com/scriptcenter/Script-to-determine-the-OU-5a22a0e0
    $Filter = "(&(objectCategory=Computer)(Name=$ComputerName))"
    $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
    $DirectorySearcher.Filter = $Filter
    $SearcherPath = $DirectorySearcher.FindOne()
    $DistinguishedName = $SearcherPath.GetDirectoryEntry().DistinguishedName

    $OUName = ($DistinguishedName.Split(","))[2]
    if($OUName -imatch "Computer"){
        $OUName = ($DistinguishedName.Split(","))[3]
    }

    return $OUName.SubString($OUName.IndexOf("=")+1)
}
