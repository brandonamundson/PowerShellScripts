<#
.SYNOPSIS
    Get all departments from AD with either a pre-provided list of usernames
    or by searching all of ad for users.

.INPUTS
    Input file of usernames with header USN

.EXAMPLE
    PS>getDepartments.ps1
    PS>getDepartments.ps1 -AD
    PS>getDepartments.ps1 -FilePath "<FILEPATH>"
   
.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/19/2024
    Purpose/Change: Initial script development
#>

[CmdletBinding(DefaultParameterSetName = 'AD')]
Param(
    # Path to csv report for comparison
    [ValidateNotNullOrEmpty]
    [Parameter(Mandatory,ParameterSetName = 'File')]
    [string]
    $FilePath = "",
    # Boolean var set to always true if csv is null or empty 
    [Parameter(Mandatory,ParameterSetName = 'AD')]
    [bool]
    $AD = $true
)
#Requires -RunAsAdministrator

# Get formatted date and start logging with dated log file
$Date = Get-Date -UFormat "%Y-%m-%d"
Start-Transcript -Path "$PSScriptRoot\Logs\getJobTitles_$Date.log"
# Import required module
Import-Module ActiveDirectory


switch($FilePath)
{
    # If FilePath is empty, search AD for all users with listed departments
    # then sort, and filter each name and department before exporting to csv
    {$_ -eq ""} {
        Get-ADUser -Filter * -Properties SamAccountName,Department | 
            Select-Object SamAccountName,Department | 
                Export-Csv -Path $PSScriptRoot\..\everydepartment.csv -NoTypeInformation
    }

    {$_ -ne ""} {
        # Import list of all users and departments from a file and select only
        # usernames, then sort by unique usernames
        $un = (Import-CSV -Path "$FilePath" -Header 'USN').USN | Sort-Object -Unique
        # verify only all usernames are unique
        $un = $un | Sort-Object -Unique
        
        # create array to hold all departments and usernames and initialize
        $job = @()
        $job += "Department,Username"
        
        # for every user in list get department and add department
        # and username to job array
        foreach($user in $un)
        {
            if(Get-ADUser -Identity $user)
            {
                $job += ((Get-ADUser -Identity $user -Properties Department).Department + "," + $user)
            }
            else
            {
                $job += " ," + $user
            }
        }
        
        # Output all departments and usernames in job array
        # output to host
        Write-Output $job | Out-Default
        
        # output results to csv
        Out-File -FilePath $PSScriptRoot\..\alldepartments.csv -InputObject $job -Force
    }
}

Stop-Transcript