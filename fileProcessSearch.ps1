<#
.DESCRIPTION
    Frees up file locked by process from disconnected session on server or
    host of servers and ends them.

.INPUTS
    proc - process name
    filePath - path to open file
    servers - array of hosts that might have process locking file

.EXAMPLE
    PS>fileProcessSearch -proc <process name> -filePath <path to locked file> -servers <hosts possibly locking file>

.EXAMPLE   
    PS>fileProcessSearch <process name> <path to locked file> <hosts possibly locking file>

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 10/06/2024
    Purpose/Change: Initial script development
#>
Param(
    # Process name
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $proc,
    # Path of file being locked
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $filePath,
    # string or array of strings of host servers
    [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
    [string]
    $servers    
)
#Requires -RunAsAdministrator

$Processes = @()
$location = [System.Collections.Generic.List[PSObject]]::new()

foreach($server in $servers)
{
    # get all process(es) matching filter for process requested
    $Processes = Get-CimInstance -Class Win32_Process -ComputerName $Server -Filter "Name='$proc'"
    # if any process(es) are found
    if($Processes)
    {
        foreach($Process in $Processes)
        {
            $Processid = $Process.handle
            $ProcessCmd = $Process.CommandLine
            try
            {
                # get file path split from command line argument and remove
                # "" surrounding it
                $file = ($ProcessCmd -split '"  ')[1].ToString().Trim('"')
                # verify if file we are looking for matches current file
                if($file -eq $filePath)
                {
                    # if it matches, log server, process, and file
                    $locationData = [PSCustomObject]@{
                        Server = $server
                        Processid = $Processid
                        File = $file
                    }
                    $location.Add($locationData)
                }
            }
            catch{}
        }
    }
}

# close each open process found
foreach($lock in $location)
{
    if($lock.File -eq $filePath)
    {
        Write-Output "Closing $($lock.File) on Server $($lock.Server) with ProcessID $($lock.Processid)`n`n"
        # taskkill /servername /processid /terminate process and child process(es)
        taskkill /s $($lock.Server) /pid $($lock.Processid) /t
    }
}