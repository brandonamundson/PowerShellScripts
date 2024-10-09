<#
.SYNOPSIS

    Script to rename current computer and force immediate restart

.EXAMPLE

    PS> .\RenamePC.ps1 -ComputerName Name    

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development

#>
#Requires -RunAsAdministrator

Param(
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $ComputerName
)

Rename-Computer $ComputerName -Force -Restart