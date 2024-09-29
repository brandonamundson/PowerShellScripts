# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $Command = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb RunAs -ArgumentList $Command
        Exit
 }
}

$Date = Get-Date -UFormat "%Y-%m-%d"
Start-Transcript -Path "$PSScriptRoot\Logs\AddComputersToGroup_$Date.log"
Import-Module ActiveDirectory

# Get AD info
# Get count of AD Objects
$Computers = (Get-ADComputer -Filter *).count
$Workstations = (Get-ADComputer -LDAPFilter "(&(objectClass=Computer)(!operatingSystem=*server*))" -Searchbase (Get-ADDomain).distinguishedName).count
$Servers = (Get-ADComputer -LDAPFilter "(&(objectClass=Computer)(operatingSystem=*server*))" -Searchbase (Get-ADDomain).distinguishedName).count
$Users = (Get-ADUser -Filter *).count 
$Groups = (Get-ADGroup -Filter *).Count

# Get AD Forest
$ADForest = (Get-ADDomain).Forest

# Get FSMO Role Owners
$FSMO = netdom query FSMO

# Get Domain Information
$ADForestMode = (Get-ADForest).ForestMode
$ADDomainMode = (Get-ADDomain).DomainMode
$ADVer = Get-ADObject (Get-ADRootDSE).schemaNamingContext -property objectVersion | Select objectVersion
$ADNUM = $ADVer -replace "@{objectVersion=", "" -replace "}", ""

If ($ADNum -eq '88') { $srv = 'Windows Server 2019/Windows Server 2022' }
ElseIf ($ADNum -eq '87') { $srv = 'Windows Server 2016' }
ElseIf ($ADNum -eq '69') { $srv = 'Windows Server 2012 R2' }
ElseIf ($ADNum -eq '56') { $srv = 'Windows Server 2012' }
ElseIf ($ADNum -eq '47') { $srv = 'Windows Server 2008 R2' }
ElseIf ($ADNum -eq '44') { $srv = 'Windows Server 2008' }
ElseIf ($ADNum -eq '31') { $srv = 'Windows Server 2003 R2' }
ElseIf ($ADNum -eq '30') { $srv = 'Windows Server 2003' }

Write-host "Active Directory Info" -ForegroundColor Yellow
Write-host ""
Write-Host "Computers =    "$Computers -ForegroundColor Cyan
Write-Host "Workstions =   "$Workstations -ForegroundColor Cyan
Write-Host "Servers =      "$Servers -ForegroundColor Cyan
Write-Host "Users =        "$Users -ForegroundColor Cyan
Write-Host "Groups =       "$Groups -ForegroundColor Cyan
Write-host ""
Write-Host "Active Directory Forest Name =  "$ADForest -ForegroundColor Cyan
Write-Host "Active Directory Forest Mode =  "$ADForestMode -ForegroundColor Cyan
Write-Host "Active Directory Domain Mode =  "$ADDomainMode -ForegroundColor Cyan
Write-Host "Active Directory Schema Version is $ADNum which corresponds to $Srv" -ForegroundColor Cyan
Write-Host ""
Write-Host "FSMO Role Owners" -ForegroundColor Cyan
$FSMO

Stop-Transcript