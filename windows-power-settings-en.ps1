# Windows 10 Power Settings Configuration Script
# Sets display timeout to 30 minutes, sleep timeout to 1 hour, console lock display timeout to 5 minutes

param(
    [switch]$RestoreDefaults,
    [switch]$ShowCurrentSettings,
    [switch]$WhatIf
)

# Power scheme settings
$DisplayTimeout = 1800    # 30 minutes in seconds
$SleepTimeout = 3600      # 1 hour in seconds
$ConsoleLockTimeout = 300 # 5 minutes in seconds

# Pause and exit function
function Pause-AndExit {
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    try {
        $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    }
    catch {
        Start-Sleep -Seconds 2
    }
}

# Show error message and exit
function Show-ErrorAndExit {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
    Pause-AndExit
    exit 1
}

# Check PowerShell version
try {
    $psVersion = $PSVersionTable.PSVersion.Major
    if ($psVersion -lt 5) {
        Show-ErrorAndExit "PowerShell 5.0 or higher is required. Current version: $psVersion"
    }
}
catch {
    Show-ErrorAndExit "Unable to get PowerShell version information."
}

# Show current power settings
function Show-CurrentSettings {
    Write-Host "Current Power Settings:" -ForegroundColor Yellow
    Write-Host "========================" -ForegroundColor Yellow

    try {
        # Get current power scheme
        $currentScheme = powercfg.exe /getactivescheme 2>$null
        if ($LASTEXITCODE -eq 0 -and $currentScheme) {
            $schemeName = ($currentScheme -split '[\(\)]')[1]
            Write-Host "Active Power Scheme: $schemeName" -ForegroundColor Cyan
        } else {
            Write-Host "Unable to get power scheme information" -ForegroundColor Red
        }

        # Show current timeout values
        $displayAC = powercfg.exe /query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 2>$null | Select-String "Current AC Power Setting Index:"
        $displayDC = powercfg.exe /query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 2>$null | Select-String "Current DC Power Setting Index:"
        $sleepAC = powercfg.exe /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 2>$null | Select-String "Current AC Power Setting Index:"
        $sleepDC = powercfg.exe /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 2>$null | Select-String "Current DC Power Setting Index:"
        $consoleLockAC = powercfg.exe /query SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 2>$null | Select-String "Current AC Power Setting Index:"
        $consoleLockDC = powercfg.exe /query SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 2>$null | Select-String "Current DC Power Setting Index:"

        if ($displayAC) {
            Write-Host "Display Timeout (AC): $(Convert-SecondsToMinutes $((($displayAC -split ':')[1]).Trim())) minutes" -ForegroundColor White
        }
        if ($displayDC) {
            Write-Host "Display Timeout (DC): $(Convert-SecondsToMinutes $((($displayDC -split ':')[1]).Trim())) minutes" -ForegroundColor White
        }
        if ($sleepAC) {
            Write-Host "Sleep Timeout (AC): $(Convert-SecondsToMinutes $((($sleepAC -split ':')[1]).Trim())) minutes" -ForegroundColor White
        }
        if ($sleepDC) {
            Write-Host "Sleep Timeout (DC): $(Convert-SecondsToMinutes $((($sleepDC -split ':')[1]).Trim())) minutes" -ForegroundColor White
        }
        if ($consoleLockAC) {
            Write-Host "Console Lock Display Timeout (AC): $(Convert-SecondsToMinutes $((($consoleLockAC -split ':')[1]).Trim())) minutes" -ForegroundColor White
        }
        if ($consoleLockDC) {
            Write-Host "Console Lock Display Timeout (DC): $(Convert-SecondsToMinutes $((($consoleLockDC -split ':')[1]).Trim())) minutes" -ForegroundColor White
        }
    }
    catch {
        Write-Host "Error getting power settings:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Convert seconds to minutes
function Convert-SecondsToMinutes {
    param([int]$seconds)
    if ($seconds -eq 0) {
        return "Never"
    }
    return [math]::Round($seconds / 60, 1)
}

# Set power timeouts
function Set-PowerTimeouts {
    Write-Host "Setting Power Timeouts..." -ForegroundColor Green

    try {
        # Set display timeout to 30 minutes (1800 seconds) for both AC and DC power
        if ($WhatIf) {
            Write-Host "WhatIf: powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE $DisplayTimeout" -ForegroundColor Gray
            Write-Host "WhatIf: powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE $DisplayTimeout" -ForegroundColor Gray
        } else {
            powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE $DisplayTimeout 2>$null | Out-Null
            powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE $DisplayTimeout 2>$null | Out-Null
        }

        # Set sleep timeout to 1 hour (3600 seconds) for both AC and DC power
        if ($WhatIf) {
            Write-Host "WhatIf: powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE $SleepTimeout" -ForegroundColor Gray
            Write-Host "WhatIf: powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE $SleepTimeout" -ForegroundColor Gray
        } else {
            powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE $SleepTimeout 2>$null | Out-Null
            powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE $SleepTimeout 2>$null | Out-Null
        }

        # Set console lock display timeout to 5 minutes (300 seconds) for both AC and DC power
        if ($WhatIf) {
            Write-Host "WhatIf: powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $ConsoleLockTimeout" -ForegroundColor Gray
            Write-Host "WhatIf: powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $ConsoleLockTimeout" -ForegroundColor Gray
        } else {
            powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $ConsoleLockTimeout 2>$null | Out-Null
            powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $ConsoleLockTimeout 2>$null | Out-Null
        }

        # Apply all changes
        if (-not $WhatIf) {
            powercfg.exe /setactive SCHEME_CURRENT 2>$null | Out-Null
        }

        Write-Host "Power settings updated successfully!" -ForegroundColor Green
        Write-Host "- Display timeout: 30 minutes" -ForegroundColor Cyan
        Write-Host "- Sleep timeout: 1 hour" -ForegroundColor Cyan
        Write-Host "- Console lock display timeout: 5 minutes" -ForegroundColor Cyan

    }
    catch {
        Write-Error "Failed to set power timeouts: $($_.Exception.Message)"
        Show-ErrorAndExit "Please check if running as Administrator."
    }
}

# Restore default power settings
function Restore-DefaultSettings {
    Write-Host "Restoring default power settings..." -ForegroundColor Yellow

    try {
        # Restore default display timeout (usually 10 minutes)
        powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 600 2>$null | Out-Null
        powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 600 2>$null | Out-Null

        # Restore default sleep timeout (usually 30 minutes for AC, 15 minutes for DC)
        powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 1800 2>$null | Out-Null
        powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 900 2>$null | Out-Null

        # Restore default console lock timeout (usually 1 minute)
        powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 60 2>$null | Out-Null
        powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 60 2>$null | Out-Null

        # Apply changes
        powercfg.exe /setactive SCHEME_CURRENT 2>$null | Out-Null

        Write-Host "Default power settings restored!" -ForegroundColor Green

    }
    catch {
        Write-Error "Failed to restore default settings: $($_.Exception.Message)"
        Show-ErrorAndExit "Please check if running as Administrator."
    }
}

# Main execution
Write-Host "Windows 10 Power Settings Configuration Script" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta

# Check execution policy
try {
    $executionPolicy = Get-ExecutionPolicy
    Write-Host "Current Execution Policy: $executionPolicy" -ForegroundColor Cyan

    if ($executionPolicy -eq "Restricted") {
        Show-ErrorAndExit "Execution policy restricts script execution. Please run the following command and try again:`nSet-ExecutionPolicy RemoteSigned -Scope CurrentUser"
    }
}
catch {
    Write-Host "Unable to check execution policy, continuing..." -ForegroundColor Yellow
}

# Check if running as administrator
try {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Warning "Warning: This script requires administrator privileges to modify power settings."
        Write-Host "If not running as administrator, the script will run in read-only mode." -ForegroundColor Yellow
        Write-Host ""

        # If not administrator, only allow view mode
        if (-not $ShowCurrentSettings) {
            Write-Host "Switching to view mode..." -ForegroundColor Yellow
            $ShowCurrentSettings = $true
        }
    }
}
catch {
    Write-Host "Unable to check administrator privileges, continuing..." -ForegroundColor Yellow
    $isAdmin = $false
}

# Handle different modes
try {
    if ($ShowCurrentSettings) {
        Show-CurrentSettings
    }
    elseif ($RestoreDefaults) {
        if ($isAdmin) {
            Restore-DefaultSettings
        }
        else {
            Show-ErrorAndExit "Restoring default settings requires administrator privileges. Please run PowerShell as Administrator."
        }
    }
    else {
        if ($WhatIf) {
            Write-Host "WhatIf Mode: Showing what would be changed..." -ForegroundColor Gray
        }

        if ($isAdmin) {
            Set-PowerTimeouts
        }
        else {
            Write-Host "No administrator privileges, cannot modify power settings." -ForegroundColor Red
            Write-Host "Current Power Settings:" -ForegroundColor Yellow
            Show-CurrentSettings
        }
    }

    Write-Host "Script completed." -ForegroundColor Magenta

}
catch {
    Show-ErrorAndExit "Error during script execution: $($_.Exception.Message)"
}

# Pause and wait for user to press any key to exit
Pause-AndExit
