<#
.SYNOPSIS
    Script to connect to on prem server with Entra AD Sync and running
    an AD Sync Delta type Sync Cycle

.INPUTS
    Server Name - Name of the server with Entra AD Sync installed

.OUTPUTS
    NONE

.EXAMPLE
    PS>adsync.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/29/2024
    Purpose/Change: Initial script development
#>
Param(
    # Name of server with Entra AD Sync installed
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $serverName
)

# Create PS Session to Server w/ Entra AD Sync
$Session = New-PSSession -ComputerName $serverName -Authentication Kerberos
# Output logging messages to Host
Write-Output "Started at $(Get-Date -Format 'MM/dd/yyyy hh:mm')"
Write-Output "importing module adsync"
# Import AD Sync module in PS Session
Invoke-Command -Session $session -ScriptBlock { Import-Module adsync }
# Output logging message to Host
Write-Output "starting adsync cycle"
# Run Start-ADSyncSyncCycle with policy type delta in PS Session and get the result
$result = Invoke-Command -Session $session -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta; $lastexitcode }
# Output status result of Start-ADSyncSyncCycle
Write-Output $result | Select-Object result
# PSSession cleanup
Get-PSSession | Remove-PSSession
[GC]::Collect()
