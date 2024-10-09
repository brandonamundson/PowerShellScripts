<#
.SYNOPSIS

    Searches 2 levels of home drive location for specific folder

.DESCRIPTION

    Searches for folder bookmark_backups 2 levels deep in home drive

.OUTPUTS

    Outputs count of files counted and a file with every users folder that was found    

.EXAMPLE

    PS>.\searchhomedrive.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development

#>
param(
    [Parameter(Mandatory)]
    [string]
    $filePath
)

# Set Error Action Preference to Silently Continue to avoid any errors being
# displayed on screen
$ErrorActionPreference = 'SilentlyContinue'
# If Z drive already exists, remove Z drive
if ( Get-PSDrive -Name Z ) { Remove-PSDrive -Name Z }
# Connect New Drive
New-PSDrive -Name Z -PSProvider FileSystem -Root $filePath -Credential $(Get-Credential)

# Set $a to the Full Name (full path) of items found matching the
# bookmark_backups file name within two levels of the root of the home drive
$a = Get-ChildItem Z:\*\* | Where-Object { $_.FullName -like "*bookmark_backups" } | Select-Object FullName
# If Z drive still exists, remove it (cleanup)
if ( Get-PSDrive -Name Z ) { Remove-PSDrive -Name Z }

# Write output of count of all items found
Write-Output ($a | Measure-Object).Count
# Output all FullNames to txt file on home drive
$a | Write-Output | Out-File $PSScriptRoot\Logs\bookmarks.log