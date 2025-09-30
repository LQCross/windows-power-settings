# Windows 10 Power Settings Configuration Script (Chinese Display)
# Sets display timeout to 30 minutes, sleep timeout to 1 hour, console lock display timeout to 5 minutes

# Ensure proper encoding for Chinese characters

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
    Write-Host "按任意键退出..." -ForegroundColor Yellow
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
        Show-ErrorAndExit "需要 PowerShell 5.0 或更高版本。当前版本: $psVersion"
    }
}
catch {
    Show-ErrorAndExit "无法获取 PowerShell 版本信息。"
}

# Show current power settings
function Show-CurrentSettings {
    Write-Host "当前电源设置：" -ForegroundColor Yellow
    Write-Host "========================" -ForegroundColor Yellow

    try {
        # Get current power scheme
        $currentScheme = powercfg.exe /getactivescheme 2>$null
        if ($LASTEXITCODE -eq 0 -and $currentScheme) {
            $schemeName = ($currentScheme -split '[\(\)]')[1]
            Write-Host "活动电源方案：$schemeName" -ForegroundColor Cyan
        } else {
            Write-Host "无法获取电源方案信息" -ForegroundColor Red
        }

        # Show current timeout values
        $displayAC = powercfg.exe /query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 2>$null | Select-String "Current AC Power Setting Index:"
        $displayDC = powercfg.exe /query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 2>$null | Select-String "Current DC Power Setting Index:"
        $sleepAC = powercfg.exe /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 2>$null | Select-String "Current AC Power Setting Index:"
        $sleepDC = powercfg.exe /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 2>$null | Select-String "Current DC Power Setting Index:"
        $consoleLockAC = powercfg.exe /query SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 2>$null | Select-String "Current AC Power Setting Index:"
        $consoleLockDC = powercfg.exe /query SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 2>$null | Select-String "Current DC Power Setting Index:"

        if ($displayAC) {
            Write-Host "显示器超时（交流电源）：$(Convert-SecondsToMinutes $((($displayAC -split ':')[1]).Trim())) 分钟" -ForegroundColor White
        }
        if ($displayDC) {
            Write-Host "显示器超时（电池电源）：$(Convert-SecondsToMinutes $((($displayDC -split ':')[1]).Trim())) 分钟" -ForegroundColor White
        }
        if ($sleepAC) {
            Write-Host "睡眠超时（交流电源）：$(Convert-SecondsToMinutes $((($sleepAC -split ':')[1]).Trim())) 分钟" -ForegroundColor White
        }
        if ($sleepDC) {
            Write-Host "睡眠超时（电池电源）：$(Convert-SecondsToMinutes $((($sleepDC -split ':')[1]).Trim())) 分钟" -ForegroundColor White
        }
        if ($consoleLockAC) {
            Write-Host "控制台锁定显示超时（交流电源）：$(Convert-SecondsToMinutes $((($consoleLockAC -split ':')[1]).Trim())) 分钟" -ForegroundColor White
        }
        if ($consoleLockDC) {
            Write-Host "控制台锁定显示超时（电池电源）：$(Convert-SecondsToMinutes $((($consoleLockDC -split ':')[1]).Trim())) 分钟" -ForegroundColor White
        }
    }
    catch {
        Write-Host "获取电源设置时出错：" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Convert seconds to minutes
function Convert-SecondsToMinutes {
    param([int]$seconds)
    if ($seconds -eq 0) {
        return "永不"
    }
    return [math]::Round($seconds / 60, 1)
}

# Set power timeouts
function Set-PowerTimeouts {
    Write-Host "正在设置电源超时..." -ForegroundColor Green

    try {
        # Set display timeout to 30 minutes (1800 seconds) for both AC and DC power
        if ($WhatIf) {
            Write-Host "预览模式: powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE $DisplayTimeout" -ForegroundColor Gray
            Write-Host "预览模式: powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE $DisplayTimeout" -ForegroundColor Gray
        } else {
            powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE $DisplayTimeout 2>$null | Out-Null
            powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE $DisplayTimeout 2>$null | Out-Null
        }

        # Set sleep timeout to 1 hour (3600 seconds) for both AC and DC power
        if ($WhatIf) {
            Write-Host "预览模式: powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE $SleepTimeout" -ForegroundColor Gray
            Write-Host "预览模式: powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE $SleepTimeout" -ForegroundColor Gray
        } else {
            powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE $SleepTimeout 2>$null | Out-Null
            powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE $SleepTimeout 2>$null | Out-Null
        }

        # Set console lock display timeout to 5 minutes (300 seconds) for both AC and DC power
        if ($WhatIf) {
            Write-Host "预览模式: powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $ConsoleLockTimeout" -ForegroundColor Gray
            Write-Host "预览模式: powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $ConsoleLockTimeout" -ForegroundColor Gray
        } else {
            powercfg.exe /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $ConsoleLockTimeout 2>$null | Out-Null
            powercfg.exe /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK $ConsoleLockTimeout 2>$null | Out-Null
        }

        # Apply all changes
        if (-not $WhatIf) {
            powercfg.exe /setactive SCHEME_CURRENT 2>$null | Out-Null
        }

        Write-Host "电源设置更新成功！" -ForegroundColor Green
        Write-Host "- 显示器超时：30分钟" -ForegroundColor Cyan
        Write-Host "- 睡眠超时：1小时" -ForegroundColor Cyan
        Write-Host "- 控制台锁定显示超时：5分钟" -ForegroundColor Cyan

    }
    catch {
        Write-Error "设置电源超时失败：$($_.Exception.Message)"
        Show-ErrorAndExit "请检查是否以管理员身份运行。"
    }
}

# Restore default power settings
function Restore-DefaultSettings {
    Write-Host "正在恢复默认电源设置..." -ForegroundColor Yellow

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

        Write-Host "默认电源设置已恢复！" -ForegroundColor Green

    }
    catch {
        Write-Error "恢复默认设置失败：$($_.Exception.Message)"
        Show-ErrorAndExit "请检查是否以管理员身份运行。"
    }
}

# Main execution
Write-Host "Windows 10 电源设置配置脚本" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta

# Check execution policy
try {
    $executionPolicy = Get-ExecutionPolicy
    Write-Host "当前执行策略：$executionPolicy" -ForegroundColor Cyan

    if ($executionPolicy -eq "Restricted") {
        Show-ErrorAndExit "执行策略限制运行脚本。请运行以下命令后重试：`nSet-ExecutionPolicy RemoteSigned -Scope CurrentUser"
    }
}
catch {
    Write-Host "无法检查执行策略，继续运行..." -ForegroundColor Yellow
}

# Check if running as administrator
try {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Warning "警告：此脚本需要管理员权限才能修改电源设置。"
        Write-Host "如果没有管理员权限，脚本将以只读模式运行。" -ForegroundColor Yellow
        Write-Host ""

        # If not administrator, only allow view mode
        if (-not $ShowCurrentSettings) {
            Write-Host "切换到查看模式..." -ForegroundColor Yellow
            $ShowCurrentSettings = $true
        }
    }
}
catch {
    Write-Host "无法检查管理员权限，继续运行..." -ForegroundColor Yellow
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
            Show-ErrorAndExit "恢复默认设置需要管理员权限。请以管理员身份运行 PowerShell。"
        }
    }
    else {
        if ($WhatIf) {
            Write-Host "预览模式：显示将要进行的更改..." -ForegroundColor Gray
        }

        if ($isAdmin) {
            Set-PowerTimeouts
        }
        else {
            Write-Host "没有管理员权限，无法修改电源设置。" -ForegroundColor Red
            Write-Host "当前电源设置：" -ForegroundColor Yellow
            Show-CurrentSettings
        }
    }

    Write-Host "脚本执行完成。" -ForegroundColor Magenta

}
catch {
    Show-ErrorAndExit "脚本执行过程中发生错误：$($_.Exception.Message)"
}

# Pause and wait for user to press any key to exit
Pause-AndExit
