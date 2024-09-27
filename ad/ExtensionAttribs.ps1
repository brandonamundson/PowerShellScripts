<#
.SYNOPSIS
    Get all extension attributes for a given user in AD

.INPUTS
    Username to search for in AD
   
.OUTPUTS
    NONE
   
.EXAMPLE
    PS>ExtensionAttribs.ps1 -UserName <USERNAME>
    PS>ExtensionAttribs.ps1 <USERNAME>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/23/2024
    Purpose/Change: Initial script development
#>
Param(
    # Username of user to get attributes for
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $UserName
)
#Requires -RunAsAdministrator

Get-ADUser -Identity $UserName -Properties * | Select-Object extensionattribute*