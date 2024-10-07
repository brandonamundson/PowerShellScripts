<#
.DESCRIPTION
    Script to search home directories for hidden directories and
    common name directories and removes all that are found.   

.INPUTS
    rootPath - path to home directory for searching   

.OUTPUTS
    NONE   

.EXAMPLE
    PS>homedrivecleanup.ps1 -rootPath <ROOTPATH>j
.EXAMPLE
    PS>homedrivecleanup.psq <ROOTPATH>   

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 10/06/2024
    Purpose/Change: Initial script development
#>
param(
    [Parameter(Mandatory)]
    [string]
    $rootPath
)

$appdata = 'Application Data'
$as = 'Autosave'
$office = 'Custom Office Templates'

$Date = Get-Date -UFormat "%Y-%m-%d"
$LogFile = "$PSScriptRoot\Logs\HomeDriveCleanup_$Date.log"
Start-Transcript -path $LogFile -append

# Map driver for shorter path
New-PSDrive -root $rootPath -name z -PSProvider FileSystem -Credential
# Get hidden directories
Write-Output "Getting Hidden Directories at $(Get-Date)"
$hidFolders = (Get-ChildItem -Depth 2 -Path z:\ -Directory -ErrorAction SilentlyContinue -Attributes Hidden | Where-Object { 
    $_.FullName -notlike '*administrator*' }).FullName
Write-Output "Getting Hidden Directories complete at $(Get-Date)"
# Getting specific directories
Write-Output "Getting Hidden Directories complete, proceeding with specified directories at $(Get-Date)"
$comFolders = (Get-ChildItem -Path z:\ -Directory -Depth 2 | Where-Object {
    ($_.Name -eq $appdata -or $_.Name -eq $as -or $_.Name -eq $office -or $_.Name -eq 'IBM' -or $_.Name -eq 'XEN78') -and $_.FullName -notlike '*administrator*' }).FullName
Write-Output "Finished getting all Directories at $(Get-Date)"
# Combine directories
$files = $hidFolders + $comFolders

ForEach($file in $files)
{
    # Ensure ownership controls are set and remove
    Get-Acl $rootPath | set-acl $file
    Remove-Item $file -Force -Verbose -Recurse
}
Remove-PSDrive -Name z
Stop-Transcript