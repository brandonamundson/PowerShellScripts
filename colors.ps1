<#
.DESCRIPTION
    Output every combination of colors for foreground and background, excluding
    where the colors match to avoid unreadable outputs.   

.INPUTS
    NONE   

.OUTPUTS
    NONE   

.EXAMPLE
    PS>colors.ps1

.NOTES
    Version: 1.0
    Author: Brandon Amundson
    Creation Date: 10/31/2024
    Purpose/Change: Initial script development
#>

# Cycle through every combination of colors for background and foreground
# Output, exclude where the colors are the same
foreach($bg in $color)
{
    foreach($fg in $color)
    {
        if($fg -ne $bg)
        {
            # Output color combination for sample text colored and colored background
            Write-Host "Writing in $fg on a $bg background" -ForegroundColor $fg -BackgroundColor $bg
        }
    }
    # Output blank line in betweekn each background color change
    Write-Host "`n"
}