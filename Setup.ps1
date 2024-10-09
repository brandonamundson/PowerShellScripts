<#
.SYNOPSIS

    Setup new computer and install necessary software, then cleanup   

.DESCRIPTION

   Creates Admin and non-admin user, sets password for each account
   Renames computer and adds to specified workgroup
   Download software for drivers and install them
   Download and install custom start menu
   If device is laptop, install vpn
   Moves files to desktop and downloads folders, leaves what is needed
   after running and removes the rest after running them.

.INPUTS

   

.EXAMPLE

   

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development

#>


#Requires -RunAsAdministrator
Param(
    # Name to rename machine to.
    [Parameter(Mandatory)]
    [string]
    $ComputerName,
    # Workgroup to add machine to.
    [Parameter(Mandatory)]
    [string]
    $Workgroup
)

# Add libraries for message boxes
Add-Type -AssemblyName PresentationCore,PresentationFramework

# Variables for local file moves/saves
$desktop = "$env:USERPROFILE\Desktop"
$downloads = "$env:USERPROFILE\Downloads"
$cleanupFiles = @()
$cleanupFiles += "$desktop\Microsoft *"
# Credential variable and connect share drive for file xfers
$cred = Get-Credential -Credential "<DOMAIN\USERNAME>"
New-PSDrive -Name P -PSProvider FileSystem -root '<SHARED DRIVE LOCATION>' -Credential $cred


# Function to add local non admin user with a password
# and modify the admin password
function addUser
{
    net user "<STANDARD ACCT USERNAME>" /add
    net user Administrator /active:yes
    Write-Output "Enter Password for <STANDARD USER ACCT>"
    net user "<STANDARD ACCT USERNAME>" *
    Write-Output "Enter Password for Administrator"
    net user Administrator *
}

# Transfer files from share drive to local machine
function mvfiles
{
    Copy-Item '<RDP & BAT FILES>' "C:\Windows"
    Copy-Item '<SHELL INIT REG KEY MODIFIER>' $desktop
    Copy-Item '<REMOTE AGENT>' $desktop
    Copy-Item '<CLASSIC START XML FILE>' $desktop
}

# Download any installers run all installers
# and add to cleanup array for deletion later
function runfile
{
    wget https://ninite.com/classicstart-chrome/ninite.exe -OutFile $downloads\ninite.exe
    wget https://go.microsoft.com/fwlink?LinkID=799445 -OutFile $downloads\Windows10UpgradeAssistant.exe
    $cleanupFiles += "$downloads\ninite.exe"
    $cleanupFiles += "$desktop\<REMOTE AGENT>"
    $cleanupFiles += "$downloads\Windows10UpgradeAssistant.exe"
    Start-Process $downloads\ninite.exe -wait
    Start-Process $desktop\'<REMOTE AGENT>' -wait
    Start-Process $downloads\Windows10UpgradeAssistant.exe
}

# cleanup all files for setting up new pc
function cleanup
{
    foreach($file in $cleanupFiles)
    {
        Remove-Item -force $file
    }
}

# Change computer name, add to WorkGroup, prompt to restart now or later
function rebootOptional
{
    Rename-Computer $ComputerName
    Add-Computer -WorkGroupName $Workgroup
    $msgboxinput = [System.Windows.MessageBox]::Show("A restart is required to make the requested changes.  Do you want to restart now?","Reboot Required",'yesno','information')
    switch($msgboxinput)
    {
        'Yes' { shutdown /r }
        'No' { exit }
    }
}

# Verify if device is desktop or laptop for VPN requirements
# By checking the reported Chassis Type reported to Windows
# and checking if there is a battery attached
function checkLaptop
{
    # Get-WmiObject to check system enclousre chassis type
    $chassis = (Get-WmiObject -Class win32_systemenclosure -ComputerName localhost).chassistypes
    # If chassis type is equivalent to 9=Laptop,10=Notebook,14=Sub Notebook
    if($chassis -eq 9 -or $chassis -eq 10 -or $chassis -eq 14)
    {
        # check if device has a battery
        if(Get-WmiObject -Class win32_battery -ComputerName localhost)
        {
            isLaptop
        }
        else
        {
            $msgboxinput = [System.Windows.MessageBox]::Show("Is this device a laptop?","Check device type",'yesno','information')
            switch($msgboxinput)
            {
                'Yes' { isLaptop }
                'No' { }
            }
        }
    }
}

# download and install update method for dell laptops
# ask if vpn is needed
function isLaptop
{
    # Check if device manufacturer is a Dell and download Dell Driver Updater
    if((Get-WmiObject -Class win32_systemenclosure -ComputerName localhost).manufacturer -eq "Dell Inc.")
    {
        $cleanupFiles += "$downloads\supportassistinstaller.exe"
        wget https://downloads.dell.com/serviceability/catalog/supportassistinstaller.exe -outfile $downloads\supportassistinstaller.exe
        Start-Process $downloads\supportassistinstaller.exe -wait
    }
    requireVPN
}

# ask if vpn is needed and if needed, install it
function requireVPN
{
    $msgboxinput = [System.Windows.MessageBox]::Show("Does this device require VPN?","VPN Required",'yesno','information')
    switch($msgboxinput)
    {
        'Yes' { vpnSetup }
        'No' { }
    }
}

# get vpn installer from share drive
# install vpn
function vpnSetup
{
    Copy-Item '<VPN INSTALLER>' $desktop
    $cleanupFiles += "$desktop\<VPN INSTALLER>"
    $cleanupFiles += "<RDP SHELL BAT FILE>"
    $cleanupFiles += "$desktop\<RDP FILES>"
    Move-Item C:\Windows\"<RDP FILE>" C:\Users\Public\Desktop
    Start-Process $desktop\"<VPN INSTALLER>" -wait
}

# Call functions
addUser
mvfiles
runfile
checkLaptop
cleanup
rebootOptional