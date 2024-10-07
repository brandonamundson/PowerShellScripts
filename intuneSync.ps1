<#
.SYNOPSIS
    Force a Intune Sync on managed device

.INPUTS
    NONE
   
.OUTPUTS
    NONE

.EXAMPLE
    PS>intuneSync.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 10/06/2024
    Purpose/Change: Initial script development
#>

$Shell = New-Object -ComObject Shell.Application
$Shell.open("intunemanagementextension://syncapp")
[System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$Shell) | out-null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()