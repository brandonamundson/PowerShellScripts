<#
.SYNOPSIS
    Removes the home drive for all users in the Users OU

.INPUTS
    NONE

.OUTPUTS
    Transcript log

.EXAMPLE
    PS>RemoveHomeDrive.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development
#>

#Requires -RunAsAdministrator

Param(
    # OU to search for users with Home Drive Attribute
    [Parameter(Mandatory)]
    [string]
    $OU
)

# Start logging, append to existing if necessary
Start-Transcript -Path "$PSScriptRoot\Logs\RemoveHomeDrive.log" -Append
# Get all users in OU and select HomeDirectory and HomeDrive
Get-AdUser -Filter * -Properties HomeDirectory,HomeDrive -SearchBase $OU | ForEach-Object {
    # Output name of user
    Write-Host "- " $_.Name
    # If user has Home Drive, output message stating removing Home drive
    # Then remove it and write output Done.
    if ($_.HomeDrive -ne $null) {
        Write-Host -NoNewline "|-  Current home:" $_.HomeDrive "->" $_.HomeDirectory": removing... "
        Set-AdUser -Identity $_.DistinguishedName -HomeDirectory $null -HomeDrive $null
        Write-Host "Done."
    }
 }
 # Stop logging
Stop-Transcript