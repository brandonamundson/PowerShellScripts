<#
.SYNOPSIS

    Adds device to Autopilot with given Group Tag

.EXAMPLE

    PS> .\Autopilot.ps1    

.NOTES
    Version: 1.1
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Adjusted setting tls 1.2 and modified script install to use
                    newer version for diagnostics purposes
                    Added documentation to code

#>

Param(
    # Group Tag used for Intune Provisioning
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $GroupTag
)


# Enable TLS 1.2 without affecting the status of other protocols
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
# Set Execution Policy to allow scripts to be ran
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
# Install NuGET package provider with a minimum version of 2.8.5.201
Install-PackageProvider -Name NuGET -MinimumVersion 2.8.5.201 -Force
# Install Script to add device to Autopilot
Install-Script -name Get-WindowsAutopilotInfo -Force
# Install Script in case of need later for diagnostics
Install-Script -name Get-AutopilotDiagnosticsCommunity -Force
# Run script to add device to Autopilot using given Group Tag
Get-WindowsAutopilotInfo -Online -Reboot -GroupTag $GroupTag
# Reboot immediately
shutdown /r /t 0