<#
.SYNOPSIS
    Script to remove print drivers

.EXAMPLE
    PS>removeprintdriver.ps1 -infName <NAME>
    PS>removeprintdriver.ps1 -driverName

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development
#>
#Requires -RunAsAdministrator

Param(
    # inf file name for driver
    [Parameter(Mandatory)]
    [string]
    $infName,
    # driver name
    [Parameter(Mandatory)]
    [string]
    $driverName
)
$ErrorActionPreference='silentlycontinue'

# start by removing printer driver
Remove-PrinterDriver $drivername

# Get OEM driver details from pnputil
# This line gets the OEM name needed to remove from driver store
$drv = pnputil /enum-drivers /class printer | Select-String -Context 1 $infName
    | ForEach-Object { ($_.context.precontext[0] -split ': +')[1] }

# This line gets the manufacturer name for to ensure all files
# are cleaned up
$man = pnputil /enum-drivers /class printer | Select-String -context 1 $infName
    | ForEach-Object { ($_.context.postcontext[0] -split ': +')[1] }
pnputil /delete-driver $drv

# known driver path where files are left behind
$driverpath = "$env:SystemRoot\System32\spool\drivers\x64\3"

# if location exists with known files to be cleaned up
if(Test-Path $PSScriptRoot\man.txt)
{
    # if location has content
    if($oem = get-content $psscriptroot\$man.txt)
    {
        # loop through contents of file force removing
        # all files listed
        foreach($file in $oem)
        {
            $a = Join-Path -Path $driverpath -ChildPath $file
            Remove-Item $a -force
        }
    }
}