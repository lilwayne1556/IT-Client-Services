﻿#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------

#Sample function that provides the location of the script
function Get-ScriptDirectory
{
<#
	.SYNOPSIS
		Get-ScriptDirectory returns the proper location of the script.

	.OUTPUTS
		System.String
	
	.NOTES
		Returns the correct path within a packaged executable.
#>
	[OutputType([string])]
	param ()
	if ($null -ne $hostinvocation)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}

function Update-Filename
{
	if ($StartDate -and $EndDate)
	{
		$script:FormattedFilename = "$StartDate-$EndDate $Filename"
		$labelFilename.Text = $script:FormattedFilename
	}
	else
	{
		$labelFilename.Text = $script:Filename
	}
	
	# Clear error
	$errorprovider.SetError($buttonUploadScreensaver, "")
}

function Update-Calendar
{
	# Using Google's API we can add a calendar event
	$refreshTokenParams = @{
		client_id = $script:Config.Screensaver.API.Client_ID;
		client_secret = $script:Config.Screensaver.API.Client_Secret;
		refresh_token = $script:Config.Screensaver.API.Refresh_Token;
		grant_type = "refresh_token";
	}
	
	$RefreshedToken = Invoke-WebRequest "https://accounts.google.com/o/oauth2/token" -Method POST -Body $refreshTokenParams | ConvertFrom-Json
	$AccessToken = $refreshedToken.access_token
	
	# Has to be in JSON format or else it won't work
	# Dates are in YYYY-MM-dd format
	$request = @{
		end = @{
			date = ($script:CalendarEnd).addD;
		};
		start = @{
			date = $script:CalendarStart;
		};
		summary = $script:Filename;
	} | ConvertTo-Json
	
	$requestUri = "https://www.googleapis.com/calendar/v3/calendars/primary/events"
	
	Invoke-WebRequest -Uri $requestUri -Method POST -Headers @{ Authorization = "Bearer $($AccessToken)" }  -Body $request -ContentType 'application/json'
}

#Sample variable that provides the location of the script
[XML]$Config = Get-Content("\\fsa.ad.uni.edu\IT-CS\GP\Screensaver\Script\Config.xml")

[string]$ScriptDirectory = Get-ScriptDirectory
[string]$Today = [System.DateTime]::Now
[String]$Filename = ""
[String]$FormattedFilename = ""
[String]$StartDate = ""
[String]$EndDate = ""

[String]$CalendarStart = ""
[String]$CalendarEnd = ""
# SIG # Begin signature block
# MIIX5AYJKoZIhvcNAQcCoIIX1TCCF9ECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDJySbpf3+d39vW
# NIkZnpMab4+PP8JMDv4qDtOTJ9dNF6CCEp8wggPHMIICr6ADAgECAhAiSLvsHK6q
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
# BAGCNwIBBDAvBgkqhkiG9w0BCQQxIgQgvhnzcMtWKkkPjOomPvv3eWDlnKmv4ZcN
# Ogyk0hUkijAwDQYJKoZIhvcNAQEBBQAEggEAY0KDkgn9JIhG5oDUjf0YIhFsFFuO
# yL+A9bmnlV+emvCfdSoo73sJTvC+sJhsXU1nbCmf/x7hgdKtWKN48mbdhBxdSeB4
# czftOLprH/EkfHl+wktFMbQ1TF5gF0z2Y3iCuY9Y465Bg6GSOjXfifaA1wXL7m0Y
# LY/FnPLgsGQ8S932yl0qY1ikf/eG9BZ6P6LforwyrctMhsFCMKIUSfZtXm4fWnc2
# d98kON1VDCvpG8WMZIaHi01a+svpBY6qooSjKdaT/WrwruXcKqvW8OhZZMC5tzrh
# 54nkLOGMDk7yQWTONbYr0w0zTNnKHuNlF0Qfu7KzwE50lLXH1FjT8XO9WaGCArkw
# ggK1BgkqhkiG9w0BCQYxggKmMIICogIBATBrMFsxCzAJBgNVBAYTAkJFMRkwFwYD
# VQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVz
# dGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyAgwkVLh/HhRTrTf6oXgwDQYJYIZIAWUD
# BAIBBQCgggEMMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
# MQ8XDTE5MDExNDIxMDE1OVowLwYJKoZIhvcNAQkEMSIEICID1pCDzH5E6GlED+hU
# UjfefPP3UQDH9eJarU+PcBx7MIGgBgsqhkiG9w0BCRACDDGBkDCBjTCBijCBhwQU
# Psdm1dTUcuIbHyFDUhwxt5DZS2gwbzBfpF0wWzELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gU0hBMjU2IC0gRzICDCRUuH8eFFOtN/qheDANBgkqhkiG9w0B
# AQEFAASCAQCdGPoJyQ4xCRy3qgPoLsIICCamu4vZaIVgzjH/sWlolzaDwHWQxqoM
# iyEPSEboCn2TeD3r+ZWbp8hT6P+hb3edqQXedHrrp8XsX9TVwwdcVP1QQPl6mDRc
# F8IhUX0we5J+4gHwMjRHb+C8AWN8l/QRFrjRzbGTi7yDHkhu2BYU2LSptHi+7ysG
# RCHFblen9cd8rWMEmjKmNyl3LrjMHuyIasgBUOKbvwf5XnanCAxwlmRSshK2a3+7
# By48jF7jnWz0elBQ/708aDqT2fmCX2L4Q+RYftqZkYzxGCkZhfxXSnEw1G+fC2uP
# 1wj5JwraLVkj2mTU+GMbUhW31t6GvuJf
# SIG # End signature block