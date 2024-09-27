<#
.SYNOPSIS
    Script that checks for all expired users and disables them, then moves them to
    a target OU for later deletion
   
.INPUTS
    NONE

.OUTPUTS
    Transcript log at $PSScriptRoot\DisableExpiredUsers\
   
.EXAMPLE
    PS>ADDisableExpiredUsers.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/22/2024
    Purpose/Change: Initial script development
#>
#Requires -RunAsAdministrator

# Get date in Y-M-D format for logging
$Date = Get-Date -UFormat "%Y-%m-%d"
$dateCompare = Get-Date
Start-Transcript -Path "$PSScriptRoot\Logs\DisableExpiredUsers\DisableExpiredUsers_$Date.log"
Import-Module ActiveDirectory
# Set Target OU for where expired users should be moved to after being expired
$TargetOU = "<AD OU>"
# init empty arrays for expired users
$expiredusers = @(); $expiredusers1 = @();
# Get all enabled users whose accounts have expired and whose dates are not null 
$expiredusers = Get-ADUser -Filter * -Properties AccountExpirationDate |
    Where-Object {
        $_.AccountExpirationDate -le $dateCompare -and $_.AccountExpirationDate -ne $null -and $_.enabled -eq $true
    }
# Get all disabled users whose accounts have expired and whose dates are not null, and accounts not in Target OU
$expiredusers1 = Get-ADUser -Filter * -Properties AccountExpirationDate |
    Where-Object {
        $_.AccountExpirationDate -le $dateCompare -and $_.AccountExpirationDate -ne $null -and $_.enabled -eq $false -and $_.DistinguishedName -notlike "*$TargetOU*"
    }

# Combine lists into one
$expiredusers += $expiredusers1

# loop through each user whose account is expired
foreach($user in $expiredusers)
{
    # get username
    $san = $user.SamAccountName

    # get all groups that user is a member of
    $existingGroups = (Get-ADPrincipalGroupMembership $san | Select-Object -Property Name).Name
    
    # for each group, search for specific group to remove and if found remove user from it
    foreach($group in $ExistingGroups) {
        if ($group -like "*<AD GROUP>*") {
            Remove-ADGroupMember -Identity $group -Members $san -Confirm:$false
            Write-Host "Removed $san from $group"
        }
    }
    
    # disable user account
    Set-ADUser -identity $san -enabled $false -Confirm:$false
    # move user account to Target OU
    Move-ADObject -Identity (Get-ADUser -identity $san).distinguishedName -TargetPath $TargetOU -Confirm:$false
    Write-Host "Moved $san aka "$san.DisplayName" to $targetOU"
}
Stop-Transcript