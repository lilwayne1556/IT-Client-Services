Function Get-Fullname($Username){
    # Get User's full name https://serverfault.com/questions/582696/retrieve-current-domain-users-full-name
    return ([adsi]"WinNT://$env:userdomain/$Username,user").fullname
}