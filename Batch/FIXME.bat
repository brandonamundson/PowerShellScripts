:::::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights::
:::::::::::::::::::::::::::::::::::::::::::
@echo off
CLS 
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================
 
:checkPrivileges 
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges ) 
 
:getPrivileges 
if '%1'=='ELEV' (shift & goto gotPrivileges)  
ECHO. 
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation 
ECHO **************************************
 
setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs" 
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs" 
"%temp%\OEgetPrivileges.vbs" 
exit /B 
 
:gotPrivileges 
::::::::::::::::::::::::::::
:START
::::::::::::::::::::::::::::
setlocal & pushd .
 
:::::::::::::::::::::::::::::::::::::::::::
:: Run multiple sfc scans and dism       ::
:: cleanup operations to restore         ::
:: corrupted Windows OS files.           ::
:: Run check disk to ensure no file      ::
:: corruption.                           ::
:::::::::::::::::::::::::::::::::::::::::::
REM Run shell as admin
::::::::::::::::::::::::::::
sfc /scannow
dism /online /cleanup-image /startcomponentcleanup
sfc /scannow
dism /online /cleanup-image /scanhealth
sfc /scannow
dism /online /cleanup-image /restorehealth
sfc /scannow
echo y | chkdsk /b /x
echo "shutdown in 30 seconds"
shutdown /r /f /t 30