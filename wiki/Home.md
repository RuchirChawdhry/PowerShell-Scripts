# PowerShell Scripts — Wiki

Independent utilities for **Windows 11** and **PowerShell 7+**. Each public `Get-*.ps1` file is self-contained: dot-source only the command you want.

## Getting started

```powershell
. .\Get-QR.ps1
Get-QR 'Hello PowerShell' -Terminal -Window

. .\Get-HWInfo.ps1
(Get-HWInfo -Category CPU, RAM).CPU
```

## Command reference

- [[Get-BluetoothBattery]] — Read battery percentages reported by connected Bluetooth accessories.
- [[Get-BatteryInfo]] — Inspect designed capacity, full-charge capacity, remaining charge, and health.
- [[Get-QR]] — Turn UTF-8 text into a PNG, a terminal QR, and a window preview.
- [[Get-HWND]] — Find HWNDs by fuzzy process name, window title, or exact PID.
- [[Get-ProcesID]] — Locate process IDs with the same fuzzy search as HWND lookup.
- [[Get-HWInfo]] — Retrieve Windows hardware sections through CIM/WMI.
- [[Get-Screenshot]] — Capture an exact visible HWND rectangle as an opaque PNG.
- [[Get-ScreenshotJumplist]] — Open an app's real taskbar Jump List and capture the popup.

## Dependencies

- **QR:** no external module; uses embedded PowerShell QR encoding and .NET drawing APIs.
- **Screenshots:** install Microsoft's [WinApp CLI](https://github.com/microsoft/winappcli) using `winget install Microsoft.winappcli --source winget`. An unlocked interactive desktop is required.
- **Battery/hardware:** Windows' native PnP and CIM/WMI APIs.

## More resources

- [GitHub repository](https://github.com/RuchirChawdhry/PowerShell-Scripts)
- [Documentation website](https://ruchirchawdhry.github.io/PowerShell-Scripts/)
- [XML sitemap](https://ruchirchawdhry.github.io/PowerShell-Scripts/sitemap.xml)
- [CI tests](https://github.com/RuchirChawdhry/PowerShell-Scripts/actions)
