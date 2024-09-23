<#
.SYNOPSIS

    Gets Autopilot Diagnostics

.EXAMPLE

    PS> .\AutopilotDiagnostics.ps1    

.NOTES
    Version: 1.1
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Adjusted setting tls 1.2 and modified script install to use
                    newer version for diagnostics purposes
                    Added documentation to code

#>

# Enable TLS 1.2 without affecting the status of other protocols
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
# Install NuGET package provider with a minimum version of 2.8.5.201
Install-PackageProvider -Name NuGET -MinimumVersion 2.8.5.201 -Force
# Install Script for diagnostics
Install-Script Get-AutopilotDiagnosticsCommunity -Force
# Run script to get diagnostics
Get-AutopilotDiagnosticsCommunity -Online