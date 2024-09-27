<#
.SYNOPSIS
    Gets members of a On-Prem Distribution Group

.INPUTS
    Name of distribution group
    Connection URI   

.OUTPUTS
    None

.EXAMPLE
    PS>GetDistributionGroup.ps1 -GroupName <GROUPNAME> -ConnectionUri http://<FQDNHOSTNAME>/PowerShell
    PS>GetDistributionGroup.ps1 <GROUPNAME> http://<FQDNHOSTNAME>/PowerShell

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/25/2024
    Purpose/Change: Initial script development
#>
Param(
    # Name of Distribution Group in Exchange
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $GroupName,
    # ConnectionUri aka FQDN of host to connect
    [Parameter(Mandatory)]
    [string]
    $ConnectionUri
)
#Requires -RunAsAdministrator

# Create PS Session to Exchange Server
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionUri -Authentication Kerberos
# Import PS Session
Import-PSSession $Session

# Output blank line
Write-Host "`n"
# Get and output all members in group
(Get-DistributionGroupMember -identity $GroupName).SamAccountName

# Close session and cleanup all imported members to prevent collisions
Exit-PSSession
Get-PSSession | Remove-PSSession
[GC]::Collect()