<#
.SYNOPSIS
   Script to remove all Print Toast Notifications  

.EXAMPLE
   PS>removeprintnotifications.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development

#>
$registrypath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Print.Notification"
$name = "Enabled"
$value = "0"

if(-NOT (Test-Path $registrypath))
{
   New-Item -Path $registrypath -Force | out-null
}

New-ItemProperty -Path $registrypath -Name $name -Value $value -PropertyType DWORD -Force
