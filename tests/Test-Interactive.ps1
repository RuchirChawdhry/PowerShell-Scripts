$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
. "$root/Get-HWND.ps1"
. "$root/Get-Screenshot.ps1"
. "$root/Get-ScreenshotJumplist.ps1"

Start-Process notepad.exe
Start-Sleep -Seconds 2

Get-HWND -Name notepad
Get-Screenshot -Name notepad -Path (Join-Path $PSScriptRoot 'notepad.png')
Get-ScreenshotJumplist -Name notepad -Path (Join-Path $PSScriptRoot 'notepad-jumplist.png')

Write-Host 'Open both PNGs and verify their contents, then close Notepad.'
