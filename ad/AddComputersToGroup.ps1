<#
.SYNOPSIS
    Script to add AD computers to a specified group, excluding specified computer
    objects
   

.OUTPUTS
    Outputs log file and csv file under $PSScriptRoot\Logs
   

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/03/2024
    Purpose/Change: Initial script development

#>
#Requires -RunAsAdministrator

# Place your script here
$Date = Get-Date -UFormat "%Y-%m-%d"
# Set working file path as the path of this script
$file_path = "$PSScriptRoot"
Start-Transcript -Path "$file_path\Logs\AddComputersToGroup_$Date.log"
Import-Module ActiveDirectory

# Groups/types of ADComputerObjects to skip adding to AD groups
$server = '.*Server.*'
$svr = '<Specific Server group(s)>'
$sg = 'SG_O365_MONTHLY_CHANNEL'
$uk = '.*Unknown.*'
$test = '.*test.*'
$temp = '.*temp.*'
$mac = '.*mac.*'
$members = @()
$nonmembers = @()
$OutFile = "$file_path\Logs\notInGroup_$($date).csv"
# If file exists, remove file
if([System.IO.File]::exists($OutFile)) { Remove-Item -Force $OutFile }

# All AD Computer Objects that are not servers, mac pc's, or unknown
# and do not match testing,temporary, or other svr groups.
$computers = (Get-ADComputer -Filter * -properties Name,MemberOf,OperatingSystem,SamAccountName |
        Where-Object { $_.OperatingSystem -notmatch "$server|$uk|$mac" -and $_.Name -notmatch "$svr|$test|$temp" } |
        Select-Object Name,MemberOf,SamAccountName)

foreach($computer in $computers)
{
    # If computer is not a member of security group
    if($computer.MemberOf -notlike "*$sg*")
    {
        # Add group to non-members var
        $nonmembers += $($computer.Name + "," + $computer.MemberOf)
        # Add computer to security group
        Add-ADGroupMember -Identity $sg -Members $computer.SamAccountName
        # Output confirmation message
        Write-Output "Added $($computer.Name) to Security Group $sg" | Out-Default
    }
    # If computer is a member
    else
    {
        # Add to members variable
        $members += $($computer.Name + "," + $computer.MemberOf)
        # Output computer is already a member
        Write-Output "Computer $($computer.Name) is already a member of $sg" | Out-Default
    }
}

# Output all computer objects to csv
($members + $nonmembers) | out-file -filepath $OutFile -Encoding ASCII
Stop-Transcript