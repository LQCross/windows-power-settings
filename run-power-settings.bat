@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo Windows 10 电源设置配置工具
echo ==========================================
echo.

echo 检查管理员权限...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo 管理员权限：是
) else (
    echo 管理员权限：否
    echo.
    echo 警告：某些功能需要管理员权限。
    echo 如果需要修改电源设置，请右键以管理员身份运行此批处理文件。
    echo.
    pause
)

echo.
echo 正在启动 PowerShell 脚本...
echo.

REM 切换到脚本所在目录
cd /d "%~dp0"

REM 检查脚本文件是否存在
if not exist "windows-power-settings-cn.ps1" (
    echo 错误：找不到 windows-power-settings-cn.ps1 文件！
    echo 请确保批处理文件和 PowerShell 脚本在同一目录中。
    echo.
    pause
    exit /b 1
)

REM 运行 PowerShell 脚本（使用最终版本，确保UTF-8 with BOM编码）
powershell.exe -ExecutionPolicy Bypass -File "windows-power-settings-cn.ps1"

echo.
echo 批处理文件执行完成。