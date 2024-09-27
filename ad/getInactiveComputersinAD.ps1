﻿<#
.SYNOPSIS
    Checks for Inactive Computers in Active Directory
    
.DESCRIPTION
    Checks for inactive computers in Active Directory by using a csv file 
    generated by Lansweeper or by searching for computers that have a
    LastLogonDate of 30 days by default or set by the parameter entered

.INPUTS
    Can accept a csv file for input based upon known active computers

.OUTPUTS
    Outputs a file named based on the parameter entered in the directory from 
    which the script was called.
    
.EXAMPLE
    PS>.\getInactiveComputersinAD.ps1
    PS>.\getInactiveComputersinAD.ps1 -FilePath "C:\Path\To\File.csv"
    PS>.\getInactiveComputersinAD.ps1 -DaysInactive 30
    
.NOTES
    Version: 2.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Added Script parameters for better operability and
    added documentation
#>

[CmdletBinding(DefaultParameterSetName = 'Dated')]
Param(
    # Path to csv report for comparison
    [Parameter(Mandatory,ParameterSetName = 'File')]
    [string]
    $FilePath = "",
    # Specified Inactive Dates to look for
    [Parameter(Mandatory,ParameterSetName = 'Dated')]
    [int]
    $DaysInactive = 30
)
#Requires -RunAsAdministrator

# Get date format for logging
$Date = Get-Date -UFormat "%Y-%m-%d"
# Set working file path as the path of this script
Start-Transcript -Path "$PSScriptRoot\..\Logs\InactiveComputersinAD_$Date.log"


Switch ($FilePath)
{
    # If FilePath is not empty or null
    {$_ -ne ""} {
        # Import active computer objects from FilePath
        $active = Get-Content -Path $FilePath
        # Get all computers from AD and select by name
        $all = (Get-ADComputer -Filter *).Name
        
        # Compare All AD computers with active computer list and select those
        # that are not active (in list all, not active)
        $inactive = Compare-Object $all $active | Where-Object { 
            $_.SideIndicator -eq "<=" } | Select-Object InputObject

        # Output all inactive computers to default output object
        Write-Output $inactive | Out-Default
        
        # Output all inactive computers to csv
        $inactive | export-csv -Path "$PSScriptRoot\inactiveComputersinAD_File_$Date.csv" -NoTypeInformation
    }

    # If FilePath is empty/null
    {$_ -eq ""} {
    
    # Get the date that computers must be older than to be inactive
    $time = (Get-Date).AddDays(-($DaysInactive))
    
    # All inactive computers based on LastLogonTimeStamp and select only by
    # name and last logon date
    $inactive = Get-ADComputer -Filter { LastLogonTimeStamp -lt $time } 
        -Properties Name,LastLogonDate | Select-Object Name,LastLogonDate
    
    # Output all inactive computers to default output object
    Write-Output $inactive | Out-Default

    # Output all inactive computers to csv
    $inactive | export-csv -Path "$PSScriptRoot\inactiveComputersinAD_Dated_$Date.csv" -NoTypeInformation
    }
}

Stop-Transcript