<#
.SYNOPSIS
    Script removes user folders without cleaning up the user profile
    from the machine properly.  USE WITH CAUTION
   

.DESCRIPTION
    Runs a check against all users in C:\Users and verifies they are in
    Active Directory.  If they are not, script proceeds to remove the folder
    structure in C:\Users for all users not in AD simultaneously as opposed to
    sequentially

.INPUTS
    ComputerName - Name of the computer to remove user folders from
   
.OUTPUTS
   NONE

.EXAMPLE
    PS>usercleanup.ps1 -ComputerName <COMPUTERNAME>

.EXAMPLE
    PS>usercleanup.ps1 <COMPUTERNAME>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development
#>
Param(
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $ComputerName
)

# If script is called with a verbose setting
if($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent)
{
    # Get all usernames in C:\Users on the specified machine
    $a = (Get-ChildItem \\$computername\c$\users\).Name
    # For each folder in C:\Users simultaneously check name against AD and
    # other restricted usernames we wish to leave alone.
    # If not in AD or matching restricted usernames, recursively remove with Verbose setting
    $a | ForEach-Object -parallel {
        if(-not (
            [bool](Get-ADUser -Filter {SamAccountName -eq $_}) -or ($_ -eq "Public") -or ($_ -eq "Administrator") -or ($_ -like "*_adm"))
            ) {
                Remove-Item \\$using:computername\c$\users\$_ -Recurse -Force -Verbose:($using:VerbosePreference -eq 'Continue') 
            }
        }
}

# If script is not called with verbose
else
{
    # Get all usernames in C:\Users on the specified machine
    $a = (Get-ChildItem \\$computername\c$\users\).Name
    # For each folder in C:\Users simultaneously check name against AD and
    # other restricted usernames we wish to leave alone.
    # If not in AD or matching restricted usernames, recursively remove
    $a | ForEach-Object -parallel {
        if(-not (
            [bool](Get-ADUser -Filter {SamAccountName -eq $_}) -or ($_ -eq "Public") -or ($_ -eq "Administrator") -or ($_ -like "*_adm"))
            ) {
                Remove-Item -Recurse -Force \\$using:computername\c$\users\$_
            }
        }
}