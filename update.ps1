<#
.SYNOPSIS

    Download and run Windows 10 Update Assistant

.EXAMPLE

    PS> .\update.ps1    

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 07/30/2024
    Purpose/Change: Initial script development
#>


# Get Windows 10 Update Assistant download from Microsoft and save to Downloads file
wget https://go.microsoft.com/fwlink?LinkID=799445 -OutFile $env:userprofile\Downloads\Win10UA.exe
# Run Update Assistant
Start-Process $env:userprofile\Downloads\Win10UA.exe