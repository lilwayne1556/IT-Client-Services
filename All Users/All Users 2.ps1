<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.155
	 Created on:   	11/6/2018 9:54 AM
	 Created by:   	it-bowiewaa
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

function Insert-Header($Header)
{
	return "`n" + (" " * (($MAX_WIDTH/2 - $Header.Length)/2)) + $Header + "`n" + "-" * (($MAX_WIDTH - $Header.Length)) + "`n"
}

function Dell-Warranty($SerialNumber)
{
    $apiKey = "634259b0-ea73-4604-86d0-92b50d334fc1"
	
	$URL = "https://api.dell.com/support/assetinfo/v4/getassetwarranty/$($SerialNumber)?apikey=$($Apikey)"
	
	$Request = Invoke-RestMethod -URI $URL -Method GET -ContentType 'Application/xml'
	
	# Extract Warranty Info
	$Warranty = $Request.AssetWarrantyDTO.AssetWarrantyResponse.AssetWarrantyResponse.AssetEntitlementData.AssetEntitlement |`
	Where-Object ServiceLevelDescription -NE 'Dell Digitial Delivery'
	

	if ($Warranty -is [array]){
        $EndDate = ($Warranty[0].EndDate).Substring(0,10)
    }
    else
	{
        if ($Warranty -is [object]){
        $EndDate = ($Warranty.EndDate).Substring(0,10)
        }
        else
        {
        $EndDate = "Expired"
        }
	}
	
	return $EndDate
}

$MAX_WIDTH = 50

# Check if NAS is up
$dir = "\\fsa.ad.uni.edu\IT-CS\allusers"
if (!(Test-Path $dir))
{
	exit
}


# Holds information to be put into a file
$Info = ""


# Current Date
$Date = Get-Date -Format g
$Info += ("#" * ($MAX_WIDTH - ($Date.length)))`
		+ " " + $Date + " "`
		+ ("#" * ($MAX_WIDTH - ($Date.length)))`
		+ "`n`n"


# Computer Info
$ComputerSys = Get-WmiObject win32_ComputerSystem
$Network = Get-WmiObject Win32_NetworkAdapterConfiguration -Filter IPEnabled=true
$ComputerName = $ComputerSys.Name


$Info += "Computer Name: " + $ComputerSys.Name + "." + $ComputerSys.Domain + "`n"`
		+ "MAC: " + $Network.MACAddress + "`n"`
		+ "IP: " + $Network.IPAddress[0] + "`n"`
		+ "User: " + [Environment]::UserName + "`n`n"


# Hardware information
$OS = Get-WmiObject Win32_OperatingSystem
$OSVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"| Select-Object -ExpandProperty ReleaseId)
$BIOS = Get-WmiObject Win32_Bios
$RAM = (Get-WmiObject -class "cim_physicalmemory" | Measure-Object -Property Capacity -Sum).Sum / 1GB


$Info += Insert-Header("Computer Information")
$Info += "Model: $($computerSys.Model)`n"`
		+ "Serial Number: $($BIOS.SerialNumber)`n"`
		+ "RAM: $($RAM)GB`n"`
		+ "OS: $($OS.Caption)`n"`
		+ "OS Version: $($OSVersion)`n"`
		+ "BIOS: $($BIOS.Manufacturer)  - $($BIOS.Description)`n"`
        + "Warranty Ends: $(Dell-Warranty $BIOS.SerialNumber) `n`n"`

if (Test-Path "HKLM:\Software\Microsoft\Deployment 4")
{
    $Info += Insert-Header("Deployment Information")
	$HKLM = Get-ItemProperty -path "HKLM:\Software\Microsoft\Deployment 4"
	$Info += "Deployment Time: " + ([WMI]'').ConvertToDateTime($HKLM.'Deployment Timestamp') + "`n"`
	+ "Deployment Name: " + $HKLM.'Task Sequence ID' + " - " + $HKLM.'Task Sequence Version' + "`n`n"
}


# Mapped Drives
$Info += Insert-Header("Mapped Drives")
$Info += (Get-PSDrive -PSProvider FileSystem) |`
		Select-Object Name,`
		@{ Name = "Used (GB)"; Expression = { ($_.Used / 1GB).toString("####.##") } },`
		@{ Name = "Free (GB)"; Expression = { ($_.Free / 1GB).toString("####.##") } },`
		@{ Name = "Root"; Expression = { if ($_.DisplayRoot) { $_.DisplayRoot } else { $_.Root } } } |`
		Out-String


# Mapped Printers
$Info += Insert-Header("Installed Printers")
$Info += Get-Printer | Select-Object -ExpandProperty Name | Out-String


# Get the OU of the computer
$OU = ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine" |`
		Select-Object -ExpandProperty Distinguished-Name) -split "," |`
		Where-Object { $_ -match "OU" -and $_ -cmatch "^[^a-z]*$" -and $_ -notmatch "UNI"}).substring(3)

$OldFile = Get-Content -Path "$dir\$ComputerName.txt"

Remove-Item -Path "$dir\$ComputerName.txt"
$Info | Out-File -File "$dir\$ComputerName.txt"
$OldFile | Out-File -File "$dir\$ComputerName.txt" -Append

# SIG # Begin signature block
# MIIX5AYJKoZIhvcNAQcCoIIX1TCCF9ECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAjXQQAWA6/Z1XM
# 8Tmj3EVneEk0FsxiXX2v2A9hnD7DxaCCEp8wggPHMIICr6ADAgECAhAiSLvsHK6q
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
# BAGCNwIBBDAvBgkqhkiG9w0BCQQxIgQgmokRWkRlnEm3Z++/fMxzcjQyTc/uFJfz
# VHug5XZ35zEwDQYJKoZIhvcNAQEBBQAEggEAY0pl/8GMpLi2725EP8p+tWUuC3Ih
# EEF9xKWrWWvDgCyYDthr+YWs5zlsvNx+UKkLL5g97sfVYkjyPvcMrlCTQlK/exL1
# T+8idyvrqFrFsHBrCMAjD0HdDsiZuoZqdv0AKjJM+kPq3iRYw/snPU7SEVUQEPSv
# M0DW2eCCjF/IoF3cwH8nl0GNoy1Zw7rq47sFneQXQxVrW54A0jBhf0tl50MIkHHZ
# z+BActITgw06nLg6VvVjiMNl3wtGxTkatGYqU0v7r4r7c5GtVGxXFeH4ReyrZwTd
# tn6UUjPBpR07feR8l6/m91Rh5684WEhKcrDv08Fnk2v3V4AggTbGaCDuBKGCArkw
# ggK1BgkqhkiG9w0BCQYxggKmMIICogIBATBrMFsxCzAJBgNVBAYTAkJFMRkwFwYD
# VQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVz
# dGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyAgwkVLh/HhRTrTf6oXgwDQYJYIZIAWUD
# BAIBBQCgggEMMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
# MQ8XDTE5MDExNDIwNTUwNVowLwYJKoZIhvcNAQkEMSIEIEJARrpDy1hS+7c0E6RS
# SUGCsyzgzM9L2Cm3FtxJcavTMIGgBgsqhkiG9w0BCRACDDGBkDCBjTCBijCBhwQU
# Psdm1dTUcuIbHyFDUhwxt5DZS2gwbzBfpF0wWzELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gU0hBMjU2IC0gRzICDCRUuH8eFFOtN/qheDANBgkqhkiG9w0B
# AQEFAASCAQBTOgGB0252x+YEyvrCAbz4BEqnwS87AEGJp4eBpLvTij3LjJY+MDdA
# OmtDX96E40B1lvCykULxlg87gF0DLtN7C7qFcsgXA7wRhgExgPMucWdVu9eR/yTC
# 67cLWUjQrvzvs7X0GqXaMWTqg27LJe7e4jeEEOLgnEkOSWIS8udXH/kMwGDqKPRV
# O2yMPb1TBRFSPPdDFRTYIU4k0rueDqcDwzQtITOTY3rItKxEnT46GbNrQCmRa5e2
# +wBjyeGxXGFUulX4dmjT6VmcH/eB1At8lwSjeD76OvjW6EeEz9Na3aojMCe+LTQ+
# ByVc0DFMjsZCT2Z2pqjaeI7UsR5JprrX
# SIG # End signature block
