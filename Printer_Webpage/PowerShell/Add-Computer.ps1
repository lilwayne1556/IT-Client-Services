﻿function Add-Computer($ComputerName){
    # https://technet.microsoft.com/en-us/library/2009.05.scriptingguys.aspx

    $Config = From-XML "Database"

    if(-Not ($Config.Location)){
        $folder = Get-Folder "Select database location"
        Change-XML "Database.Location" $folder
        $Config = From-XML "Database"
    }

    try{
        $LastUser = Get-Last-User $ComputerName | Out-String
        $MAC = Get-Mac $ComputerName | Out-String
        $SerialNumber = Get-Serial-Number $ComputerName | Out-String
        $OU = Get-OU $ComputerName | Out-String
        $OS = Get-OS $ComputerName | Out-String
        $OSVersion = Get-OS-Version $ComputerName | Out-String
        $Model = Get-Computer-Model $ComputerName | Out-String
        $BIOSVersion = Get-BIOS-Version $ComputerName | Out-String
        $RAM = Get-RAM $ComputerName | Out-String
        $Monitors = Get-Monitors $ComputerName
        $Printers = Get-Printers $ComputerName | Out-String
        $Programs = Get-Programs $ComputerName | Out-String

        $ADUser = From-CatID $ComputerName
        if($ADUser)
        {
            $FirstName = $ADUser.GivenName
            $LastName = $ADUser.Surname
            $Email = $ADUser.UserPrincipalName
            $Owner = "$($FirstName) $($LastName)"
        }

        if(!$FirstName){
            $Owner = $OU
        }
    }
    catch{
        "Do not have access to $($ComputerName)"
        return
    }

    $Database = Connect-Database $Config.Location
    $Table = new-object -com "ADODB.Recordset"
    $Data = Query-Database $ComputerName

    if($Data){
        $Query = "SELECT * FROM Inventory WHERE [Computer Name]='$($ComputerName)'"
        $Table.Open($Query, $Database, 3, 3)
    } else {
        $Table.Open("Select * from Inventory", $Database, 3, 3)
        $Table.AddNew()
    }

    $Table.Fields.Item("Computer Name") = $ComputerName.ToUpper()
    $Table.Fields.Item("Owner") = $Owner
    $Table.Fields.Item("Email") = $Email
    $Table.Fields.Item("Last User") = $LastUser
    $Table.Fields.Item("MAC") = $MAC
    $Table.Fields.Item("Serial Number") = $SerialNumber
    $Table.Fields.Item("OU") = $OU
    $Table.Fields.Item("OS") = $OS
    $Table.Fields.Item("OS Version") = $OSVersion
    $Table.Fields.Item("Model") = $Model
    $Table.Fields.Item("BIOS Version") = $BIOSVersion
    $Table.Fields.Item("RAM(GB)") = $RAM
    $Table.Fields.Item("Monitor") = $Monitors
    $Table.Fields.Item("Printer") = $Printers
    $Table.Fields.Item("Programs") = $Programs
    $Table.Update()

    $Database.Close()
    if($Data){
        Write-Host "$($ComputerName) Updated"
    } else {
        Write-Host "$($ComputerName) Added to database"
    }
}

# SIG # Begin signature block
# MIIX5AYJKoZIhvcNAQcCoIIX1TCCF9ECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCENt4kE1cabhGX
# 0sWt60wQNA4ro+BKqIz3cjJNn5lQuqCCEp8wggPHMIICr6ADAgECAhAiSLvsHK6q
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
# BAGCNwIBBDAvBgkqhkiG9w0BCQQxIgQg6x0GZQag9zmUHmlIY2pLBFsQmVSGURn1
# oMC6HhJVwMgwDQYJKoZIhvcNAQEBBQAEggEADgPSxEWDBhrFl69vLdPQIGeBU38E
# RHVHzWyMpyZ1Ne529Fm2hECl1EW2NNqEmJ5TxQ15CqY5IuLsWGdukR/DY+vRM9We
# z1kHKKSyVlZHtSK4L95LFx0NQo7T9+1Gp2tQDRox+lf0hCqh/6HNZUfL7PwH3vpb
# Eew5Bpxv8whfuzG2r4HcOzEKXO0T9wKTtlMjOkajHoqntGsT4HWjFHKpY4OuwpIF
# WZ4bssaGwT6TjYFwIUfVtR87Zl0f/h+tN1g5VuUiR8/b+zDx7tAkUnTzOipAn0oB
# NDSWDml6hyJVqF65AwRAE+c6wOScM+ckHlSgjreslDxUifa8b5njHfz+gqGCArkw
# ggK1BgkqhkiG9w0BCQYxggKmMIICogIBATBrMFsxCzAJBgNVBAYTAkJFMRkwFwYD
# VQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVz
# dGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyAgwkVLh/HhRTrTf6oXgwDQYJYIZIAWUD
# BAIBBQCgggEMMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
# MQ8XDTE5MDEwNDE1NDYxMFowLwYJKoZIhvcNAQkEMSIEIBh6Zi3F6/lraJwHdE2P
# 5RswpiJ2gAVlctwGbtFztrV7MIGgBgsqhkiG9w0BCRACDDGBkDCBjTCBijCBhwQU
# Psdm1dTUcuIbHyFDUhwxt5DZS2gwbzBfpF0wWzELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gU0hBMjU2IC0gRzICDCRUuH8eFFOtN/qheDANBgkqhkiG9w0B
# AQEFAASCAQCLL9PQ14X3kpmt6aA03buMCcatMBvbgbgoNYf1/AV0TZKcpTLKjvJa
# Vy0JE+ic6SxJEynAX2usAtYbkMcFgqxKDEpDOsGj0BbUQGqMM/nDYorOQaALMbKi
# m2iupOaGGTniDTaNAtIpfRQtqmtWiWA0/h5QFQ4nGRHzhqs8e6yz5s17mhleUaHd
# WLWaDyaGO3S/+THnIUwQfShZLsgrp76wQS05eBb1pVrJhUwGcHaPqwX7ZGkaf8aS
# as6AaAXOQEoMLZPDYeZdmcPapHO+oBKRZ+ir3Qzb0kBV+udWosnDApPKeWymLPzZ
# 56gHIe8v6UnABVGd/p56NyRVn70Idh+k
# SIG # End signature block
