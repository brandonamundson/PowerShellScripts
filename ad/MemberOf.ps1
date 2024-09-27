<#
.SYNOPSIS
    Get all AD groups a user is a member of and sort

.INPUTS
    Username of AD User

.EXAMPLE
    PS>MemberOf.ps1 <USERNAME>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/25/2024
    Purpose/Change: Initial script development
#>
Param(
    # Username of AD User to get groups of
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $UserName
)
#Requires -RunAsAdministrator

(Get-ADUser -Identity $UserName -Properties MemberOf).MemberOf | Sort-Object