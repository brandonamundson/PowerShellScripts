<#
.DESCRIPTION
    Script to setup a new computer, has prompts to verify if a reboot is needed
    a hotfix update is required, and verification if device is a laptop if it
    cannot be determined.  Script will download updates, including download
    and install any updates from Dell with Dell Command Update.  Will also
    rename the computer and cleanup all installation files created.
    ***THIS IS NOT A SILENT SETUP SCRIPT***
    ***IT IS AN INTERACTIVE SETUP SCRIPT***   

.INPUTS
    ComputerName - what to name the computer
    MessageBox inputs - control the flow of script execution   

.OUTPUTS
    Message boxes that help control the flow and execution of the script

.EXAMPLE
    PS>setupv2.ps1 -ComputerName <COMPUTERNAME>

.EXAMPLE
    PS>setupv2.ps1 <COMPUTERNAME>

.NOTES
    Version: 2.0
    Author: Brandon Amundson
    Creation Date: 10/08/2024
    Purpose/Change: Initial script development
#>
Param(
    # What to name the computer after finishing setup
    [Parameter(ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Mandatory)]
    [string]
    $ComputerName,
    # Domain name to add computer to
    [Parameter(ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Mandatory)]
    [string]
    $DomainName
)
#Requires -RunAsAdministrator

# Types required for Message Box initialization
Add-Type -AssemblyName PresentationCore,PresentationFramework

# Initialize window object for showing Message Boxes
$window = New-Object System.Windows.Window

# Install file variables
$downloads = "$env:USERPROFILE\Downloads"
$WUA = "https://go.microsoft.com/fwlink?LinkID=799445"
$update = "https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/updt/2023/09/windows10.0-kb5030300-x64_528f52f9e16c9da54d7b76d2542b3b1a1d484daf.msu"
$dellUpdate = "https://dl.dell.com/FOLDER11914128M/1/Dell-Command-Update-Windows-Universal-Application_9M35M_WIN_5.4.0_A00.EXE"
$dellUpdatePath = "$env:programfiles\dell\commandupdate\dcu-cli.exe"

# Array of files to cleanup
$cleanupFiles = @()

function runfile
{
    <#
        .SYNOPSIS
            Starts execution of script, downloads upgrade assistant, and calls
            to function dellSupport
    #>
    # If computer is below Windows 11 Version
    if((Get-ComputerInfo | Select-Object OSName, OSVersion).OsVersion -lt '10.0.22000')
    {
        # Download Windows 10 Upgrade Assistant
        Invoke-WebRequest $WUA -OutFile $downloads\Windows10UpgradeAssistant.exe
        # Add Upgrade Assistant to file cleanup array for later cleanup
        $cleanupFiles += "$downloads\Windows10UpgradeAssistant.exe"
        # run Upgrade Assistant
        Start-Process $downloads\Windows10UpgradeAssistant.exe
    }
    # call to dellSupport function
    dellSupport
}

function dellSupport
{
    <#
        .SYNOPSIS
            Function that downloads and installs Dell Command Update, then
            checks for updates with Dell Command Update
    #>
    # add commandUpdate to file cleanup
    $cleanupFiles += "$downloads\commandUpdate.exe"
    # download Dell Command Update with the Mozilla UserAgent to prevent it
    # from being blocked
    Invoke-WebRequest $dellUpdate -OutFile $downloads\commandUpdate.exe -UserAgent 'Mozilla'
    # Start the installer and wait for it to finish
    Start-Process $downloads\commandUpdate.exe -wait
    # scan for updates then apply them silently
    Start-Process -FilePath $dellUpdatePath -ArgumentList "/scan -silent"
    Start-Process -FilePath $dellUpdatePath -ArgumentList "/applyupdates -forceupdate=enable -silent -autosuspendbitlocker"
}

function checkLaptop
{
    <#
        .SYNOPSIS
            Looks to see if device is a laptop before calling the isLaptop
            of the script.  If unable to verify by WMI call, then it prompts
            for confirmation with a message box
    #>
    $chassis = (Get-CimInstance Win32_SystemEnclosure).ChassisTypes
    # Chassis types 9, 10, and 14 apply to laptop/tablet type form factors
    if($chassis -eq 9 -or $chassis -eq 10 -or $chassis -eq 14)
    {
        # Verify if device has a battery before confirming that device is a laptop
        if(Get-CimInstance Win32_Battery)
        {
            isLaptop
        }
        else
        {
            # If battery is not found, prompt user with Message Box and 
            # utilize the answer to proceed with remainder of script
            $msgboxinput = [System.Windows.MessageBox]::Show("Is this device a laptop?","Check device type",'yesno','information')
            switch($msgboxinput)
            {
                'Yes' { isLaptop }
                'No' { }
            }
        }
    }
}

function isLaptop
{
    <#
    .SYNOPSIS
        If device is a laptop, asks if a hotfix update needs to be applied via
        MessageBox
    #>
    $msgboxinput = [System.Windows.MessageBox]::Show($window,"Does this device need KB5030300 power issue hotfix?","Check device type",'yesno','information')
    switch($msgboxinput)
    {
        'Yes' { downloadUpdate }
        'No' { }
    }
}

function downloadUpdate
{
    <#
        .SYNOPSIS
            If a hotfix is needed for a laptop device, this function
            executes to download and install the hotfix
    #>
    # Download hotfix
    Invoke-WebRequest $update -OutFile $downloads\kb5030300.msu
    # Add to cleanup function
    $cleanupFiles += "$downloads\kb5030300.msu"
    # Run update installer silently
    Start-Process -FilePath $downloads\kb5030300.msu -ArgumentList "/s" -wait
}

function cleanup
{
    <#
        .SYNOPSIS
            Cleanup function to cleanup all files generated by this script
    #>
    foreach($file in $cleanupFiles)
    {
        Remove-Item -Force $file
    }
}

function rebootOptional
{
    <#
        .SYNOPSIS
            Function that renames the computer and asks if device needs a reboot.
            Final function of the script before exiting
    #>
    # If device is already in a domain, just rename it
    if((Get-CimInstance Win32_ComputerSystem).PartOfDomain -eq $TRUE)
    {
        Rename-Computer $ComputerName
    }
    # Otherwise rename the computer and add it to the domain
    else
    {
        Add-Computer -DomainName $DomainName -NewName $ComputerName -Credential
    }
    # Prompt asking if user wishes to reboot, if no, end of script
    $msgboxinput = [System.Windows.MessageBox]::Show($window,"A restart is required to make the requested changes.  Do you want to restart now?","Reboot Required",'yesno','information')
    switch($msgboxinput)
    {
        'Yes' { shutdown /r }
        'No' { exit }
    }
}

# Execution order, call functions
runfile
checklaptop
cleanup
rebootOptional