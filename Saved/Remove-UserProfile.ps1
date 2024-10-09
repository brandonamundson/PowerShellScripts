<#
.DESCRIPTION
    Removes user profile from any networked Computer.  Searches Active
    Directory and outputs if it exists or not.  Outputs all names that
    exists on the pc and prompts for removal   

.INPUTS
    NONE

.OUTPUTS
    NONE

.EXAMPLE
    PS>Remove-UserProfile.ps1

.EXAMPLE
    PS>Remove-UserProfile

.NOTES
    Version: 1.0
    Author: unknown
    Creation Date: unknown
#>

Function Remove-usrProfile{
    <#
    .Description
       Deletes a user profile properly off remote machine.
       WARNING: DOES NOT BACK UP DATA!  Use at your own peril.
       Added User Display Name as the selection corresponding it to their Logon
       Name, and deletion of files if no CIM instance was found.
    #>

    Param(
        # Name of pc to remove profiles from
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory)]
        [string]
        $ComputerName
    )
    # If computer is not available, output error and start over
    If(-not(Test-Connection -ComputerName $ComputerName -Count 1 -Quiet ))
    {
        Write-Host "Computer seems to be offline, please check name spelling." `
            -ForegroundColor DarkYellow; Write-Host ""
        &Remove-usrProfile
    }
    else {
        # create list of names of users logged into computer
        $menu = (Get-ChildItem "\\$ComputerName\c$\users"  | 
            Sort-Object LastWriteTime -Descending).Name
        # for each user
        $userinfo1 = foreach ($user in $menu)
        {
            # Sleep, then get user's full name from username
            Start-Sleep -Milliseconds 2
            $userinfo = (net user $user /domain | Select-String "Full Name" `
                -ErrorAction SilentlyContinue) -replace `
                "Full Name                   ", "" 2>&1 | Out-String -Stream
           #$userinfo = (get-aduser $user | select Name)
            if ($userinfo.Length -lt 4)
            {    
                "$user - NO DISPLAY NAME in ADUC"  # output
            }
            else
            {
                if ($LASTEXITCODE -eq 2)
                {
                    "$user   -   ACCOUNT NOT in ADUC"    # output
                }
                else
                {
                    if ($LASTEXITCODE -eq 0)
                    {
                        $userinfo  # output
                    }
                }
            }
        }


        Write-Warning "Ensure user usrprofiles are no longer active and/or, have usrprofiles be backed-up!"

        Write-Host "RESULTS:" -BackgroundColor Black -ForegroundColor White

        # Output numbered list of usernames
        for ($i=0; $i -lt $userinfo1.Count; $i++)
        {
            Write-Host "$($i): $($userinfo1[$i])"
        } #END LIST OF POSSIBLE NAMES 

        Write-Host ""

        Write-Host "For multiple users, seperate using a SPACE(1 2 3)" 
        
        # Get input on which users to remove
        $selection = Read-Host "ENTER THE NUMBER of the user(s) or Q to quit"

        $selection = $selection -split " "

        # for each selection
        foreach($index in $selection)
        {
            $usrProfile = $menu[$index]
            Write-Host "Deleting user: $($userinfo1[$index]) `
                LogonName:$usrProfile "
            
            # remove user
            $del = Get-CimInstance -ComputerName $ComputerName -Class Win32_UserProfile |
                Where-Object { $_.LocalPath.split('\')[-1] -eq $usrProfile }

            # if del is null, then get-ciminstance did not find a user profile to remove
            # will need to remove manually
            If($null -eq $del)
            {
                Write-Warning "No CIM instance found on system, profile has been deleted but files persist."    
                Write-Host "Attempting to delete files, please wait. . ." 
                
                # remove all items in user path
                Remove-Item -Path "\\$ComputerName\c$\users\$usrProfile" -Recurse -Force       
                Write-Host 'Remove-item, has finished.'
                Write-Host ""
     
                Start-Sleep -Seconds 2
                Write-Host "Checking if profile is still there. . ."

                # verify removal
                $TestPath = Test-Path -Path "\\$ComputerName\c$\users\$usrProfile"    
                If($TestPath -eq $false){ Write-Host "User persistent files have been deleted. `
                    Continuing. . . ." -ForegroundColor Green}
            }
            # otherwise user profile was found
            else
            {
                # remove profile via Remove-CimInstance
                Get-CimInstance -ComputerName $ComputerName -Class Win32_UserProfile |
                    Where-Object { $_.LocalPath.split('\')[-1] -eq $usrProfile } |
                    Remove-CimInstance 

                Write-Host "user profile has been deleted" -ForegroundColor Red

                Write-Host ""
            }
        }
    }
}

Remove-usrProfile