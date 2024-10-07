<#
.SYNOPSIS
    Copies all scripts in C:\Scripts directory to another
    computer in the same directory

.INPUTS
    ComputerName - name of computer to copy scripts to

.OUTPUTS
    All scripts that are copied to the other specified computer

.EXAMPLE
    PS>CopyScripts.ps1 -ComputerName <COMPUTERNAME>
    PS>CopyScripts.ps1 <COMPUTERNAME>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/29/2024
    Purpose/Change: Initial script development
#>
Param(
    # Name of computer to copy scripts to
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $ComputerName
)

# If directory does not exist, create it
if(-not(Test-Path \\$ComputerName\c$\Scripts)) {
    mkdir \\$ComputerName\c$\Scripts }
# Recurse existing script directory for all .ps1 files and copy it to
# other computers
Get-ChildItem -Force C:\Scripts -Recurse -Include "*.ps1" | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination \\$ComputerName\c$\Scripts\ -Recurse -Verbose
}