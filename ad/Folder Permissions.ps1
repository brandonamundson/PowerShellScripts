<#
.SYNOPSIS
	Get all inherited directory permissions of a given path recursively and output as CSV
   
.INPUTS
	File path
   
.OUTPUTS
	CSV File listing all inherited permissions for each directory in path
   
.EXAMPLE
	PS>Folder Permissions.ps1 -RootPath <PATH>
	PS>Folder Permissions.ps1 <PATH>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/25/2024
    Purpose/Change: Initial script development
#>
Param(
	# Path to traverse for permissions
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
	[ValidateNotNullOrEmpty]
    [string]
    $RootPath
)
#Requires -RunAsAdministrator

# If output file exists, delete and create new with a header
$OutFile = "$PSScriptRoot\access.csv"
$Header = "Folder Path,IdentityReference,AccessControlType,IsInherited,InheritanceFlags,PropagationFlags"
if($OutFile) { Remove-Item $OutFile }
Add-Content -Value $Header -Path $OutFile

# Store each folder in path
$Folders = Get-ChildItem $RootPath -Recurse -Directory

foreach ($Folder in $Folders)
{
	# Get access for current folder in array
	$ACLs = (Get-Acl $Folder.fullname).Access
	# Get only inherited permissions
    if($ACL.IsInherited -eq $false)
    {
		# Output each permission with all access details per line of csv file
	    Foreach ($ACL in $ACLs)
        {
	        $OutInfo = $Folder.Fullname + "," + $ACL.IdentityReference  + "," + $ACL.AccessControlType + "," + $ACL.IsInherited + "," + $ACL.InheritanceFlags + "," + $ACL.PropagationFlags
	        Add-Content -Value $OutInfo -Path $OutFile
	    }
    }
}