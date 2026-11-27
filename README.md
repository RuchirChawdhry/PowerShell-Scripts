# PowerShell Scripts

Small, direct utilities for **Windows 11 + PowerShell 7+**. Every `.ps1` script is self-contained and can be dot-sourced independently. QR generation uses only built-in PowerShell and .NET; screenshots use Microsoft's WinApp CLI.

## Scripts

| Script | Purpose | Example |
| --- | --- | --- |
| `Get-BluetoothBattery` | Battery percentages exposed by connected Bluetooth device nodes | `Get-BluetoothBattery -Name Sony` |
| `Get-BatteryInfo` | Laptop battery capacities, health, charge and power state | `Get-BatteryInfo` |
| `Get-QR` | Text to a PNG, a terminal QR or a QR window | `Get-QR 'Hello' -Terminal -Window` |
| `Get-HWND` | Find main-window handles by fuzzy app name, title or PID | `Get-HWND -Name npad` |
| `Get-ProcesID` | Find process IDs by fuzzy app/process name or window title | `Get-ProcesID -Name chrome` |
| `Get-HWInfo` | Hardware inventory grouped by system, CPU, GPU, RAM, disks, motherboard, BIOS, network and monitors | `(Get-HWInfo -Category CPU, RAM).CPU` |
| `Get-Screenshot` | Screenshot the visible window from an HWND, PID or fuzzy name | `Get-Screenshot -Name notepad -Path .\notepad.png` |
| `Get-ScreenshotJumplist` | Open an app's taskbar jump list and screenshot its visible contents | `Get-ScreenshotJumplist -Name notepad -Path .\jump.png` |

`Get-ProcesID` retains the requested spelling; **`Get-ProcessID`** is also provided as an alias.

Fuzzy search matches characters in order, so `npad` matches `notepad`. Exact and prefix process-name matches come first. Multiple matching PIDs or HWNDs can be returned. `Get-Screenshot` uses the first matching visible main window.

## Use

```powershell
. .\Get-BluetoothBattery.ps1
. .\Get-BatteryInfo.ps1
. .\Get-QR.ps1
. .\Get-HWND.ps1
. .\Get-ProcesID.ps1
. .\Get-HWInfo.ps1
. .\Get-Screenshot.ps1
. .\Get-ScreenshotJumplist.ps1

Get-ProcesID -Name 'edge'
Get-HWND -Name 'notepad'
Get-HWInfo -Category CPU, GPU, RAM
Get-Screenshot -ProcessId 1234 -Path .\app.png
Get-Screenshot -Hwnd (Get-HWND -Name 'notepad' | Select-Object -First 1)
```

Generate QR codes locally with no module or package installation:

```powershell
Get-QR -Text 'https://github.com/RuchirChawdhry/PowerShell-Scripts' -Path .\repo.png
Get-QR 'Hello from PowerShell' -Terminal
Get-QR 'Scan me' -Window
Get-QR 'Both displays at once' -Terminal -Window -Width 400
```

`Get-QR` always saves an opaque PNG and returns its file object. `-Terminal` prints a scannable QR with ANSI half-block glyphs; `-Window` opens a resizable-by-closing modal Windows Forms preview (close it to return to the console). Both switches can be combined. The embedded PowerShell encoder is based on [Gregoire L. Duval's MIT-licensed implementation](https://github.com/GregoireLD/Powershell-QrCodeGenerator) with its license retained in the script.

Install Microsoft's WinApp CLI once for screenshots:

```powershell
winget install Microsoft.winappcli --source winget
```

The Bluetooth percentage is populated only if Windows received a battery report for that accessory. `Get-BatteryInfo` returns no rows on machines without a Windows-reported battery.

Screenshots use `winapp ui screenshot --capture-screen`, capturing the visible window rectangle as an opaque PNG with no transparent padding. It includes visible overlays or covering windows. Jump-list capture uses WinApp to locate the taskbar button, right-click it, and capture the actual Shell popup by HWND—no fixed crop or pixel-difference scan. Both commands require an **unlocked, interactive Windows desktop**.

`Get-HWInfo` returns an object with named hardware sections. Select individual sections with `-Category` (for example, `(Get-HWInfo -Category Disk).Disk`); all sections are included by default. Values come from Windows CIM/WMI, with no third-party hardware probe or sensor service.

## Tests

GitHub Actions runs parsing, fuzzy lookup, Bluetooth-property parsing, battery calculations, hardware-inventory checks, dependency-free QR generation and its terminal/window modes, and real window and jump-list captures on `windows-latest` with WinApp. A separate test decoder checks QR content, and PNG edge-alpha tests check for transparent borders. Hardware-specific battery readings use deterministic samples because hosted runners have no Bluetooth accessories or laptop battery.

For an additional local interactive check:

```powershell
.\tests\Test-Interactive.ps1
```

This opens Notepad and saves `tests/notepad.png` and `tests/notepad-jumplist.png` for visual inspection. It does not close Notepad automatically.
