<#
.SYNOPSIS

   Finds all sessions on a server or set of servers and can search by username

.DESCRIPTION

   Looks for all sessions on any server(s) passed into the servers parameter.
   Will look for a username if one is entered under the userName paramerter.

.INPUTS

   Accepts any username passed through a pipeline

.OUTPUTS

   Outputs a hash table with a list of sessions that are disconnected or
   matching the userName parameter

.EXAMPLE

   PS> .\qwinsta.ps1 -userName name1 -servers server1
   PS> .\qwinsta.ps1 -userName name1 -servers server1,server2,server3
   PS> .\qwinsta.ps1 -servers server1
   PS> .\qwinsta.ps1 -servers server1,server2,server3
   PS> .\qwinsta.ps1 -userName name1 -servers 0.0.0.0
   PS> .\qwinsta.ps1 -userName name1 -servers 0.0.0.0,1.1.1.1,2.2.2.2
   PS> .\qwinsta.ps1 -servers 0.0.0.0
   PS> .\qwinsta.ps1 -servers 0.0.0.0,1.1.1.1,2.2.2.2

.NOTES
    Version: 1.1
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Script validation, review, and documentation

#>
Param(
    # Username to search for among hosts
    [Parameter(ValueFromPipeline=$true)]
    [string]
    $userName,
    #Servers by IP Address, or Hostname
    [Parameter(Mandatory)]
    [string]
    $servers
)

#Requires -RunAsAdministrator
# create empty table to store values later
$table = @{}

# create hashtable of values
function Format-Hashtable {
    param(
      [Parameter(Mandatory,ValueFromPipeline)]
      [hashtable]$Hashtable,

      [ValidateNotNullOrEmpty()]
      [string]$KeyHeader = 'Name',

      [ValidateNotNullOrEmpty()]
      [string]$ValueHeader = 'Value'
    )

    $Hashtable.GetEnumerator() | Select-Object @{Label=$KeyHeader;Expression={$_.Key}},@{Label=$ValueHeader;Expression={$_.Value}}

}


foreach($server in $servers)
{
    # for each server, get all usernames for logged in sessions
    # Where session is not blank
    $sessions = (qwinsta /server:$server | Where-Object { $_ -match '^[>]|[a-zA-Z](\S+) +(\S*?) +(\d+) +(\S+)' } |
    # select service, username, session id, and session state
    Select-Object @{n='Service';e={$matches[1]}},
            @{n='Username';e={$matches[2]}}, 
            @{n='ID';e={$matches[3]}},
            @{n='Status';e={$matches[4]}} |
    # For each match, verify status is Disconnected and session name is not Services, output session name, 
    # otherwise output username
    ForEach-Object {if(($_.Status -eq 'Disc') -and ($_.Service -ne 'ervices')) {$_.Service} else {$_.Username}})

    # For each not blank session, add them to a table
    foreach($session in $sessions)
    {
        if($session -ne "") { $table.add($session, $server) }
    }
}

# if $userName is not null
if($userName)
{
    # Output table and format it using format-hashtable function and search for username
    Write-Output $table | Format-Hashtable -KeyHeader "Username" -ValueHeader "Host" | findstr $userName
}
else
{
    # Output table and format it using format-hashtable function
    Write-Output $table | Format-Hashtable -KeyHeader "Username" -ValueHeader "Host"
}
