<#
.SYNOPSIS
    Provision new user remote mailbox in a Hybrid Environment based upon
    AD Group O365Provision

.INPUTS
    ConnectionUri
    URL for M365 Tenant email usually @*.mail.onmicrosoft.com

.OUTPUTS
    None

.EXAMPLE
    PS>RemoteEnable.ps1 -TenantUrl <TENANTURL> -ConnectionUri http://<FQDNHOSTNAME>/PowerShell
    PS>RemoteEnable.ps1 http://<FQDNHOSTNAME>/PowerShell <TENANTURL>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/25/2024
    Purpose/Change: Initial script development
#>
Param(
    
    # Server FQDN that hosts Exchange in http://<FQDN>/PowerShell format
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $ConnectionUri,

    # Tenant email URL usually mail.onmicrosoft.com
    [Parameter(Mandatory)]
    [string]
    $TenantUrl
)
#Requires -RunAsAdministrator

# Start logging
$LogFile = "$PSScriptRoot\Logs\RemoteEnable.log"
Start-Transcript -path $LogFile -append

# Create PSSession config and Import into current session
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionUri -Authentication Kerberos
Import-PSSession $Session

# Get a list of users with Group O365Provision
$userlist = Get-ADGroupMember -Identity "O365provision" -Recursive | Select-Object SamAccountName
foreach($user in $userlist){
    # Username = SamAccountName
    $username = $user.samaccountname
    # Routing address becomes concatenated Username and Tenant URL
    $routingAddress = $username + $TenantUrl
    # Output routing address to screen
    $routingAddress 
    # Enable remote mailbox with remote routing address
    Enable-RemoteMailbox $username -RemoteRoutingAddress $routingAddress
}

# Get all group members of O365Provision and remove group
Get-ADGroupMember "O365provision" | ForEach-Object {Remove-ADGroupMember "O365provision" $_ -Confirm:$false}

# Exit session and cleanup imported session variables
Exit-PSSession
get-pssession | remove-pssession

Stop-Transcript
[GC]::Collect()