# Get-ScreenshotJumplist

Uses WinApp to inspect the taskbar, right-click the app button, then screenshot the actual Shell Jump List HWND.

## Usage

```powershell
. .\Get-ScreenshotJumplist.ps1
Get-ScreenshotJumplist -Name 'notepad' -Path .\jumplist.png
```

## Parameters

- `-Name`: Fuzzy name of a running app with a taskbar button.
- `-ProcessId`: Exact PID, alternative to -Name.
- `-Path`: PNG output path, defaults to jumplist.png.

## Returns

PNG FileInfo object.

## Notes

Requires Microsoft WinApp CLI and an unlocked interactive desktop. The app must be running with a taskbar button.

[Source script](https://github.com/RuchirChawdhry/PowerShell-Scripts/blob/main/Get-ScreenshotJumplist.ps1) · [Documentation page](https://ruchirchawdhry.github.io/PowerShell-Scripts/scripts/get-screenshotjumplist.html)
