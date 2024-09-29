<#
.DESCRIPTION
    Get email addresses from two separate files and compare them against a 
    third file with a list of email addresses to ignore, usually 
    distribution groups.  Used for outputting all email addresses that should
    no longer be active.

.INPUTS
    <file1>.csv - list of email addresses with one domain
    <file2>.csv - list of email addresses with a different domain
    ignoreEmailAddresses.csv - list of email addresses to skip/ignore

.OUTPUTS
    Transcription log of script
    Dated csv files of existing users

.EXAMPLE
    PS>EmailCheckUsers.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 09/27/2024
    Purpose/Change: Initial script development
#>
Param(
    # Email addresses from one domain
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $DomainOne,
    # Email addresses from a secondary domain
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $DomainTwo,
    # Email addresses to ignore
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $ignoreAddresses
)
#Requires -RunAsAdministrator
Import-Module ActiveDirectory

#Get date for timestamp of file
$date = get-date -UFormat "%Y_%m_%d"

#Set working file path as the path of this script
$file_path = "$PSScriptRoot"

Start-Transcript -Path "$file_path\Logs\CurrentEmails\currentUsers_$($date).txt"
#Set the output file and delete it if it already exists, to avoid appending to old data
$OutFile = "$file_path\Logs\CurrentEmails\current_$($date).csv"
if([System.IO.File]::exists($OutFile)) { Remove-Item -Force $OutFile }

#Create array to loop through each file, improved over parsing individually
$files = "$DomainOne", "$DomainTwo"
#Pull Dataset of email addresses to ignore
$ignore = Get-Content "$ignoreAddresses"

#For each file
foreach($file in $files)
{
    #Get a list of all the usernames (exclude everything after @)
    $list = Get-Content $file | ForEach-Object { $_ -replace '(@.*)' }
    #Filter out the email addresses to be ignored
    $noExclist = Compare-Object $list $ignore | Where-Object { 
        $_.SideIndicator -eq "<=" } | Select-Object -Expand InputObject

    #For each username in filtered list
    foreach($user in $noExclist)
    {
        $SAM = "SamAccountName -like '*$user*'"
        #Special case
        if($user -eq "<EMAILNAME>") { $user = "<ADUSERNAME>" }
        #Try to find in AD, if not found, $check is null
        $check = $(try { Get-ADUser -Filter $SAM } catch { $null })
        #If $check is not null, check if account is disabled
        if($null -ne $check)
        {
            #Check if account is disabled, if no, $disabled will be null
            $disabled = $( try{ Get-ADUser -Filter "$SAM -and Enabled -eq '$FALSE'" } catch{ $null } )
            #If $disabled is not null, then output the user to file
            if($null -ne $disabled) { Out-File -FilePath "$OutFile" -InputObject "$user" -Encoding ASCII -Append }
        }
        #Else, output to file
        else { Out-file -FilePath "$OutFile" -InputObject "$user" -Encoding ASCII -Append }
    }
}
Stop-Transcript