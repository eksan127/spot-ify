<#
================================== If you want to edit Please don't remove this ==================================
Created by @eksan127 and inspired from SpotX
Tool created to make it easier to use SpotX, all SpotX tools are one in this tool 
starting from installing spotify, uninstalling patches, spotify and changing the lyric theme.

Thanks

Source:
SpotX: https://github.com/SpotX-Official/SpotX
My Page: https://eksan127.gitbook.io/revanced-xsn-lite/
==================================================================================================================
#>

# INPUT VARIABLE
$ToolName = "Spot-ify Installer Tool"
$AppVersion = "V4.5"
$MsgContinue = "Back to Menu Press Enter"
$AccountFree = "Free Account"
$AccountPrem = "Premium Account"
$Theme = "spotify"
$LyricText = "With Theme Lyric"
$CacheText = "Cache Limit"
$Global:DefaultCache = 10000
$Global:SizeUnit = "MB"
$AppDataRoaming = $env:APPDATA
$PathSpot = "$AppDataRoaming\Spotify\Spotify.exe"
$url = 'https://raw.githubusercontent.com/SpotX-Official/SpotX/refs/heads/main/run.ps1'
$command = "-new_theme -confirm_uninstall_ms_spoti -confirm_spoti_recomended_over -block_update_on -DisableStartup -newFullscreenMode"
$Global:SpotStartText = "Do you want Start Spotify now"


# CUSTOM FUNCTION COLORING
function Write-Color {
    param(
        [Parameter(Mandatory=$true)][string[]]$Text,
        [Parameter(Mandatory=$true)][ConsoleColor[]]$Color
    )

    for ($i = 0; $i -lt $Text.Count; $i++) {
        Write-Host $Text[$i] -ForegroundColor $Color[$i] -NoNewline
    }
    Write-Host # Add a final newline
}
# Usage
# Write-Color -Text "Hello", " ", "World", "!" -Color Red, White, Blue, White

function Set-ConsoleWindowSize {
    param(
        [int]$Width,
        [int]$Height
    )

    # Get the current UI and create new size objects
    $rawUI = $Host.UI.RawUI
    $newSize = New-Object System.Management.Automation.Host.Size
    $newBufferSize = New-Object System.Management.Automation.Host.Size

    # Set the new dimensions
    $newSize.Width = $Width
    $newSize.Height = $Height
    $newBufferSize.Width = $Width
    # Ensure buffer height is at least as large as window height
    $newBufferSize.Height = [Math]::Max($Height, $rawUI.BufferSize.Height)

    # Set the BufferSize first, as WindowSize cannot be larger than BufferSize
    try {
        $rawUI.BufferSize = $newBufferSize
    } catch {
        #Write-Warning "Could not set buffer size. May be constrained by console limits."
    }
    
    # Set the WindowSize
    try {
        $rawUI.WindowSize = $newSize
    } catch {
        #Write-Error "Could not set window size. Ensure size is within screen limits."
    }
}
function CheckNullChar {
    param (
        [string]$InputChar
    )
    do {
        $user_input = $InputChar
        if ([string]::IsNullOrEmpty($user_input)) {
            $user_input = 'S'
            return $user_input
        }
    } while ([string]::IsNullOrEmpty($user_input))
}
function Get-ListThemeLyric {
    Clear-Host
    $CleanInt = 1
    $ArrLyric = @($null, "default", "red", "orange", "yellow", "spotify", "blue", "purple", "strawberry", "pumpkin", "sandbar", "radium", "oceano", "royal", "github", "discord", "drot", "forest", "fresh", "zing", "pinkle", "krux", "blueberry", "postlight")
    Write-Host "Available Theme Lyric:"
    Write-Host "[1] Default     [9]  Pumpkin  [17] Forest"
    Write-Host "[2] Red         [10] Sandbar  [18] Fresh"
    Write-Host "[3] Orange      [11] Radium   [19] Zing"
    Write-Host "[4] Yellow      [12] Oceano   [20] Pinkle"
    Write-Host "[5] Spotify     [13] Royal    [21] Krux"
    Write-Host "[6] Blue        [14] Github   [22] Blueberry"
    Write-Host "[7] Purple      [15] Discord  [23] Postlight"
    Write-Host "[8] Strawberry  [16] Drot"
    $LyricInput =""
    do {
        $LyricInput = Read-Host -Prompt "Please Chose Theme[1-23]?"
        if (CheckNullChar -InputChar $LyricInput -eq 'S'){
            Write-Host "Blank Input Not Allowed, Please Chose Theme Again" -BackgroundColor Red -ForegroundColor White
        }
        elseif ($CleanInt -eq 1 -and $LyricInput -match 0) {
                Write-Warning "Wrong Input"
        }
        elseif ($CleanInt -eq 1 -and $LyricInput -notmatch '^\d+$'){
                Write-Warning "Wrong Input"
        }
        elseif ($CleanInt -gt 1 -and $LyricInput -notmatch '^\d+$'){
                Write-Warning "Wrong Input"
        } 
        $CleanInt++
    } until ($LyricInput -match '^\d+$')
    [int]$LyricInput = $LyricInput
    # Check Input in Range 1 - 23
    if ($LyricInput -ge 1 -and $LyricInput -le 23){
        $LyricString = $ArrLyric[$LyricInput]
        return $LyricString
    }
    # Check Input less than 1 or greater than 23
    elseif ($LyricInput -lt 1 -or $LyricInput -gt 23) {
            Get-ListThemeLyric
    }
}

function InputCache {
    Clear-Host
    Write-Host "+----------------------------------------------------+"
    Write-Host "        Input Maximum Cache in range 500-20000"
    Write-Host "            This for Clearing Audio cache"
    Write-Host "+----------------------------------------------------+"
    $CleanCache = 1
    $CacheInput = ""
    do {
        $CacheInput = Read-Host -Prompt "Please Input Size Cache [500-20000]?"
        if (CheckNullChar -InputChar $CacheInput -eq 'S'){
            Write-Host "Blank Input Not Allowed, Input Again" -BackgroundColor Red -ForegroundColor White
        }
        elseif ($CleanCache -eq 1 -and $CacheInput -notmatch '^\d+$'){
            Write-Warning "Wrong Input"
        }
        elseif ($CleanCache -gt 1 -and $CacheInput -notmatch '^\d+$'){
            Write-Warning "Wrong Input"
        }
        $CleanCache++
    } until ($CacheInput -match '^\d+$')
    # Check Input in Range 500 - 20000
    [int]$CacheInput = $CacheInput
    if ($CacheInput -ge 500 -and $CacheInput -le 20000){
        return $CacheInput
    }
    else {
        Write-Warning "Wrong Input"
        InputCache
    }
}

#CHECKING EXE FOUND OR NOT
function StartSpot {
    #Write-Host "Cek Folder Spotify"
    if (Test-Path -Path $PathSpot -PathType Leaf){
        #File exist
        Clear-Host
        Write-Host "Opening Spotify, Pleaase Wait...." -ForegroundColor Green
        & $PathSpot
        Start-Sleep -Seconds 2
        #return $true
    }
    else {
        Write-Host "Spotify not Found!!!" -ForegroundColor Red
        Read-Host -Prompt $MsgContinue
        #return $false
    }
}

#CHOICE FOR YES OR NO
function Get-YesNoChoice {
    $CleanInt = 1
    $prompt = "Do you want to continue?[Y/N]"
    
    # Loop until a valid choice is made
    do {
        $choice = Read-Host -Prompt $prompt
        if (CheckNullChar -InputChar $choice -eq 'S'){
            Write-Host "Blank Input Not Allowed" -BackgroundColor Red -ForegroundColor White
        }
        elseif ($CleanInt -eq 1 -and $choice -notmatch '^[YN]$'){
            Write-Warning "Input Only Y or N"
        }
        elseif ($CleanInt -gt 1 -and $choice -notmatch '^[YN]$') {
            Write-Warning "Input Only Y or N"
        }
        $CleanInt++
        # Check if the choice matches 'y' or 'n' using regex (case-insensitive)
    } until ($choice -match '^[YN]$')
    
    # Return True for 'y'/'Y' and False for 'n'/'N'
    if ($choice -match '^[Y]$') {
        return $true
    } else {
        return $false
    }
}

#Set window to 100 columns wide and 40 lines high
Set-ConsoleWindowSize -Width 85 -Height 40
$host.UI.RawUI.WindowTitle = $ToolName

# HOME MENU
function Show-Menu {
    Clear-Host
    #Write-Host "This version only for test and not work for now" -BackgroundColor Red -ForegroundColor White
    Write-Host " ++===============================================================================++"
    Write-Host "                         Spot-ify Installer With SpotX Patch"                    
    Write-Color -Text "                                        ", "$AppVersion" -Color White, Cyan                                         
    Write-Host "                           Thanks to SpotX and @amd64fox"
    Write-Host " ++===============================================================================++"
    #Write-Color -Text "          ", " Warning:", " This tool for some Antivirus will be marked as virus" -Color White, Yellow, White
    Write-Host " "
    Write-Host "MENU:"
    Write-Host "[1] Recomended Install (for Free Account)" -ForegroundColor Green
    Write-Host "[2] Free Account" -ForegroundColor Green
    Write-Host "[3] Premium Account" -ForegroundColor Green
    Write-Host "[Q] Quit" -ForegroundColor Red
}
# CHOICE USER MENU
do {
    Show-Menu
    $Menu = Read-Host -Prompt "Enter your Choice [1,2,3..,Q]?"
    Write-Host ""

    switch ($Menu) {
        '1' {
            Clear-Host
            $host.UI.RawUI.WindowTitle = "Recommended Install"
            Write-Host "====================================================================================="
            Write-Host " "
            Write-Host "  Recommended installation is a simple installation process without"
            Write-Host "  selecting a theme, setting the cache so that it speeds up the installation process."
            Write-Host "  However, if you want to customize, you can use other installation menu."
            Write-Host " "
            Write-Host "====================================================================================="
            Write-Host " "
            Write-Host "You Will Install Recommended version With:"
            Write-Host "-" $AccountFree
            Write-Color -Text "-", " $LyricText", " $ThemeRecom" -Color White, White, Green
            Write-Host "-" $CacheText $DefaultCache $SizeUnit
            if (Get-YesNoChoice) {
                Write-Color -Text "Please Wait..." -Color Green
                Start-Sleep -Seconds 2
                Clear-Host
                #Write-Host $url
                Invoke-Expression "& { $(Invoke-WebRequest -useb $url) } $command -cache_limit $DefaultCache -lyrics_stat $Theme"
                #Write-Host $command "$Theme"
                Write-Host "Spotify Succesfully Installed" -ForegroundColor Green
                Write-Host ""
                Write-Color -Text "$SpotStartText" -Color Cyan
                if (Get-YesNoChoice){
                    StartSpot #Call Function StartSpot
                }
                else {
                    Show-Menu
                }
            } else {
                Show-Menu
            }
        }
        '2' {
            $host.UI.RawUI.WindowTitle = "Free Account"
            $LyricFree = Get-ListThemeLyric
            $CacheFree = InputCache
            Clear-Host
            Write-Host "You Will Install:"
            Write-Host "-" $AccountFree
            Write-Host "- Theme" $LyricFree
            Write-Host "- Cache Size" $CacheFree$SizeUnit
            if (Get-YesNoChoice){
                #$Theme = $LyricFree
                Write-Color -Text "Please Wait..." -Color Green
                Start-Sleep -Seconds 2
                Clear-Host
                Invoke-Expression "& { $(Invoke-WebRequest -useb $url) } $command -cache_limit $CacheFree -lyrics_stat $LyricFree"
                Write-Host "Spotify Succesfully Installed" -ForegroundColor Green
                Write-Host ""
                Write-Color -Text "$SpotStartText" -Color Cyan
                if (Get-YesNoChoice){
                    StartSpot #Call Function StartSpot
                }
                else {
                    Show-Menu
                }
            }
            else {
                Show-Menu
            }
        }
        '3' {
            $Host.UI.RawUI.WindowTitle = "Premum Account"
            $LyricPrem = Get-ListThemeLyric
            $CachePrem = InputCache
            Clear-Host
            Write-Host "You Will Install"
            Write-Host "-" $AccountPrem
            Write-Host "- Theme" $LyricPrem
            Write-Host "- Cache Size" $CachePrem$SizeUnit
            if (Get-YesNoChoice){
                Write-Color -Text "Please Wait..." -Color Green
                Start-Sleep -Seconds 2
                Clear-Host
                Invoke-Expression "& { $(Invoke-WebRequest -useb $url) } -premium $command -cache_limit $CacheFree -lyrics_stat $LyricFree"
                Write-Host "Spotify Succesfully Installed" -ForegroundColor Green
                Write-Host ""
                Write-Color -Text "$SpotStartText" -Color Cyan
                if (Get-YesNoChoice){
                    StartSpot #Call Function StartSpot
                }
                else {
                    Show-Menu
                }
            }
            else {
                Show-Menu
            }
        }
        'q' {
            Write-Host "Quitting Tool" -ForegroundColor Yellow
            return
        }
        Default {
            Write-Host "Invalid selection. Please try again." -ForegroundColor Red
            Write-Host "`e[1A`e[K" -NoNewline
            #Read-Host -Prompt $MsgContinue
        }
    }
} until ($Menu -eq 'q')
