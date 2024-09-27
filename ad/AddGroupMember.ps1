<#
.SYNOPSIS
    Add AD User to AD Group
   
.INPUTS
    NONE

.OUTPUTS
    Log file at PSScriptRoot\Logs\AddGroupMember.log

.EXAMPLE
    PS>AddGroupMember.ps1 -GroupName <GROUPNAME> -UserName <USERNAME>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development
#>
Param(
    # Name of AD Group to add member to
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $GroupName,

    # Username of AD User to add to group
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $UserName
)
#Requires -RunAsAdministrator

# Create log file or append to existing
$LogFile = "$PSScriptRoot\Logs\AddGroupMember.log"
Start-Transcript -Path $LogFile -Append

# Log message
Write-Output "Adding $UserName to Group $GroupName"
# Add Group Member
Add-ADGroupMember -Identity $GroupName -Members $UserName

# Verify user was added to group by getting all users in AD Group
$a = (Get-ADGroupMember -Identity $GroupName | Select-Object SamAccountName).SamAccountName
# If user is in group, output success, else output fail
if($a.contains($UserName)) { Write-Output "$UserName added to $GroupName successfully" }
else { Write-Output "Adding $UserName to $GroupName failed" }

Stop-Transcript