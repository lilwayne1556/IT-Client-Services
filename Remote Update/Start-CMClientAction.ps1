##########################################################
#Script Title: Start SCCM Client Action PowerShell Tool
#Script File Name: Start-CMClientAction.ps1
#Author: Ron Ratzlaff
#Date Created: 4/19/2016
#Updated: 5/23/2017
#Update Notes: Please refer to the TechNet Gallery at: https://gallery.technet.microsoft.com/Start-SCCM-Client-Actions-d3d84c3c
##########################################################


#Requires -Version 3.0

Function Start-CMClientAction
{
    <#
      .SYNOPSIS

          The "Start-CMClientAction" function allows 49 different SCCM client actions to be initiated on one, or more computers.

      .DESCRIPTION

          The "Start-CMClientAction" PowerShell function allows for the initiaion of 49 SCCM client actions that can be ran on the local computer, or remote computers. Only one client action can be ran at a time, so using an array to include several client actions is not allowed. The Configuration Manager applet in Control Panel on the Actions tab lists 10 actions and these are identified in the Notes section with a "ConfigMgr Control Panel Applet" in parenthesis. SCCM Administrators typically find themselves running the following 3 actions during their monthly software update deployments (patching): Machine Policy Retrieval & Evaluation Cycle, Software Updates Scan Cycle, and Software Updates Deployment Evaluation Cycle. Because these 3 actions are so common, I decided to offer a way to bundle them with a 5 minute wait time (300 seconds) between each action. The parameter to use to run these 3 bundled actions is the '-SCCMActionsBundle' parameter. The 'SCCMClientAction' and the 'SCCMActionsBundle' parameters are members of different parameter sets, so they cannot be used together.

      .PARAMETER ComputerName

          Enter the name of one or more computers that you wish to initiate an SCCM client action on.

      .PARAMETER SCCMClientAction

          Enter a numerical value from 1-49 that represents each SCCM client action listed in the Notes section under ther "SCCM Client Action Trigger Codes" heading.

      .PARAMETER SCCMActionsBundle

          A switch parameter that does not accept any values, but rather tells the function to run the following 3 actions listed in the Notes section under ther "SCCM Client Action Trigger Codes" heading:

          * Option 7 - Request Machine Assignments - (ConfigMgr Control Panel Applet - Machine Policy Retrieval & Evaluation Cycle)
          * Option 38 - Scan by Update Source - (ConfigMgr Control Panel Applet - Software Updates Scan Cycle)
          * Option 33 - Software Updates Assignments Evaluation Cycle - (ConfigMgr Control Panel Applet - Software Updates Deployment Evaluation Cycle)

      .EXAMPLE

          Initiate an SCCM Client Action on the Local Computer

          Start-CMClientAction -SCCMClientAction 1

      .EXAMPLE

          Initiate an SCCM Client Action on a Remote Computer

          Start-CMClientAction -ComputerName 'RemoteComputer1' -SCCMClientAction 1

      .EXAMPLE

          Initiate an SCCM Client Action on Multiple Remote Computers

          Start-CMClientAction -ComputerName 'RemoteComputer1', 'RemoteComputer2', 'RemoteComputer3' -SCCMClientAction 1

      .EXAMPLE

          Initiate an SCCM Client Action on Multiple Remote Computers Using a List of Computers in a Text File

          Start-CMClientAction -ComputerName (Get-Content -Path "$env:userprofile\desktop\RemoteComputerList.txt") -SCCMClientAction 1

       .EXAMPLE

          Initiate an SCCM Client Action Bundle on the Local Computer that Runs Options 7, 38, and 33 (Machine Policy Retrievale & Evaluation Cycle, Software Updates Scan Cycle, and Software Updates Deployment Evaluation Cycle)

          Start-CMClientAction -SCCMActionsBundle

       .EXAMPLE

          Initiate an SCCM Client Action Bundle on a Remote Computer that Runs Options 7, 38, and 33 (Machine Policy Retrievale & Evaluation Cycle, Software Updates Scan Cycle, and Software Updates Deployment Evaluation Cycle)

          Start-CMClientAction -ComputerName 'RemoteComputer1' -SCCMActionsBundle

       .EXAMPLE

          Initiate an SCCM Client Action Bundle on Multiple Remote Computers that Runs Options 7, 38, and 33 (Machine Policy Retrievale & Evaluation Cycle, Software Updates Scan Cycle, and Software Updates Deployment Evaluation Cycle)

          Start-CMClientAction -ComputerName 'RemoteComputer1', 'RemoteComputer2', 'RemoteComputer3' -SCCMActionsBundle

       .EXAMPLE

          Initiate an SCCM Client Action Bundle on Multiple Remote Computers Using a List of Computers in a Text File that Runs Options 7, 38, and 33 (Machine Policy Retrievale & Evaluation Cycle, Software Updates Scan Cycle, and Software Updates Deployment Evaluation Cycle)

          Start-CMClientAction -ComputerName (Get-Content -Path "$env:userprofile\desktop\RemoteComputerList.txt") -SCCMActionsBundle

        .NOTES

          SCCM Client Action Trigger Codes
          --------------------------------

          1 - {00000000-0000-0000-0000-000000000001} Hardware Inventory - (ConfigMgr Control Panel Applet - Hardware Inventory Cycle)
          2 - {00000000-0000-0000-0000-000000000002} Software Inventory - (ConfigMgr Control Panel Applet - Software Inventory Cycle)
          3 - {00000000-0000-0000-0000-000000000003} Discovery Inventory - (ConfigMgr Control Panel Applet - Discovery Data Collection Cycle)
          4 - {00000000-0000-0000-0000-000000000010} File Collection - (ConfigMgr Control Panel Applet - File Collection Cycle)
          5 - {00000000-0000-0000-0000-000000000011} IDMIF Collection
          6 - {00000000-0000-0000-0000-000000000012} Client Machine Authentication
          7 - {00000000-0000-0000-0000-000000000021} Request Machine Assignments - (ConfigMgr Control Panel Applet - Machine Policy Retrieval & Evaluation Cycle)
          8 - {00000000-0000-0000-0000-000000000022} Evaluate Machine Policies
          9 - {00000000-0000-0000-0000-000000000023} Refresh Default MP Task
          10 - {00000000-0000-0000-0000-000000000024} LS (Location Service) Refresh Locations Task
          11 - {00000000-0000-0000-0000-000000000025} LS (Location Service) Timeout Refresh Task
          12 - {00000000-0000-0000-0000-000000000026} Policy Agent Request Assignment (User)
          13 - {00000000-0000-0000-0000-000000000027} Policy Agent Evaluate Assignment (User) - (ConfigMgr Control Panel Applet - User Policy Retrieval & Evaluation Cycle)
          14 - {00000000-0000-0000-0000-000000000031} Software Metering Generating Usage Report
          15 - {00000000-0000-0000-0000-000000000032} Source Update Message - (ConfigMgr Control Panel Applet - Windows Installer Source List Update Cycle)
          16 - {00000000-0000-0000-0000-000000000037} Clearing Proxy Settings Cache
          17 - {00000000-0000-0000-0000-000000000040} Machine Policy Agent Cleanup
          18 - {00000000-0000-0000-0000-000000000041} User Policy Agent Cleanup
          19 - {00000000-0000-0000-0000-000000000042} Policy Agent Validate Machine Policy/Assignment
          20 - {00000000-0000-0000-0000-000000000043} Policy Agent Validate User Policy/Assignment
          21 - {00000000-0000-0000-0000-000000000051} Retrying/Refreshing Certificates in AD on MP
          22 - {00000000-0000-0000-0000-000000000061} Peer DP Status Reporting
          23 - {00000000-0000-0000-0000-000000000062} Peer DP Pending Package Check Schedule
          24 - {00000000-0000-0000-0000-000000000063} SUM Updates Install Schedule
          25 - {00000000-0000-0000-0000-000000000071} NAP action
          26 - {00000000-0000-0000-0000-000000000101} Hardware Inventory Collection Cycle
          27-  {00000000-0000-0000-0000-000000000102} Software Inventory Collection Cycle
          28 - {00000000-0000-0000-0000-000000000103} Discovery Data Collection Cycle
          29 - {00000000-0000-0000-0000-000000000104} File Collection Cycle
          30 - {00000000-0000-0000-0000-000000000105} IDMIF Collection Cycle
          31 - {00000000-0000-0000-0000-000000000106} Software Metering Usage Report Cycle
          32 - {00000000-0000-0000-0000-000000000107} Windows Installer Source List Update Cycle
          33 - {00000000-0000-0000-0000-000000000108} Software Updates Assignments Evaluation Cycle - (ConfigMgr Control Panel Applet - Software Updates Deployment Evaluation Cycle)
          34 - {00000000-0000-0000-0000-000000000109} Branch Distribution Point Maintenance Task
          35 - {00000000-0000-0000-0000-000000000110} DCM Policy
          36 - {00000000-0000-0000-0000-000000000111} Send Unsent State Message
          37 - {00000000-0000-0000-0000-000000000112} State System Policy Cache Cleanout
          38 - {00000000-0000-0000-0000-000000000113} Scan by Update Source - (ConfigMgr Control Panel Applet - Software Updates Scan Cycle)
          39 - {00000000-0000-0000-0000-000000000114} Update Store Policy
          40 - {00000000-0000-0000-0000-000000000115} State System Policy Bulk Send High
          41 - {00000000-0000-0000-0000-000000000116} State System Policy Bulk Send Low
          42 - {00000000-0000-0000-0000-000000000120} AMT Status Check Policy
          43 - {00000000-0000-0000-0000-000000000121} Application Manager Policy Action - (ConfigMgr Control Panel Applet - Application Deployment Evaluation Cycle)
          44 - {00000000-0000-0000-0000-000000000122} Application Manager User Policy Action
          45 - {00000000-0000-0000-0000-000000000123} Application Manager Global Evaluation Action
          46 - {00000000-0000-0000-0000-000000000131} Power Management Start Summarizer
          47 - {00000000-0000-0000-0000-000000000221} Endpoint Deployment Reevaluate
          48 - {00000000-0000-0000-0000-000000000222} Endpoint AM Policy Reevaluate
          49 - {00000000-0000-0000-0000-000000000223} External Event Detection
    #>

    [cmdletbinding()]

    Param
    (
        [Parameter(ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True,
            HelpMessage='Enter the name of either one or more computers')]

            [Alias('CN')]
            $ComputerName = $env:COMPUTERNAME,

        [Parameter(ParameterSetName = 'Set 1',
            HelpMessage='Enter the SCCM client action numerical value')]
            [ValidateNotNullOrEmpty()]
            [ValidateRange(1,49)]
            [Alias('SCA')]
            [Int]$SCCMClientAction,

        [Parameter(ParameterSetName = 'Set 2',
            HelpMessage='Use this switch parameter to run the following 3 SCCM client actions: Machine Policy Retrieval & Evaluation Cycle, Software Updates Scan Cycle, and Software Updates Deployment Evaluation Cycle')]
            [Alias('SAB')]
            [Switch]$SCCMActionsBundle
    )

    Begin
    {
        $NewLine = "`r`n"

        If ($ComputerName -eq $env:COMPUTERNAME)
        {
            $ComputerVar = $ComputerName.ToUpper()
        }

        Else
        {
            $NewLine
            Write-Output -Verbose "======================================================="
            $NewLine
            Write-Output -Verbose "            Check Computer(s) Online Status            "
            $NewLine
            Write-Output -Verbose "======================================================="
            $NewLine

            $ComputerOnlineStatus = Foreach ($Computer in $ComputerName)
            {
                    $Online = @(ForEach-Object -Process { If (Test-Connection -ComputerName $Computer -Count '1' -Quiet) { $Computer } })

                    $Offline = @(ForEach-Object -Process { If (!(Test-Connection -ComputerName $Computer -Count '1' -Quiet)) { $Computer } })

                    [pscustomobject] @{
                        'Online' = $Online;
                        'Offline' = $Offline
                    }
            }

                $ComputerVar = ($ComputerOnlineStatus.Online).ToUpper()

                $NewLine

                Write-Output -Verbose "---------- Computer(s) Online ----------"

                $NewLine

                If ($ComputerOnlineStatus.Online)
                {
                    ($ComputerOnlineStatus.Online).ToUpper()

                    $NewLine
                }

                Else
                {
                    Write-Output -Verbose 'N/A'

                    $NewLine
                }

                Write-Output -Verbose "---------- Computer(s) Offline ----------"

                $NewLine

                If ($ComputerOnlineStatus.Offline)
                {
                    ($ComputerOnlineStatus.Offline).ToUpper()

                    $NewLine
                }

                Else
                {
                    Write-Output -Verbose 'N/A'

                    $NewLine
                }
        }
    }

    Process
    {
        Switch ($SCCMClientAction)
        {
            '1' { $ClientAction = '{00000000-0000-0000-0000-000000000001}' }
            '2' { $ClientAction = '{00000000-0000-0000-0000-000000000002}' }
            '3' { $ClientAction = '{00000000-0000-0000-0000-000000000003}' }
            '4' { $ClientAction = '{00000000-0000-0000-0000-000000000010}' }
            '5' { $ClientAction = '{00000000-0000-0000-0000-000000000011}' }
            '6' { $ClientAction = '{00000000-0000-0000-0000-000000000012}' }
            '7' { $ClientAction = '{00000000-0000-0000-0000-000000000021}' }
            '8' { $ClientAction = '{00000000-0000-0000-0000-000000000022}' }
            '9' { $ClientAction = '{00000000-0000-0000-0000-000000000023}' }
            '10' { $ClientAction = '{00000000-0000-0000-0000-000000000024}' }
            '11' { $ClientAction = '{00000000-0000-0000-0000-000000000025}' }
            '12' { $ClientAction = '{00000000-0000-0000-0000-000000000026}' }
            '13' { $ClientAction = '{00000000-0000-0000-0000-000000000027}' }
            '14' { $ClientAction = '{00000000-0000-0000-0000-000000000031}' }
            '15' { $ClientAction = '{00000000-0000-0000-0000-000000000032}' }
            '16' { $ClientAction = '{00000000-0000-0000-0000-000000000037}' }
            '17' { $ClientAction = '{00000000-0000-0000-0000-000000000040}' }
            '18' { $ClientAction = '{00000000-0000-0000-0000-000000000041}' }
            '19' { $ClientAction = '{00000000-0000-0000-0000-000000000042}' }
            '20' { $ClientAction = '{00000000-0000-0000-0000-000000000043}' }
            '21' { $ClientAction = '{00000000-0000-0000-0000-000000000051}' }
            '22' { $ClientAction = '{00000000-0000-0000-0000-000000000061}' }
            '23' { $ClientAction = '{00000000-0000-0000-0000-000000000062}' }
            '24' { $ClientAction = '{00000000-0000-0000-0000-000000000063}' }
            '25' { $ClientAction = '{00000000-0000-0000-0000-000000000071}' }
            '26' { $ClientAction = '{00000000-0000-0000-0000-000000000101}' }
            '27' { $ClientAction = '{00000000-0000-0000-0000-000000000102}' }
            '28' { $ClientAction = '{00000000-0000-0000-0000-000000000103}' }
            '29' { $ClientAction = '{00000000-0000-0000-0000-000000000104}' }
            '30' { $ClientAction = '{00000000-0000-0000-0000-000000000105}' }
            '31' { $ClientAction = '{00000000-0000-0000-0000-000000000106}' }
            '32' { $ClientAction = '{00000000-0000-0000-0000-000000000107}' }
            '33' { $ClientAction = '{00000000-0000-0000-0000-000000000108}' }
            '34' { $ClientAction = '{00000000-0000-0000-0000-000000000109}' }
            '35' { $ClientAction = '{00000000-0000-0000-0000-000000000110}' }
            '36' { $ClientAction = '{00000000-0000-0000-0000-000000000111}' }
            '37' { $ClientAction = '{00000000-0000-0000-0000-000000000112}' }
            '38' { $ClientAction = '{00000000-0000-0000-0000-000000000113}' }
            '39' { $ClientAction = '{00000000-0000-0000-0000-000000000114}' }
            '40' { $ClientAction = '{00000000-0000-0000-0000-000000000115}' }
            '41' { $ClientAction = '{00000000-0000-0000-0000-000000000116}' }
            '42' { $ClientAction = '{00000000-0000-0000-0000-000000000120}' }
            '43' { $ClientAction = '{00000000-0000-0000-0000-000000000121}' }
            '44' { $ClientAction = '{00000000-0000-0000-0000-000000000122}' }
            '45' { $ClientAction = '{00000000-0000-0000-0000-000000000123}' }
            '46' { $ClientAction = '{00000000-0000-0000-0000-000000000131}' }
            '47' { $ClientAction = '{00000000-0000-0000-0000-000000000221}' }
            '48' { $ClientAction = '{00000000-0000-0000-0000-000000000222}' }
            '49' { $ClientAction = '{00000000-0000-0000-0000-000000000223}' }
        }

        If (!($PSBoundParameters.Keys.Contains('SCCMActionsBundle')))
        {
            Foreach ($Computer in $ComputerVar)
            {
               Try
               {
                    $NewLine

                    Invoke-WmiMethod -ComputerName $Computer -Namespace root\ccm -Class sms_client -Name TriggerSchedule -ArgumentList $ClientAction -ErrorAction Stop

                    $NewLine

                    Write-Output -Verbose "The specified SCCM client action was successfully initiated on computer $Computer"

                    $NewLine
                }

                Catch
                {
                    $NewLine

                    Write-Warning -Message "The following error occurred when trying to run the specified SCCM client action on computer ${Computer}: $_"

                    $Newline
                }
            }
        }

        Else
        {
            Foreach ($Computer in $ComputerVar)
            {
                Write-Output -Verbose '---------- Running SCCM Client Actions Bundle ----------'

                Try
                {
                    $NewLine

                    Write-Output -Verbose '==========================================='
                    Write-Output -Verbose 'Machine Policy Retrieval & Evaluation Cycle'
                    Write-Output -Verbose '==========================================='

                    $NewLine

                    Invoke-WmiMethod -ComputerName $Computer -Namespace root\ccm -Class sms_client -Name TriggerSchedule -ArgumentList '{00000000-0000-0000-0000-000000000021}' -ErrorAction Stop

                    $NewLine

                    Write-Output -Verbose 'Machine Policy Retrieval and Evaluation Cycle action successfully initiated'

                    $NewLine

                    Write-Output -Verbose 'Waiting 1 minutes before running next SCCM client action...'

                    Start-Sleep -Seconds 60

                    $NewLine
                }

                Catch
                {
                    $NewLine

                    Write-Warning -Message "The following error occurred when trying to run the specified SCCM client action on computer ${Computer}: $_"

                    $Newline

                    Break
                }

                Try
                {
                    $NewLine

                    Write-Output -Verbose '==========================='
                    Write-Output -Verbose 'Software Updates Scan Cycle'
                    Write-Output -Verbose '==========================='

                    $NewLine

                    Invoke-WmiMethod -ComputerName $Computer -Namespace root\ccm -Class sms_client -Name TriggerSchedule -ArgumentList '{00000000-0000-0000-0000-000000000113}' -ErrorAction Stop

                    $NewLine

                    Write-Output -Verbose 'Software Updates Scan Cycle action successfully initiated'

                    $NewLine

                    Write-Output -Verbose 'Waiting 1 minutes before running next SCCM client action...'

                    Start-Sleep -Seconds 60

                    $NewLine
                }

                Catch
                {
                    $NewLine

                    Write-Warning -Message "The following error occurred when trying to run the specified SCCM client action on computer ${Computer}: $_"

                    $Newline

                    Break
                }

                Try
                {
                    $NewLine

                    Write-Output -Verbose '============================================'
                    Write-Output -Verbose 'Software Updates Deployment Evaluation Cycle'
                    Write-Output -Verbose '============================================'

                    $NewLine

                    Invoke-WmiMethod -ComputerName $Computer -Namespace root\ccm -Class sms_client -Name TriggerSchedule -ArgumentList '{00000000-0000-0000-0000-000000000108}' -ErrorAction Stop

                    $NewLine

                    Write-Output -Verbose 'Software Updates Deployment Evaluation Cycle action successfully initiated'

                    $NewLine

                    Write-Output -Verbose 'Waiting 1 minutes before running next SCCM client action...'

                    Start-Sleep -Seconds 60

                    $NewLine
                }

                Catch
                {
                    $NewLine

                    Write-Warning -Message "The following error occurred when trying to run the specified SCCM client action on computer ${Computer}: $_"

                    $Newline

                    Break
                }
            }
        }
    }

    End {}
}

# SIG # Begin signature block
# MIIX5AYJKoZIhvcNAQcCoIIX1TCCF9ECAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAkooWSH0Jk+kMl
# 5LDc0RCrODZbmYfTI8BpB6yKDbnwwqCCEp8wggPHMIICr6ADAgECAhAiSLvsHK6q
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
# BAGCNwIBBDAvBgkqhkiG9w0BCQQxIgQgIMB24Fzk09NiTVhO9ZHTqACFN90CHLej
# j9OtKASsiqkwDQYJKoZIhvcNAQEBBQAEggEAYFa//95B2bUuk91d7yFTJuSCer+k
# PIZ6GIbvcllZt9FHRujMvbHtwhXlsx75Q0nS8NlHmxF4iYgaVokDRjhFRde69z1q
# wS+Vw9TImsazp7NcOaBauAafdbTRjWJru9llzjlMfyfQh9adJzaFN5Nle1tBKmuj
# TKcTfdNEwD8STFhThafaluBP0rRC0JhbW2J+ilQDwEtNGXLnFzvSpY5Aatu9ASE4
# n/xYbHTUNNzwqEFagHZfpPm6P0MRW+VnE3KhLx1AWHtd9b1GkzKMRcg27i/du5l9
# mTo6jN1nA6NHyAQTlMsBslCSzT0l7lnE+d4qvkIWPYZJ9oTNbBow0G4yNqGCArkw
# ggK1BgkqhkiG9w0BCQYxggKmMIICogIBATBrMFsxCzAJBgNVBAYTAkJFMRkwFwYD
# VQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVz
# dGFtcGluZyBDQSAtIFNIQTI1NiAtIEcyAgwkVLh/HhRTrTf6oXgwDQYJYIZIAWUD
# BAIBBQCgggEMMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
# MQ8XDTE5MDEwNDE1NDUzNlowLwYJKoZIhvcNAQkEMSIEIL5TbyNpyNZ+Ax1GuIMx
# Xz7n4NUS6W/aBJ6Xis/qVxAPMIGgBgsqhkiG9w0BCRACDDGBkDCBjTCBijCBhwQU
# Psdm1dTUcuIbHyFDUhwxt5DZS2gwbzBfpF0wWzELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gU0hBMjU2IC0gRzICDCRUuH8eFFOtN/qheDANBgkqhkiG9w0B
# AQEFAASCAQDAfb+09cRz/k6yLaLSkDUvnJbnmZUUePdPfI2gxWl1p/24AI6YwqIe
# SXAHjcK8lOy4f07TFTj+YPbhNTj+p6EUF1nfxL4A1/OBTrODPA3FcOUnjeq3oO5T
# S5cTN4G66z/Uw29UsXRWECg6RsHr27V2vhelwtIYQR8yhMYISHcoa+ZS3Ig8NwcO
# KE9Z7LuESfse++ABc/Utxv0iFNMMnWcwhveDqmIAhT6cW6Ct/oDBgQfDVgFWkYch
# 82RNO6BAcQsP5FnZpk+FmX1MXNHI8YT+QgeJ71eEkjq8ZFgL1PSLfb/zazBEz6Fl
# 6ZusBdcz3lkK0aF/QlHczVetwAKoEF6U
# SIG # End signature block
