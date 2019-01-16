 function Checklist-Helper(){
    # Configuration
    # Gets the config from an XML file
    $Config = From-XML "Checklist"

    # Checks if the user configured default location for checklist spread sheet
    if(-Not ($Config.Default.Location)){
        $filename = Get-Filename "Select default checklist excel sheet" "Excel Workbook (*.xlsm, *.xlsx, *.xls)|*.xlsm;*.xlsx;*.xls"
        if(-Not $filename){
            Write-Host "Failed to get default spread sheet"
            Wait
            return
        }
        Change-XML "Checklist.Default.Location" $filename
    }

    # Checks if the user configured their checklist folder location
    if(-Not ($Config.Folder.Location)){
        $folder = Get-Folder "Select Checklist folder"
        if(-Not $folder){
            Write-Host "Failed to get checklist folder"
            Wait
            return
        }
        Change-XML "Checklist.Folder.Location" $folder
    }

    # Get any changes that might have occured
    $Config = From-XML "Checklist"

    # Prompt for Computer Name
    $ComputerName = Read-Host -Prompt 'Input the computer name: '
    $ComputerName = $ComputerName.ToUpper().Trim()

    # Checks if computer is online
    if (!$ComputerName)
    {
        return
    }
    elseif(-Not (Is-Online $ComputerName)){
        Write-Host "The computer is offline or the name is wrong"
        Wait
        Return
    }

    # Get Mac
    $MacAddress = Get-Mac $ComputerName

    # Get Serial Number
    $SerialNumber = Get-Serial-Number $ComputerName

    # Check if a checklist exists
    if(Test-Path "$($Config.Folder.Location)\$($ComputerName).xlsm") {
        $Override = Read-Host -Prompt "Checklist exists, Override? (Y/n)"
        if($Override[0] -imatch "n"){
            return
        }
    }

    # Add computer to label sheet
    Add-Label $ComputerName

    $ADUser = From-CatID $ComputerName
    if($ADUser)
    {
        $FirstName = $ADUser.GivenName
        $LastName = $ADUser.Surname
        $Email = $ADUser.UserPrincipalName
    }

    Write-Host "Please make computer label now"
    Wait

    # Start Remote Session
    mstsc /v:$ComputerName

    # Create excel sheet https://blogs.technet.microsoft.com/heyscriptingguy/2006/09/08/how-can-i-use-windows-powershell-to-automate-microsoft-excel/
    $ExcelApp = New-Object -comobject Excel.Application

    # Open existing checklist
    $Workbook = $ExcelApp.Workbooks.Open($Config.Default.Location)
    $Workbook.SaveAs("$($Config.Folder.Location)\$($ComputerName).xlsm")

    if ($Workbook.FullName -match $Config.Default.Location)
    {
        Write-Host "You cannot overwrite the default checklist"
        Wait
        return
    }
    # Select proper sheet in the workbook
    $Checklist = $Workbook.WorkSheets.Item(1)

    $Fullname = Get-Fullname $env:username
    $Checklist.Cells.Item(2, 3) = "$($Fullname)"

    # Get machine model
    $MachineModel = Get-Computer-Model $ComputerName
    $Checklist.Cells.Item(5, 3) = "$($MachineModel)"

    # User should have made the label...
    $Checklist.Cells.Item(6, 3) = "Labeled"

    # Check Useless boxes
    $CheckBoxes = $Checklist.CheckBoxes()
    for ($i=1; $i -lt 12; $i++) {
        $CheckBoxes[$i].Value = 1
    }

    $OU = Get-OU $ComputerName
    $CheckBoxes[12].Value = 1
    $CheckBoxes[13].Value = 1
    $Checklist.Cells.Item(31, 3) = "\\UNI\...\$($OU)"

    # Run all SCCM Actions https://gallery.technet.microsoft.com/scriptcenter/Start-SCCM-Client-Actions-d3d84c3c
    Run-Actions $ComputerName
    $CheckBoxes[14].Value = 1
    $CheckBoxes[15].Value = 1
    $CheckBoxes[16].Value = 1
    Write-Host "All actions are available"

    # Check if laptop
    if($ComputerName -imatch '-L[0-9]*$'){
        $laptop = Read-Host -Prompt "Is this a laptop? (Y/n)"
        if($laptop[0] -inotmatch "n"){
            $typeLaptop = Read-Host -Prompt "Is this a Individual laptop(Y/n)"
            $Checkboxes[25].Value = 1
            $Password = "laptop#12345678"

            if($typeLaptop[0] -imatch "n"){
                # Departmental laptop
                $DepartmentName = $ComputerName.Split("-")[0]
                $Username = $DepartmentName.ToLower()
            } else {
                # Individual laptop
                $localFirstName = $FirstName
                $localLastName = $LastName
                $Username = $localFirstName.ToLower()
            }

            # Create local user https://myitblog.co.uk/powershell/script-to-create-local-administrator-account-on-remote-domain-machine/
            $comp = [ADSI]"WinNT://$($ComputerName)"
            #Check if username exists
            Try {
                $users = $comp.psbase.children | select -expand name
                if ($users -like $Username) {
                    Write-Host "$($Username) already exists."
                    $Checkboxes[26].Value = 1
                    $Checkboxes[27].Value = 1
                    $Checkboxes[28].Value = 1
                    $Checkboxes[29].Value = 1
                    $Checkboxes[31].Value = 1

                } else {
                    #Create the account
                    $User = $comp.Create("User", $Username)
                    $User.SetPassword($Password)
                    $User.Put("Description","Use when off campus for longer than two weeks")
                    if($localFirstName){
                        $Fullname = "$($localFirstName) $($localLastName)"

                        $User.Put("Fullname","$fullname")
                        $User.passwordExpired = 1;
                        $User.SetInfo()

                        $Checkboxes[32].Value = 1
                        $Checkboxes[33].Value = 1
                        $Checkboxes[34].Value = 1
                    }

                    #Set password to never expire
                    #And set user cannot change password
                    if($DepartmentName){
                        $ADS_UF_DONT_EXPIRE_PASSWD = 0x10000
                        $ADS_UF_PASSWD_CANT_CHANGE = 0x40
                        $User.userflags = $ADS_UF_DONT_EXPIRE_PASSWD + $ADS_UF_PASSWD_CANT_CHANGE
                        $User.SetInfo()

                        $Checkboxes[26].Value = 1
                        $Checkboxes[27].Value = 1
                        $Checkboxes[28].Value = 1
                        $Checkboxes[29].Value = 1
                        $Checkboxes[31].Value = 1
                    }

                    Write-Host "The user, $($Username) has been created. Please create a label now."
                }
            } Catch {
                Write-Host "Error creating $($Username) on $($ComputerName):  $($Error[0].Exception.Message)"
            }
        }
    }

    # Check for proper display drivers
    Get-Display-Driver $ComputerName | Select-String "Microsoft"

    # Get unknown devices
    $UnknownDevices = Get-Unknown-Devices $ComputerName

    if($DisplayDriver) {
        Write-Host "Display Driver is wrong"
    } else {
        $CheckBoxes[22].Value = 1
    }

    if($UnknownDevices) {
        Write-Host "There are unknown devices"
    } else {
        $CheckBoxes[23].Value = 1
    }

    if(!$DisplayDriver -and !$UnknownDevices) {
        Write-Host "Proper drivers are installed"
    }

    $Programs = Get-Programs $ComputerName

    # Check if programs are available
    if($Programs | Select-String -Pattern "7-Zip") {
        $CheckBoxes[36].Value = 1
    }

    if($Programs | Select-String -Pattern "Reader"){
        $CheckBoxes[37].Value = 1
    }

    if($Programs | Select-String -Pattern "Adobe Flash Player"){
        $CheckBoxes[38].Value = 1
    }

    if($Programs | Select-String -Pattern "Bomgar"){
        $CheckBoxes[20].Value = 1
        $CheckBoxes[39].Value = 1
    }

    if($Programs | Select-String -Pattern "Google Chrome"){
        $CheckBoxes[40].Value = 1
    }

    if($Programs | Select-String -Pattern "Java"){
        $CheckBoxes[41].Value = 1
    }

    if($Programs | Select-String -Pattern "Local Administrator Password Solution"){
        $CheckBoxes[42].Value = 1
    }

    if($Programs | Select-String -Pattern "MDOP MBAM"){
        $CheckBoxes[43].Value = 1
    }

    if($Programs | Select-String -Pattern "Microsoft Office Professional Plus 2016"){
        $CheckBoxes[44].Value = 1
    }

    if($Programs | Select-String -Pattern "Firefox"){
        $CheckBoxes[45].Value = 1
    }

    if($Programs | Select-String -Pattern "Samanage Agent"){
        $CheckBoxes[17].Value = 1
        $CheckBoxes[46].Value = 1
    }

    if($Programs | Select-String -Pattern "Spirion"){
        $CheckBoxes[47].Value = 1
    }

    if($Programs | Select-String -Pattern "VLC"){
        $CheckBoxes[49].Value = 1
    }

    if($Programs | Select-String -Pattern "WinSCP"){
        $CheckBoxes[55].Value = 1
    }

    if($Programs | Select-String -Pattern "Symantec Encryption"){
        $CheckBoxes[54].Value = 1
    }
    $Workbook.Save()
    # FM Checkbox number is 61

    # Show Excel sheet now
    $ExcelApp.Visible = $TRUE

    # Add computer to database
    Add-Computer $ComputerName

    # Bitlocker Status
    $Bitlocker = manage-bde -ComputerName $ComputerName -status | Select-String -Pattern "Percentage Encrypted:"

    while(!($Bitlocker | Select-String -Pattern "100.0%")){
        Write-Host "$($Bitlocker). Waiting one minute"
        Start-Sleep -s 60
        $Bitlocker = manage-bde -ComputerName $ComputerName -status | Select-String -Pattern "Percentage Encrypted:"
    }
    Write-Host "The drive is fully bitlocked"
    $CheckBoxes[24].Value = 1

    $Workbook.Save()
    Read-Host "Checklist Completed. Press ENTER to exit..."
}

# SIG # Begin signature block
# MIIX5AYJKoZIhvcNAQcCoIIX1TCCF9ECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBdr0dFCfA0MxWD
# 36sfHB59ot3nUVXsXAdVxm5Lds1huqCCEp8wggPHMIICr6ADAgECAhAiSLvsHK6q
# uUxHGK+8KcxCMA0GCSqGSIb3DQEBBQUAMFcxEzARBgoJkiaJk/IsZAEZFgNlZHUx
# EzARBgoJkiaJk/IsZAEZFgN1bmkxEjAQBgoJkiaJk/IsZAEZFgJhZDEXMBUGA1UE
# AxMOYWQtU05PV0JBTEwtQ0EwHhcNMTMwMTE4MjAxMjU2WhcNMzgwMTE4MjAyMjU2
# WjBXMRMwEQYKCZImiZPyLGQBGRYDZWR1MRMwEQYKCZImiZPyLGQBGRYDdW5pMRIw
# EAYKCZImiZPyLGQBGRYCYWQxFzAVBgNVBAMTDmFkLVNOT1dCQUxMLUNBMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA8Imu6pgtuO9AliwhGQJ97u9tWrNG
# 3YTDgHZKCg9VIr4gWvIs7Cv7KNvV4+8iffG6PIcJJMC+eUt/KBGztwgd4lnNV07f
# 3e5nUwnzYVxeaeLXq5UI9Hqb63r8973cRzk0efzKPt7N+42U+93FArj/0iibQ1Cc
# tagsvi5DCyMsyRcAURvrIOM00ltt5vsGGXgCcYU+7CRQyvCtzuCTNVHK8gDsBb/J
# CgOgtMLh68875WXeAPKPc7XY0mMSWV+iwIhHMH+PUdGgYNdu256CNffglcT6mB7g
# bAr3N5AR4wEkhm1yQjtcyQf3xGx6gI19JpecgDODjdlWwrL4hfKDpJwHCQIDAQAB
# o4GOMIGLMBMGCSsGAQQBgjcUAgQGHgQAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMB
# Af8EBTADAQH/MB0GA1UdDgQWBBQPqXTFwXdaUGsurPGTLHZ37jNfDTASBgkrBgEE
# AYI3FQEEBQIDAgACMCMGCSsGAQQBgjcVAgQWBBQvoxLP+EuPUcoMWW5sQAzt64dr
# 9DANBgkqhkiG9w0BAQUFAAOCAQEAha1Nd8VoT4sE0937owbeyEt1wPz1TPWvOO8n
# 6e6L8PRfdbouzc/6jWEockO3YRf++BWT5Sc9YLWTuK1ikc2yXxyMGnL5BwBNOURc
# vifL9h/Vdo+Y8DFd6Fg+syLhmW78CIg6oKIuxWV41Cku5qTvtdxZoMbxVFYgtMqI
# ubyASuwt+E7DaV0NUqMXfw+ePjYhDXk7OLBZ858slLB/SnexhBHTXrJ/tWN3oRXX
# RNt9tdnWInxayZra4B0uMDYH6bdJVk+LT2P4tg39uCtNNPom3kePkOua9ofZneHa
# C0VuD+2On1OBc2qwPz5BoUYHZ+5qVkRD70uqgH6tgHQHQK14UjCCBBUwggL9oAMC
# AQICCwQAAAAAATGJxlAEMA0GCSqGSIb3DQEBCwUAMEwxIDAeBgNVBAsTF0dsb2Jh
# bFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWduMRMwEQYDVQQD
# EwpHbG9iYWxTaWduMB4XDTExMDgwMjEwMDAwMFoXDTI5MDMyOTEwMDAwMFowWzEL
# MAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMT
# KEdsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gU0hBMjU2IC0gRzIwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCqm47DqxFRJQG2lpTiT9jBCPZGI9lF
# xZWXW6sav9JsV8kzBh+gD8Y8flNIer+dh56v7sOMR+FC7OPjoUpsDBfEpsG5zVvx
# HkSJjv4L3iFYE+5NyMVnCxyys/E0dpGiywdtN8WgRyYCFaSQkal5ntfrV50rfCLY
# FNfxBx54IjZrd3mvr/l/jk7htQgx/ertS3FijCPxAzmPRHm2dgNXnq0vCEbc0oy8
# 9I50zshoaVF2EYsPXSRbGVQ9JsxAjYInG1kgfVn2k4CO+Co4/WugQGUfV3bMW44E
# Tyyo24RQE0/G3Iu5+N1pTIjrnHswJvx6WLtZvBRykoFXt3bJ2IAKgG4JAgMBAAGj
# gegwgeUwDgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0O
# BBYEFJIhp0qVXWSwm7Qe5gA3R+adQStMMEcGA1UdIARAMD4wPAYEVR0gADA0MDIG
# CCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5
# LzA2BgNVHR8ELzAtMCugKaAnhiVodHRwOi8vY3JsLmdsb2JhbHNpZ24ubmV0L3Jv
# b3QtcjMuY3JsMB8GA1UdIwQYMBaAFI/wS3+oLkUkrk1Q+mOai97i3Ru8MA0GCSqG
# SIb3DQEBCwUAA4IBAQAEVoJKfNDOyb82ZtG+NZ6TbJfoBs4xGFn5bEFfgC7AQiW4
# GMf81LE3xGigzyhqA3RLY5eFd2E71y/j9b0zopJ9ER+eimzvLLD0Yo02c9EWNvG8
# Xuy0gJh4/NJ2eejhIZTgH8Si4apn27Occ+VAIs85ztvmd5Wnu7LL9hmGnZ/I1JgF
# snFvTnWu8T1kajteTkamKl0IkvGj8x10v2INI4xcKjiV0sDVzc+I2h8otbqBaWQq
# taai1XOv3EbbBK6R127FmLrUR8RWdIBHeFiMvu8r/exsv9GU979Q4HvgkP0gGHgY
# Il0ILowcoJfzHZl9o52R0wZETgRuehwg4zbwtlC5MIIExjCCA66gAwIBAgIMJFS4
# fx4UU603+qF4MA0GCSqGSIb3DQEBCwUAMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIFNIQTI1NiAtIEcyMB4XDTE4MDIxOTAwMDAwMFoXDTI5MDMxODEw
# MDAwMFowOzE5MDcGA1UEAwwwR2xvYmFsU2lnbiBUU0EgZm9yIE1TIEF1dGhlbnRp
# Y29kZSBhZHZhbmNlZCAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
# AQEA2XhhoZauEv+j/yf2RGB7alYtZ+NfnzGSKkjt+QWEDm1OIlbK2JmXjmnKn3sP
# CMgqK2jRKGErn+Qm7rq497DsXmob4li1tL0dCe3N6D3UZv++IiJtNibPEXiX6VUA
# KMPpN069GeUXhEiyHCGt7HPS86in6V/oNc6FE6cim6yC6f7xX8QSWrH3DEDm0qDg
# TWjQ7QwMEB2PBV9kVfm7KEcGDNgGPzfDJjYljHsPJ4hcODGlAfZeZN6DwBRc4OfS
# XsyN6iOAGSqzYi5gx6pn1rNA7lJ/Vgzv2QXXlSBdhRVAz16RlVGeRhoXkb7BwAd1
# skv3NrrFVGxfihv7DShhyInwFQIDAQABo4IBqDCCAaQwDgYDVR0PAQH/BAQDAgeA
# MEwGA1UdIARFMEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8v
# d3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAkGA1UdEwQCMAAwFgYDVR0l
# AQH/BAwwCgYIKwYBBQUHAwgwRgYDVR0fBD8wPTA7oDmgN4Y1aHR0cDovL2NybC5n
# bG9iYWxzaWduLmNvbS9ncy9nc3RpbWVzdGFtcGluZ3NoYTJnMi5jcmwwgZgGCCsG
# AQUFBwEBBIGLMIGIMEgGCCsGAQUFBzAChjxodHRwOi8vc2VjdXJlLmdsb2JhbHNp
# Z24uY29tL2NhY2VydC9nc3RpbWVzdGFtcGluZ3NoYTJnMi5jcnQwPAYIKwYBBQUH
# MAGGMGh0dHA6Ly9vY3NwMi5nbG9iYWxzaWduLmNvbS9nc3RpbWVzdGFtcGluZ3No
# YTJnMjAdBgNVHQ4EFgQU1Ie4jeblQDydWgZjxkWE2d27HMMwHwYDVR0jBBgwFoAU
# kiGnSpVdZLCbtB7mADdH5p1BK0wwDQYJKoZIhvcNAQELBQADggEBACRyUKUMvEAJ
# psH01YJqTkFfzseIOdPkfPkibDh4uPS692vhJOudfM1IrIvstXZMj9yCaQiW57rh
# Z7bwpr8YCELh680ZWDmlEWEj1hnXAOm70vlfQfsEPv6KIGAM0U8jWhkaGO/Yxt7W
# X1ShepPhtneFwPuxRsQJri9T+5WcjibiSuTE5jw177rG2bnFzc0Hm2O7PQ9hvFV8
# IxC1jIqj0mhFsUC6oN08GxVAuEl4b+WUwG1WSzz2EirUhfNIEwXhuzBFCkG3fJJu
# vk6SYILKW2TmVdPSB96dX5uhAe2b8MNduxnwGAyaoBzpaggLPelml6d1Hg+/KNcJ
# Iw3iFvq68zQwggXtMIIE1aADAgECAgpEfEIGAAIAAG9YMA0GCSqGSIb3DQEBCwUA
# MFcxEzARBgoJkiaJk/IsZAEZFgNlZHUxEzARBgoJkiaJk/IsZAEZFgN1bmkxEjAQ
# BgoJkiaJk/IsZAEZFgJhZDEXMBUGA1UEAxMOYWQtU05PV0JBTEwtQ0EwHhcNMTgw
# NjI3MTQyNTU5WhcNMjMwNjI2MTQyNTU5WjCBhTETMBEGCgmSJomT8ixkARkWA2Vk
# dTETMBEGCgmSJomT8ixkARkWA3VuaTESMBAGCgmSJomT8ixkARkWAmFkMRIwEAYD
# VQQLEwlPVSBBZG1pbnMxDDAKBgNVBAsTA0lUUzEPMA0GA1UECxMGSVRTLVVTMRIw
# EAYDVQQDEwlBZGFtIFB1bHMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQC8MgQvfXTXF+B+YKSF6K/Z51gvYy7bSVDI/ISEjojWXY2YJvuyQ23s840NZOwa
# J9MouFWWp1hxsX+UtfCMf8mFV4L0wvVJxyZ8v8GMQGMzUhf/B//AaMvStS9djIVA
# x4cIlg/8aMeAZlfF6WB+KWmy3WNU8GMPcJKjKWPBTNdzbfUY0cAtJvAF+QzPT2kh
# AJI4hDX51g/rUTiWFnbAOEthh0O3d6dEaYIdi0isYomOMrXyN3WJ7RsU6Xbm8Ldt
# Gn7aJrdBgIk4GRruQiFuLK+kfnRZbvLFuLQEhX2Jt1w8/2upsz43/RGMCGQb3lF0
# 7e7zK/DKykeqM23G5EvQNI/RAgMBAAGjggKKMIIChjA9BgkrBgEEAYI3FQcEMDAu
# BiYrBgEEAYI3FQiF8qV1gdvNJIL1hTb7oAmD0owPgU2EjJtahKioAAIBZgIBAjAT
# BgNVHSUEDDAKBggrBgEFBQcDAzALBgNVHQ8EBAMCB4AwGwYJKwYBBAGCNxUKBA4w
# DDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU8AmJ9i0mQtps7QgxOBSMlpK1wDMwHwYD
# VR0jBBgwFoAUD6l0xcF3WlBrLqzxkyx2d+4zXw0wgdIGA1UdHwSByjCBxzCBxKCB
# waCBvoaBu2xkYXA6Ly8vQ049YWQtU05PV0JBTEwtQ0EoMiksQ049U05PV0JBTEws
# Q049Q0RQLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENO
# PUNvbmZpZ3VyYXRpb24sREM9YWQsREM9dW5pLERDPWVkdT9jZXJ0aWZpY2F0ZVJl
# dm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9p
# bnQwgcIGCCsGAQUFBwEBBIG1MIGyMIGvBggrBgEFBQcwAoaBomxkYXA6Ly8vQ049
# YWQtU05PV0JBTEwtQ0EsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2Vz
# LENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9YWQsREM9dW5pLERDPWVk
# dT9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1
# dGhvcml0eTAsBgNVHREEJTAjoCEGCisGAQQBgjcUAgOgEwwRYWRhbS5wdWxzQHVu
# aS5lZHUwDQYJKoZIhvcNAQELBQADggEBAO+ealUHz/OYTD34OscM1Q7uW/S5SMSX
# 4JQqzHNJC+2GOFyUi8t0bctLehdr9pvwc+JqycGVB+VjAKTarrCuCZ0PWA83sFA1
# m4mtO0DyJl2u5EuvYsBMZWsO+3m3nf86fVYv11fNzXKhdLBBymlM42I0kxNQqvRI
# mhqjBIlM+bT98ENKkif0snwYwQNugoYqaOKof16Fzu3+EqjpVsPNx4SawTi0lHUG
# Axi5Yl8HusbC1im4Ndjkwh00N4NIS7n7Nni4pF0lM8LrJVppO2vflUUGD8yk8rj+
# oLcyJhVU+e8KZxkf4vvv3rHdmxSM1Dd/vYgjMyiwzqk4QhBsQ2AEyusxggSbMIIE
# lwIBATBlMFcxEzARBgoJkiaJk/IsZAEZFgNlZHUxEzARBgoJkiaJk/IsZAEZFgN1
# bmkxEjAQBgoJkiaJk/IsZAEZFgJhZDEXMBUGA1UEAxMOYWQtU05PV0JBTEwtQ0EC
# CkR8QgYAAgAAb1gwDQYJYIZIAWUDBAIBBQCgTDAZBgkqhkiG9w0BCQMxDAYKKwYB
# BAGCNwIBBDAvBgkqhkiG9w0BCQQxIgQgU1rqe8mLUngNJKRLOjVYC22VRpEzhCJw
# Hi0D9slKGeYwDQYJKoZIhvcNAQEBBQAEggEALFRX4kXVfbEHi/WdLv2Miq4WPMXq
# ur6DZUyD3Z0O9vx4XN661WCVpnOydPGHsAs5jH1P94ZF52Pmore37M2TtCsqor7s
# zOx/oNoJB2LVYYCHrqxmkW3Qg2uf8OjDawADas+k5cI3XfhIoMMRoggM1aBLuO6n
# xhx04PrsH2hbgSoRXef1qYQ1szN9gCOF37C2+mt/u6y/Yu0A/VZBkCE5iXrlI9RL
# svxuZbvxxH1EQErTCzYYjSabd2wNir0mGMQ3DNWn+B4LftI7A/erCoTy1Q7oyrZV
# 4TbRdNKvAitjnOO7VuyAHWCrQeF+4+Rg6W4F3s0d/g49Q3Q5J/mjbWljQKGCArkw
# ggK1BgkqhkiG9w0BCQYxggKmMIICogIBATBrMFsxCzAJBgNVBAYTAkJFMRkwFwYD
# VQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVz
# dGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyAgwkVLh/HhRTrTf6oXgwDQYJYIZIAWUD
# BAIBBQCgggEMMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
# MQ8XDTE5MDExNDIxMzA1NlowLwYJKoZIhvcNAQkEMSIEIFmlqtOVTzIeC/s/Cz2C
# KVNMK7nGycjB6fdnC0EgR6bgMIGgBgsqhkiG9w0BCRACDDGBkDCBjTCBijCBhwQU
# Psdm1dTUcuIbHyFDUhwxt5DZS2gwbzBfpF0wWzELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gU0hBMjU2IC0gRzICDCRUuH8eFFOtN/qheDANBgkqhkiG9w0B
# AQEFAASCAQCyc5msqSPKjWfpW7wXvEZZar7nUx/86txQy4kBKHIgdq+NALn8hp7I
# ybccKSPc1TUPEopI9uOnxE5EmXEWh9QXfZHXP0C2k50JG3oDkmO5XVS1aOsiCUCU
# XTX7z7W0Xo91vij/J7rrxp2p6+qifh/FDQYpD1rsH3MgnE+rbOf/eLnWIjgFbLwL
# dbDMoDIw2VqFg39sq8JEV8ESFfNU2i/Hk9AU0uag1Ytjjzvs15iBXpXH+Iue+14A
# pWg6wUehttsbCD+nNCOfF/ctfSlXWkO/U5XL7BRiFcV6ws055JgsMIJZxvZxyxQn
# VSY79/GlampE3w/xqvm+3vLXPeRL0Qug
# SIG # End signature block
