<#
.DESCRIPTION
    Querys two domain controllers in a given domain for LastLogonTime and
    validates the last logon being within the last 90 days.  Any users
    not logged on in 90 days are output to console/log and csv file   

.INPUTS
    NONE

.OUTPUTS
    CSV File of users that haven't logged on in 90 days

.EXAMPLE
    PS>LastLogonDate.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/25/2024
    Purpose/Change: Initial script development
#>
#Requires -RunAsAdministrator

# Get formatted date and create log file name
$date = Get-Date -UFormat "%Y-%m-%d"
$File = "$PSScriptRoot\Logs\LastLogonDate\UsersNotLoggedIn90Days_$Date"

# Get all domain controllers
$control = (Get-ADDomainController -Filter * | Select-Object name).name

# Create empty users array variable
[System.Collections.ArrayList]$users.clear();

# Get list of usernames to ignore
$ignore = Get-Content "$PSScriptRoot\ADUserstoIgnore.csv"

# Start logging
Start-Transcript -Path "$File.log"

# Get all enabled users not on ignore list
$user = get-aduser -filter {Enabled -eq $TRUE} | Select-Object SamAccountName |
    Where-Object { $ignore -notcontains $_.SamAccountName }

    # For each user, get if enabled, last logon date, and last logon where
# last logon is not null
$users = $user.SamAccountName | ForEach-Object {
    Get-ADUser -Identity $_ -Properties Enabled,LastLogonDate,LastLogon |
    Where-Object { ($_.LastLogonDate -ne $NULL) } |
    Select-Object Name, SamAccountName, LastLogonDate
}

# erase user variable before re-using
Clear-Variable user

foreach($user in $users)
{
    # get last logon from each domain controller for current user
    $test = foreach($DC in $control)
    {
        Get-ADUser -Identity $user.SamAccountName -Properties Name,LastLogon -Server $dc | Select-Object Name,LastLogon
    }
    # check last logon for two domain controllers and verify not null or empty
    if(($null -ne $test[0].LastLogon) -and ($null -ne $test[1].LastLogon) -and ($test[0].LastLogon -ne 0) -and ($test[1].LastLogon -ne 0))
    {
        # if DC 1 has older value than DC 2
        if($test[0].LastLogon -lt $test[1].LastLogon)
        {
            # Convert Last Logon Time Stamp
            $time = $(w32tm /ntte $test[1].LastLogon)
            # Get last three pieces of time stamp
            # MM/DD/YY HH:MM:SS a/p
            $time1 = $time.split(" - ")[-3..-1]
            # clear variable for reuse
            Clear-Variable time
            # combine timestamp pieces into one var
            $time = $time1[0] + " " + $time1[1] + " " + $time1[2];
            # Set LastLogonDate to time variable
            $users[$users.IndexOf($user)].LastLogonDate = [DateTime]$time
        }
        else
        {
            # Convert Last Logon Time Stamp
            $time = $(w32tm /ntte $test[0].LastLogon)
            # Get last three pieces of time stamp
            # MM/DD/YY HH:MM:SS a/p
            $time1 = $time.split(" - ")[-3..-1]
            # clear variable for reuse
            Clear-Variable time;
            # combine timestamp pieces into one var
            $time = $time1[0] + " " + $time1[1] + " " + $time1[2];
            # Set LastLogonDate to time variable
            $users[$users.IndexOf($user)].LastLogonDate = [DateTime]$time
        }
    }
}

# Output users that haven't logged on within last 90 days to host/log
Write-Output ($users | Where-Object {
    ($_.LastLogonDate -lt (Get-Date).AddDays(-90)) -and ($_.LastLogonDate -ne $NULL)} |
    Sort-Object -Property LastLogonDate |
    Select-Object Name,SamAccountName, LastLogonDate) | Out-Default

# Store users that haven't logged on within last 90 days into variable to output
$final = ($users | Where-Object {
    ($_.LastLogonDate -lt (Get-Date).AddDays(-90)) -and ($_.LastLogonDate -ne $NULL) } |
    Sort-Object -Property LastLogonDate |
    Select-Object Name,SamAccountName, LastLogonDate)

# Output list to csv and stop transcription
$final | Export-Csv -Path "$FILE.csv" -NoTypeInformation
Stop-Transcript