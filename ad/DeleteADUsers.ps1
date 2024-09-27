<#
.SYNOPSIS
    Script to delete a specific set of users that have
    been disabled for 30 days or more

.INPUTS
    NONE

.OUTPUTS
    Log file

.EXAMPLE
    PS>DeleteADUsers.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development

#>
#Requires -RunAsAdministrator

# Get formatted date and start logging
$Date = Get-Date -UFormat "%Y-%m-%d"
Start-Transcript -Path "$PSScriptRoot\Logs\DeleteADUsers\DeleteUsersPast30days_$Date.log"

# Get all users in Pending Deletion OU, select display name, date changed, and user name
$users = (Get-AdUser -Filter * -SearchBase "*OU=Pending Deletion*" -Properties * |
    Sort-Object DisplayName | Select-Object DisplayName,whenChanged,SamAccountName)

# For all users matching filter
foreach($user in $users) {
    $username = $user.DisplayName
    $san = $user.SamAccountName
    $dateChanged = $user.whenChanged

    # Check if date changed is before 30 days
    if($dateChanged -lt ((get-date).AddDays(-30))) {
        # Log message and remove account
        Write-Host "Removing user $username who has been pending deletion over 30 days"
        Remove-ADUser -Identity $san -Confirm:$false
    }

}
Stop-Transcript