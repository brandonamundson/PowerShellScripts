<#
.SYNOPSIS
    Script to add Active Directory user to an 
    Exchange Distribution Group

.INPUTS
    NONE  

.OUTPUTS
    Log file at $PSScriptRoot\Logs\AddDistroMember.log   

.EXAMPLE
    PS>AddDistributionGroup.ps1 -GroupName <GROUPNAME> -UserName <USERNAME> -ServerName <SERVERFQDN>   

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/22/2024
    Purpose/Change: Initial script development
#>
Param(
    # Name of the Distribution Group to add member to
    [Parameter(Mandatory)]
    [string]
    $GroupName,

    # Username of user to add to Distribution Group
    [Parameter(Mandatory)]
    [string]
    $UserName,

    # Exchange Server for connecting to
    [Parameter(Mandatory)]
    [string]
    $ServerName = "http://<SERVER.FQDN.HERE>/PowerShell"
)
#Requires -RunAsAdministrator

# Create log file and append to it
$LogFile = "$PSScriptRoot\Logs\AddDistroMember.log"
Start-Transcript -path $LogFile -append

# Create a New PS Exchange Session
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ServerName -Authentication Kerberos
# Import PS Exchange Session to current
Import-PSSession $Session

# Output logging message
Write-Output "Adding $UserName to Distribution Group $GroupName"
try
{
    # Add group member from script param and stop if error
    Add-DistributionGroupMember -Identity $GroupName -Member $UserName -ErrorAction Stop
    # If error, the catch block will keep this from executing and output error message
    # else this will output a success
    Write-Output "$UserName added to $GroupName successfully"
}
catch { Write-Output "Adding $UserName to $GroupName failed" }

# Exit and remove all PS Session(s) to prevent any confilcts on subsequent runs
Exit-PSSession
Get-PSSession | Remove-PSSession

Stop-Transcript
[GC]::Collect()