<#
.SYNOPSIS

    Sets the Windows Shell Registry Key to batch script

.DESCRIPTION

   Changes the Windows Shell Registry Key located at 
   HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon to a batch script
   that points to a saved rdp configuration

.EXAMPLE

    PS>.\regeditvdi.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development

#>
#Requires -RunAsAdministrator

# Registry Shell Path and Variables
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\'
$Name = 'Shell'
$Value = 'VDI.bat'

# If path does not exist, create it
If(-not (Test-Path $RegistryPath)) {
   New-Item -Path $RegistryPath -Force | Out-Null
}

# Modify registry variable by force setting it
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -Force