<#
.SYNOPSIS
    Get all actived locked out users

.INPUTS
    NONE

.OUTPUTS
    NONE

.EXAMPLE
    PS>LockedAD.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/25/2024
    Purpose/Change: Initial script development
#>
#Requires -RunAsAdministrator

# Search AD for LockedOut accounts that are enabled and
# Output to host that user is locked out
Search-ADAccount -LockedOut | Where-Object {
    ((Get-ADUser -Identity $_.SamAccountName -Properties Enabled).Enabled -ne $FALSE)
} | ForEach-Object { Write-Output "$($_.Name) is locked out" }