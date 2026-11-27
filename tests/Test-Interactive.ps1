$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
. "$root/Get-HWND.ps1"
. "$root/Get-Screenshot.ps1"
. "$root/Get-ScreenshotJumplist.ps1"

$notepad = Start-Process notepad.exe -PassThru
Start-Sleep -Seconds 2

Get-HWND -ProcessId $notepad.Id
Get-Screenshot -ProcessId $notepad.Id -Path (Join-Path $PSScriptRoot 'notepad.png')
Get-ScreenshotJumplist -ProcessId $notepad.Id -Path (Join-Path $PSScriptRoot 'notepad-jumplist.png')

Write-Host 'Open both PNGs and verify their contents, then close Notepad.'
