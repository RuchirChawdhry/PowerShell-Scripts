$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../Get-ScreenshotJumplist.ps1"

Start-Process notepad.exe
Start-Sleep -Seconds 3

$path = Join-Path $PSScriptRoot 'winapp-notepad-jumplist.png'
$screenshot = Get-ScreenshotJumplist -Name notepad -Path $path

$window = [PowerShellScriptsNative]::GetForegroundWindow()
$menu = winapp ui inspect -w $window --depth 5 --json | ConvertFrom-Json
if ($menu.windows[0].title -notlike 'Jump List for *') {
    throw "Expected a taskbar Jump List; got '$($menu.windows[0].title)'"
}

Add-Type -AssemblyName System.Drawing
$image = [System.Drawing.Bitmap]::new($screenshot.FullName)
if ($image.Width -lt 150 -or $image.Height -lt 80) { throw 'Jump List PNG is too small' }

$alpha = @(
    $image.GetPixel(0, 0).A
    $image.GetPixel($image.Width - 1, 0).A
    $image.GetPixel(0, $image.Height - 1).A
    $image.GetPixel($image.Width - 1, $image.Height - 1).A
)
if (($alpha | Measure-Object -Minimum).Minimum -ne 255) { throw 'Jump List PNG has transparent edges' }
$image.Dispose()

Write-Host "Captured $($screenshot.Name) using WinApp"
