<#
.SYNOPSIS
    Convert an On-Prem Remote Mailbox to shared and run an AD Sync

.EXAMPLE
    PS>ConvertToShared.ps1 -UserName <USERNAME> -ServerName <SERVERNAME>

.INPUTS
    UserName - name of user mailbox to convert to shared
    ServerName - name of Exchange Server

.OUTPUTS
    NONE

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 10/07/2024
    Purpose/Change: Initial script development
#>
Param(
    # Username of mailbox to convert from user to shared
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $UserName,
    
    # Exchange Server for connecting to
    [Parameter(Mandatory)]
    [string]
    $ServerName = "http://<SERVER.FQDN.HERE>/PowerShell"
)

#Requires -RunAsAdministrator
# Create and import Session
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ServerName -Authentication Kerberos
Import-PSSession $session

# Set remote mailbox as shared
Set-RemoteMailbox $UserName -Type Shared

# Remind to run ADSync
Write-Host "Don't forget to run an AD Sync to push to cloud!" -ForegroundColor Cyan -BackgroundColor DarkGray | Out-Default

# Remove Session and cleanup
Get-PSSession | Remove-PSSession
[GC]::Collect()