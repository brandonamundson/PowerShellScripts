<#
.DESCRIPTION
    Script to add a printer driver to the driver store
    in preparation for it to be used during a printer install
    by either a different script, different program, or to be
    used when manually installing a printer.   

.OUTPUTS
    C:\log.txt                       -- made for listing driver store before install
    C:\log1.txt                      -- made for listing driver store after install
    $env:userprofile\desktop\man.txt -- file diff in store after install

.EXAMPLE
    PS>addprintdriver.ps1 -infName <NAME> -driverName <NAME>
    PS>addprintdriver.ps1 -infName <NAME> -driverName <NAME> -testing

.NOTES
    Version: 2.0
    Author: Brandon Amundson
    Creation Date: 09/22/2024
    Purpose/Change: Improving script to allow better operability for testing
    and prevent unnecessary script modfication when testing is needed.
    Script documentation
#>
Param(
    [Parameter(Mandatory)]
    [string]
    $infname,
    [Parameter(Mandatory)]
    [string]
    $driverName,
    [Parameter()]
    [bool]
    $testing
)
$ErrorActionPreference='silentlycontinue'

Function installDriver()
{
    #stage driver to driver store
    C:\Windows\Sysnative\pnputil /add-driver "$PSSCRIPTROOT\drivers\$infname"
    #installs printer driver
    Add-PrinterDriver -name $drivername
}


switch ($testing) {
    {$testing -eq $true} {
        
        if("C:\log.txt") { Remove-Item C:\log*.txt -force }
        
        # common drive path for storing printer drivers
        $driverpath = "$env:SystemRoot\System32\spool\drivers\x64\3"
        
        # output log of all files in current state
        (Get-ChildItem $driverpath).Name > C:\log.txt
        
        installDriver

        # Gets all files in driver path after installing & outputs to file
        (Get-ChildItem $driverpath).Name > C:\log1.txt
        
        # reads in log files from before and after for comparison
        $a = Get-Content C:\log.txt
        $b = Get-Content C:\log1.txt
        
        # gets manufacturer name to name the post-comparison output file
        $man = C:\Windows\Sysnative\pnputil /enum-drivers /class printer |
            select-string -context 1 $infname | ForEach-Object { 
                ($_.context.postcontext[0] -split ': +')[1] }
        
        # outputs file of all changes made by driver within known directories
        # where files will not be removed automatically
        # this only runs when there are files that have changed within these
        # directories
        if($null -ne $(Compare-Object $a $b))
        {
            (Compare-Object $a $b).InputObject > "$env:UserProfile\Desktop\$man.txt"
        }
        
        #perform file cleanup
        Remove-Item C:\log*.txt -force
        
    }
    {$testing -ne $true} {
        installDriver
    }
}