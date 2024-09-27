<#
.DESCRIPTION
    Searches AD for all Distribution Groups matching the GroupName given
    then outputs all members of each matching group to a csv file with the
    group name as the file name

.OUTPUTS
    Multiple csv files that includes name and group name
    of all members within each group matching the input group name

.EXAMPLE
    PS> GetADGroupsandMembers.ps1 -GroupName <NAME>
    PS> GetADGroupsandMembers.ps1
    PS> <VARIABLE> | GetAdGroupsandMembers.ps1
   
.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/08/2024
    Purpose/Change: Initial script development
#>
Param(
    # Group Name to search for all or matching group names
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $GroupName
)

# array to store the hash table of the user and the group they are apart of
$name = @()
# get all groups that match the filter
$groups = Get-ADGroup -Filter "Name -like `"*$GroupName*`"" | Where-Object { "$_.GroupCategory -eq 'Distribution'" }

foreach($group in $groups)
{
    # empty array to hold the names of every member of the group, init to be
    # empty for each loop
    $names = @()
    $names += (Get-ADGroupMember -Identity $group | Select-Object Name).Name
    # for each name on the list, add it to the name array along with the
    # name of the group
    $names | ForEach-Object { $name += "$($group.Name),$_" }
    # set csv file name to be the group name
    $csv = "$PSScriptRoot\..\Logs\GroupMemberships\$($group.Name).csv"
    # output all names in the group, default out-file is 
    Out-File -InputObject $name -FilePath $csv
}