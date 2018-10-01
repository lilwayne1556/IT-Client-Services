Function Get-Config-Path(){
    $Username = [Environment]::UserName
    $Path = "C:\Users\$($Username)\AppData\Roaming\IT-Client-Services"
    if(-Not (Test-Path $Path)){
       md -Path $Path
    }

    if(-Not (Test-Path "$($Path)\config.xml")){
        Copy-Item "config.xml" -Destination "$($Path)\config.xml"
    }

    return "$($Path)\config.xml"
}
