<#
.SYNOPSIS
    Adds user to a Distribution Group in an On-Prem exchange server

.INPUTS
    Distribution Group Name
    Username
    Connection URI

.OUTPUTS
    Transaction log file

.EXAMPLE
    PS>RemoveDistributionGroup.ps1 -GroupName <GROUPNAME> -UserName <USERNAME> -ConnectionUri http://<FQDNHOSTNAME>/PowerShell
    PS>RemoveDistributionGroup.ps1 <GROUPNAME> <USERNAME> http://<FQDNHOSTNAME>/PowerShell

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/26/2024
    Purpose/Change: Initial script development
#>
Param(
    # Name of Exchange Distribution Group to remove user to
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $GroupName,
    # Username of AD User to remove group from
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $UserName,
    # Server FQDN that hosts Exchange in http://<FQDN>/PowerShell format
    [Parameter(Mandatory)]
    [string]
    $ConnectionUri
)
#Requires -RunAsAdministrator

# Start log file, append to previous if exists
$LogFile = "$PSScriptRoot\Logs\RemoveDistroMember.log"
Start-Transcript -path $LogFile -append

# Output logging message then create and import session
Write-Output "Removing $UserName from Distribution Group $GroupName"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionUri -Authentication Kerberos
Import-PSSession $Session

# Remove group member and output success if complete
if(Remove-DistributionGroupMember -identity $GroupName -member $UserName -confirm:$True) { 
    Write-Output "$UserName removed from $GroupName successfully"
}
# If removal fails, output failure
else { Write-Output "Removing $UserName from GroupName failed" }

# End PS Session and cleanup
Exit-PSSession
get-pssession | remove-pssession
Stop-Transcript
[GC]::Collect()