<#
.SYNOPSIS
    Searches for locked AD accounts, verifies that they are enabled before
    prompting to unlock the account(s)   

.INPUTS
    NONE

.OUTPUTS
    NONE

.EXAMPLE
    PS>unlockad.ps1   

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development
#>
Search-ADAccount -LockedOut | Where-Object {
    ((Get-ADUser -Identity $_.SamAccountName -Properties Enabled).Enabled -ne $FALSE) } |
    ForEach-Object { Unlock-ADAccount -identity "$_" -Confirm }