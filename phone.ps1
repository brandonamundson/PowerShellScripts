<#
.SYNOPSIS
    Get phone number attribute of AD User   

.INPUTS
    User - username of user to get phone number attribute   

.OUTPUTS
    NONE   

.EXAMPLE
    PS>phone.ps1 -user <USERNAME>

.EXAMPLE
    PS>phone.ps1 <USERNAME>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development
#>

param(
    # User to get phone number from
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $user
)

Get-ADUser $user -Properties telephoneNumber | Select-Object telephoneNumber