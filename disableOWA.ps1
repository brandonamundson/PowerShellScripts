<#
.DESCRIPTION
    Disables OWA access with Exchange Online Powershell

.INPUTS
    user - username to disable OWA for
    admin - admin with capability to do so

.OUTPUTS
    NONE   

.EXAMPLE
    PS>disableOWA.ps1 -user <USER> -admin <ADMIN>

.EXAMPLE
    PS>disableOWA.psq <USER> <ADMIN>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 10/08/2024
    Purpose/Change: Initial script development
#>
Param(
    # username to modify OWA access for
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $user,
    # administrator with privileges to modify OWA access
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $admin
)

#Requires -RunAsAdministrator
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName $admin

Start-Transcript -Path C:\Scripts\Logs\disableOWA.log -Append
Set-CASMailbox -Identity $user -OWAEnabled $false
Remove-Module ExchangeOnlineManagement
Stop-Transcript