<#
.SYNOPSIS
    Remove Home Drive from specific AD User

.INPUTS
    Username to be removed

.OUTPUTS
    Transcription Log

.EXAMPLE
    PS>RemoveHomeDriveIndividual.ps1 -UserName <USERNAME>
    PS>RemoveHomeDriveIndividual.ps1 <USERNAME>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/26/2024
    Purpose/Change: Initial script development
#>
param(
    # Username to remove home drive from
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $UserName
)

# Start Transcript log -- append or create as needed
Start-Transcript -Path "$PSScriptRoot\Logs\RemoveHomeDrive.log" -Append
# Get user per given username
Get-AdUser -Identity $UserName -Properties HomeDirectory,HomeDrive | ForEach-Object {
    # Output name of user to remove home drive from
    Write-Host "- " $_.Name
    # If home drive is not null, output status update and remove before 
    # stating complete
    if ($_.HomeDrive -ne $null) {
     Write-Host -NoNewline "|-  Current home:" $_.HomeDrive "->" $_.HomeDirectory": removing... "
     Set-AdUser -Identity $_.DistinguishedName -HomeDirectory $null -HomeDrive $null
     Write-Host "Done."
    }
 }
 # Stop transcription logging
Stop-Transcript