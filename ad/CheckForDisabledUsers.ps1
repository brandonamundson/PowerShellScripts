<#
.DESCRIPTION
    Looks for disabled users not in a Vendor OU or Pending Deletion OU
    and outputs them in a log file for review   

.INPUTS
    NONE

.OUTPUTS
    Log file listing all disabled users not pending deletion by OU

.EXAMPLE
    PS>CheckForDisabledUsers.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/23/2024
    Purpose/Change: Initial script development
#>
#Requires -RunAsAdministrator

#Get formatted date and start logging
$Date = Get-Date -UFormat "%Y-%m-%d"
Start-Transcript -Path "$PSScriptRoot\Logs\DisabledUsersNotPendingDelete\DisabledUsersNotPendingDelete_$Date.log"
# Avoid these managed groups
$VS = '.*OU=Vendor.*'
$PD = '.*OU=Pending Deletion,.*'
# Avoid these Default Names
$def = 'DefaultAccount'
$krb = 'krbtgt'
# Simple Vars that are reused
$DN = 'DistinguishedName'
$N = 'Name'

# Get list of users filtered by not enabled, where AD Path (DN) is not
# a match to Pending Delete or Vendor OU's and does not match default accounts
$list = get-aduser -Filter {
    (Enabled -eq $FALSE)
} -Properties * | Where-Object {
    $_.$DN -notmatch "$PD|$VS" -and $_.$N -notmatch "$krb|$def"
} | Select-Object $N,@{l='OU';e={$_.$DN -replace '^.*?,(?=[A-Z]{2}=)'}}

#Output list to log/console
Write-Output $list | Out-Default

Stop-Transcript