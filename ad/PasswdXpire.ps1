<#
.SYNOPSIS
    Get user properties of PasswordExpired and PasswordLastSet

.INPUTS
    Username of an AD User

.OUTPUTS
    NONE

.EXAMPLE
    PS>PasswdXpire.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development
#>
Param(
    # Username of AD User
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $user
)
#Requires -RunAsAdministrator

Get-ADUser -Identity $user -Properties PasswordExpired,PasswordLastSet |
    Select-Object Name,PasswordExpired,PasswordLastSet