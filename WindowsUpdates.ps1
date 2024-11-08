<#
.SYNOPSIS
    Check for updates and install them -- very interactive, not silent
   
.INPUTS
    NONE

.OUTPUTS
    NONE

.EXAMPLE
    PS>WindowsUpdates.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 10/31/2024
    Purpose/Change: Initial script development
#>

# Set Execution Policy to Remote Signed to allow updates to work
set-executionpolicy remotesigned

# Install and import the update module
install-module pswindowsupdate
import-module pswindowsupdate

# Check for updates
get-windowsupdate
# Install updates
install-windowsupdate