<#
.SYNOPSIS
  Remove User Profiles that haven't logged in past 60 days    

.DESCRIPTION
    Remove user profiles that haven't been logged into for 60 days or more

.EXAMPLE
  PS>.\removeStaleProfiles.ps1    

.NOTES
  Version: 1.0
  Author: Brandon Amundson
  Creation Date: 07/30/2024
  Purpose/Change: Initial script development
#>
#Requires -RunAsAdministrator

#Get Date 60 days previous from today
$sixtyDaysAgo = (Get-Date).AddDays(-60)

# For each user profile, if LastUseTime <= 60, remove profile
Get-CimInstance Win32_UserProfile | ForEach-Object {

  if ($_.LastUseTime -lt $sixtyDaysAgo) {
    Remove-CimInstance -InputObject $_ -Confirm:$false
  }
}
