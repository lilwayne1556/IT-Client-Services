Function Get-Owner(){
    $FirstName = Read-Host -Prompt "What is the Owner's First Name"
    $LastName = Read-Host -Prompt "What is the Owner's Last Name"

    $FirstName = $FirstName.Trim()
    $LastName = $LastName.Trim()

    $AD = Get-ADUser -filter {GivenName -eq $FirstName -and Surname -eq $LastName}

    if(-not $AD){
        "Owner does not exist, Please make sure you entered their correct name and not a nick name"
        return Get-Owner
    }

    # If the object is not an array, then there is only one person in the AD search
    if($AD.GetType().BaseType.name -ne "Array"){
        return $AD.GivenName, $AD.Surname, $AD.UserPrincipalName
    }


    "Potential Options"
    for($i = 0; $i -lt $AD.Count; $i++){
        "$($i+1). $($AD[$i].GivenName) $($AD[$i].Surname), $($AD[$i].UserPrincipalName)"
    }

    [int] $option = Read-Host -Prompt "Which option to you choose(1-$($AD.length))"
    $option = $option - 1
    if($option -lt 0 -or $option -ge $AD.Count){
        "Option is out of range"
        return Get-Owner
    }

    # Returns First Name, Last Name, And Email
    return $AD[$option].GivenName, $AD[$option].Surname, $AD[$option].UserPrincipalName
}
