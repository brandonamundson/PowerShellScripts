<#
.SYNOPSIS
    Script to restart a given service using Sysinternals tools

.INPUTS
    sysinternalsPath
    computerName
    serviceName

.OUTPUTS
    NONE

.EXAMPLE
    PS>restartService.ps1 -sysinternalsPath <PATH> -computerName <HOSTNAME> -serviceName <SERVICENAME>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 10/06/2024
    Purpose/Change: Initial script development
#>
param(
    [Mandatory]
    [string]
    $sysinternalsPath,
    [Mandatory]
    [string]
    $computerName,
    [mandatory]
    [string]
    $serviceName
)
#Requires -RunAsAdministrator

Set-Location $sysinternalsPath
.\PsKill.exe -t \\$computerName $serviceName
.\PsService.exe \\$computerName restart $serviceName