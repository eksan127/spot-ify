<#
================================== If you want to edit Please don't remove this ==================================
Created by @eksan127 and inspired from SpotX
Tool created to make it easier to use SpotX, all SpotX tools are one in this tool 
starting from installing spotify, uninstalling patches, spotify and changing the lyric theme.

Thanks

Source:
SpotX: https://github.com/SpotX-Official/SpotX
My Page: https://eksan127.gitbook.io/xsn-lite/
==================================================================================================================
#>

# INPUT VARIABLE
$ToolName = "Spot-ify Installer Tool"
$AppVersion = "v5.1"
$MsgContinue = "Back to Menu, Press Enter"
$AccountFree = "Free"
$AccountPrem = "Premium"
$Theme = "spotify"
$LyricText = "With Theme Lyric"
$CacheText = "Cache Size Limit"
$Global:DefaultCache = 10000
$Global:SizeUnit = "MB"
$AppDataRoaming = $env:APPDATA
$PathSpot = "$AppDataRoaming\Spotify\Spotify.exe"
$PathSpotFol = "$AppDataRoaming\Spotify"
$url = 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1'
$CommandParam = "-new_theme -confirm_uninstall_ms_spoti -block_update_on -DisableStartup -newFullscreenMode"
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

function chekrunning {
    $appName = "Spotify"
    $processrun = Get-Process -Name $appName -ErrorAction SilentlyContinue
    if ($processrun){
        Write-Host "$appName is running, Please wait..." -ForegroundColor DarkYellow
        Start-Sleep -Seconds 2
        Stop-Process -InputObject $processrun -Force
        Write-Host "$appName has been terminated." -ForegroundColor Green
    } else {
        Write-Host "$appName is not currently running." -ForegroundColor Green
    }
}

function remove_patch{
    param (
        [string]$FolderPath
    )
    Write-Host ""
    Write-Host "Please wait removing patch..."
    if (Test-Path -Path "$FolderPath\chrome_elf.dll.bak" -PathType Leaf){
        Remove-Item -Path "$FolderPath\chrome_elf.dll" -Force -ErrorAction SilentlyContinue
        Move-Item -Path "$FolderPath\chrome_elf.dll.bak" -Destination "$FolderPath\chrome_elf.dll" -Force -ErrorAction SilentlyContinue
    }

    if (Test-Path -Path "$FolderPath\Spotify.dll.bak" -PathType Leaf){
        Remove-Item -Path "$FolderPath\Spotify.dll" -Force -ErrorAction SilentlyContinue
        Move-Item -Path "$FolderPath\Spotify.dll.bak" -Destination "$FolderPath\Spotify.dll" -Force -ErrorAction SilentlyContinue
    }

    if (Test-Path -Path "$FolderPath\Spotify.bak" -PathType Leaf){
        Remove-Item -Path "$FolderPath\Spotify.exe" -Force -ErrorAction SilentlyContinue
        Move-Item -Path "$FolderPath\Spotify.bak" -Destination "$FolderPath\Spotify.exe" -Force -ErrorAction SilentlyContinue
    }

    if (Test-Path -Path "$FolderPath\Apps\xpui.bak" -PathType Leaf){
        Remove-Item -Path "$FolderPath\Apps\xpui.spa" -Force -ErrorAction SilentlyContinue
        Move-Item -Path "$FolderPath\Apps\xpui.bak" -Destination "$FolderPath\Apps\xpui.spa" -Force -ErrorAction SilentlyContinue
    }

    if (Test-Path -Path "%temp%\SpotX_Temp"){
        Remove-Item -Path "%temp%\SpotX_Temp\*" -Recurse
    }

    Write-Host "Patch successfully removed" -ForegroundColor Green
    Write-Host ""
    Read-Host -Prompt $MsgContinue
}

function Get-Recommended_install {
    param (
        [string]$recom_account,
        [string]$recom_lyrictext,
        [string]$recom_theme,
        [string]$recom_cachetext,
        [int]$recom_defaultcache,
        [string]$recom_sizeunit
    )
        Write-Host " +---------------------------------------------------------------------------------+"
        Write-Host " "
        Write-Host "   Recommended installation is a simple installation process without,"
        Write-Host "   Selecting a theme, setting the cache Size" 
        Write-Host "   So that it speeds up the installation process."
        Write-Host "   However, if you want to customize, you can use other installation menu."
        Write-Host " "
        Write-Host " +---------------------------------------------------------------------------------+"
        Write-Host " "
        Write-Host "You will Installing with:"
        Write-Host "-" $recom_account "Account"
        Write-Color -Text "-", " $recom_lyrictext", " $recom_theme" -Color White, White, Green
        Write-Host "-" $recom_cachetext $recom_defaultcache $recom_sizeunit
        if (Get-YesNoChoice) {
            if ($recom_account -match "Free"){
                Write-Color -Text "Please Wait..." -Color Green
                Start-Sleep -Seconds 2
                Clear-Host
                Invoke-Expression "& { $(Invoke-WebRequest -useb $url) } $CommandParam -cache_limit $recom_defaultcache -lyrics_stat $recom_theme"
                Write-Host "Spotify Succesfully Installed" -ForegroundColor Green
                Write-Host ""
                Get-ChoiceRunSpot
            } elseif ($recom_account -match "Premium") {
                Write-Color -Text "Please Wait..." -Color Green
                Start-Sleep -Seconds 2
                Clear-Host
                Invoke-Expression "& { $(Invoke-WebRequest -useb $url) } -premium $CommandParam -cache_limit $recom_defaultcache -lyrics_stat $recom_theme"
                Write-Host "Spotify Succesfully Installed" -ForegroundColor Green
                Write-Host ""
                Get-ChoiceRunSpot
            }
        } else {
            Show-Menu
        }
}

function Get-Custom_Install {
    param (
        [string]$custom_account,
        [string]$custom_lyrictext,
        [string]$custom_theme,
        [string]$custom_cachetext,
        [int]$custom_defaultcache,
        [string]$custom_sizeunit
    )
    Write-Host "You will Installing with:"
    Write-Host "-" $custom_account "Account"
    Write-Color -Text "-", " $custom_lyrictext", " $custom_theme" -Color White, White, Green
    Write-Host "-" $custom_cachetext $custom_defaultcache $custom_sizeunit
    if (Get-YesNoChoice){
        if ($custom_account -match "Free"){
            Write-Color -Text "Please Wait..." -Color Green
            Start-Sleep -Seconds 2
            Clear-Host
            Invoke-Expression "& { $(Invoke-WebRequest -useb $url) } $CommandParam -cache_limit $custom_defaultcache -lyrics_stat $custom_theme"
            Write-Host "Spotify Succesfully Installed" -ForegroundColor Green
            Write-Host ""
            Get-ChoiceRunSpot
        } elseif ($custom_account -match "Premium") {
            Write-Color -Text "Please Wait..." -Color Green
            Start-Sleep -Seconds 2
            Clear-Host
            Invoke-Expression "& { $(Invoke-WebRequest -useb $url) } -premium $CommandParam -cache_limit $custom_defaultcache -lyrics_stat $custom_theme"
            Write-Host "Spotify Succesfully Installed" -ForegroundColor Green
            Write-Host ""
            Get-ChoiceRunSpot
        }
    } else {
        Show-Menu
    }
}

function Get-ChoiceRunSpot {
    Write-Color -Text "$SpotStartText" -Color Cyan
    if (Get-YesNoChoice){
        StartSpot #Call Function StartSpot
    }
    else {
        Show-Menu
    }
    
}

#Set window to 100 columns wide and 40 lines high
Set-ConsoleWindowSize -Width 85 -Height 40

# HOME MENU
function Show-Menu {
    Clear-Host
    $host.UI.RawUI.WindowTitle = $ToolName
    #Write-Host "This version only for test and not work for now" -BackgroundColor Red -ForegroundColor White
    Write-Host " +=================================================================================+"
    Write-Host "                         Spot-ify Installer With SpotX Patch"                    
    Write-Color -Text "                                        ", "$AppVersion" -Color White, Cyan                                         
    Write-Host "                           Thanks to SpotX and @amd64fox"
    Write-Host " +=================================================================================+"
    Write-Host " "
    Write-Host " MENU:"
    Write-Host " ------------------------------------------------"
    Write-Host " Recommended Install:"
    Write-Host "  [1] Free Account" -ForegroundColor Green
    Write-Host "  [2] Premium Account" -ForegroundColor Green
    Write-Host " ------------------------------------------------"
    Write-Host " Custom Install:"
    Write-Host "  [3] Free Account" -ForegroundColor Green
    Write-Host "  [4] Premium Account" -ForegroundColor Green
    Write-Host " ------------------------------------------------"
    Write-Host "  [5] Uninstall Patch" -ForegroundColor DarkYellow
    Write-Host "  [Q] Quit" -ForegroundColor Red
    Write-Host " "
}
# CHOICE USER MENU
do {
    Show-Menu
    $Menu = Read-Host -Prompt "Enter your Choice [1,2,3..,Q]?"
    switch ($Menu) {
        '1' {
            Clear-Host
            $host.UI.RawUI.WindowTitle = "Recommended Install"
            Get-Recommended_install -recom_account "$AccountFree" -recom_lyrictext "$LyricText" -recom_theme "$Theme" -recom_cachetext "$CacheText" -recom_defaultcache $DefaultCache -recom_sizeunit "$SizeUnit"
        }
        '2'{
            Clear-Host
            $host.UI.RawUI.WindowTitle = "Recommended Install"
            Get-Recommended_install -recom_account "$AccountPrem" -recom_lyrictext "$LyricText" -recom_theme "$Theme" -recom_cachetext "$CacheText" -recom_defaultcache $DefaultCache -recom_sizeunit "$SizeUnit"
        }
        '3' {
            $host.UI.RawUI.WindowTitle = "Custom Install"
            $LyricFree = Get-ListThemeLyric
            $CacheFree = InputCache
            Clear-Host
            Get-Custom_Install -custom_account "$AccountFree" -custom_lyrictext "$LyricText" -custom_theme "$LyricFree" -custom_cachetext "$CacheText" -custom_defaultcache "$CacheFree" -custom_sizeunit "$SizeUnit"
        }
        '4' {
            $Host.UI.RawUI.WindowTitle = "Custom Install"
            $LyricPrem = Get-ListThemeLyric
            $CachePrem = InputCache
            Get-Custom_Install -custom_account "$AccountPrem" -custom_lyrictext "$LyricText" -custom_theme "$LyricPrem" -custom_cachetext "$CacheText" -custom_defaultcache "$CachePrem" -custom_sizeunit "$SizeUnit"
        }
        '5' {
            Clear-Host
            $Host.UI.RawUI.WindowTitle = "Uninstall Patch"
            Write-Host "+-----------------------------------------------------------------+"
            Write-Host "  This only Uninstall Patch "
            Write-Host "  Then the Spotify will restore to Default version (Un-patching)"
            Write-Host "+-----------------------------------------------------------------+"
            if (Get-YesNoChoice){
                chekrunning
                remove_patch -FolderPath $PathSpotFol
            } else {
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
        }
    }
} until ($Menu -eq 'q')
