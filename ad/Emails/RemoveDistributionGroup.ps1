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
    Version: 1.1
    Author: Brandon Amundson
    Creation Date: 09/26/2024
    Purpose/Change: Improving error handling
#>
Param(
	# Name of Exchange Distribution Group to remove user to
	[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory)]
	[string]
	$GroupName,
	# Username of AD User to remove group from
	[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory)]
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
Start-Transcript -Path $LogFile -Append

# Output logging message then create and import session
Write-Output "Removing $UserName from Distribution Group $GroupName"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionUri -Authentication Kerberos
Import-PSSession $Session

# Remove group member and output success if complete
try {
	Remove-DistributionGroupMember -Identity $GroupName -Member $UserName -Confirm:$True -ErrorAction Stop
	Write-Output "$UserName removed from $GroupName successfully"
}
# If removal fails, output failure
catch {
	Write-Output "Removing $UserName from GroupName failed"
}

# End PS Session and cleanup
Exit-PSSession
Get-PSSession | Remove-PSSession
Stop-Transcript
[GC]::Collect()