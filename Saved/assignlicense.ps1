Param(
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $UPN
)

#Requires -RunAsAdministrator

$LogFile = 'C:\Scripts\Saved\assignLicense.log'
Start-Transcript -path $LogFile -append
Install-Module Microsoft.Graph -Scope CurrentUser
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All
Update-MgUser -UserId $UPN -UsageLocation US
Set-MgUserLicense -UserId $UPN -AddLicenses @{SkuId = "05e9a617-0261-4cee-bb44-138d3ef5d965"} -RemoveLicenses @()
Stop-Transcript