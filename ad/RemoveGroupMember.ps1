<#
.SYNOPSIS
    Adds a given AD user to an AD Security Group

.INPUTS
    AD Group Name
    Username

.OUTPUTS
    Transcription log file

.EXAMPLE
    PS>RemoveGroupMember.ps1 -GroupName <GROUPNAME> -UserName <USERNAME>
    PS>RemoveGroupMember.ps1 <GROUPNAME> <USERNAME>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/26/2024
    Purpose/Change: Initial script development
#>
Param(
    # AD Group name to remove user from
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $GroupName,

    # Username of AD User to remove from AD Group
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $UserName
)
#Requires -RunAsAdministrator

# Start logging and create/append to file as needed
$LogFile = "$PSScriptRoot\Logs\RemoveGroupMember.log"
Start-Transcript -Path $LogFile -append

# Write Output
Write-Output "Removing $UserName from Distribution Group $GroupName"

# If group was removed, output true
if(Remove-ADGroupMember -Identity $GroupName -Members $UserName -Confirm:$True) {
    Write-Output "$UserName removed from $GroupName successfully"
}
# Otherwise output false
else { Write-Output "Removing $UserName from GroupName failed" }

Stop-Transcript