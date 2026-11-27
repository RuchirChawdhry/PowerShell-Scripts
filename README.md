# PowerShell Scripts

Small, direct utilities for **Windows 11 + PowerShell 7+**. Each public script can be dot-sourced independently. No modules, services or installers are needed for the other six scripts; QR generation uses the offline `QRCodeGenerator` module.

## Scripts

| Script | Purpose | Example |
| --- | --- | --- |
| `Get-BluetoothBattery` | Battery percentages exposed by connected Bluetooth device nodes | `Get-BluetoothBattery -Name Sony` |
| `Get-BatteryInfo` | Laptop battery capacities, health, charge and power state | `Get-BatteryInfo` |
| `Get-QR` | Text to an offline PNG QR code | `Get-QR 'Hello' -Path .\hello.png` |
| `Get-HWND` | Find main-window handles by fuzzy app name, title or PID | `Get-HWND -Name npad` |
| `Get-ProcesID` | Find process IDs by fuzzy app/process name or window title | `Get-ProcesID -Name chrome` |
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
. .\Get-Screenshot.ps1
. .\Get-ScreenshotJumplist.ps1

Get-ProcesID -Name 'edge'
Get-HWND -Name 'notepad'
Get-Screenshot -ProcessId 1234 -Path .\app.png
Get-Screenshot -Hwnd (Get-HWND -Name 'notepad' | Select-Object -First 1)
```

Install the one QR dependency once (the module generates codes locally without uploading text):

```powershell
Install-Module QRCodeGenerator -RequiredVersion 2.4.0 -Scope CurrentUser -Force
Get-QR -Text 'https://github.com/RuchirChawdhry/PowerShell-Scripts' -Path .\repo.png
```

The Bluetooth percentage is populated only if Windows received a battery report for that accessory. `Get-BatteryInfo` returns no rows on machines without a Windows-reported battery.

Screenshots use the visible desktop pixels, including overlays, not hidden-window rendering. If an app is covered, its capture can include the covering window. Jump-list capture locates the app's taskbar button through Windows UI Automation, right-clicks it, then crops the changed screen region. It requires an **unlocked, interactive Windows 11 session** and a taskbar button whose accessible name identifies the app or window title.

## Tests

GitHub Actions runs the parsing, fuzzy lookup, PnP battery-property parsing, battery calculations and PNG-generation tests on `windows-11-arm` with PowerShell 7. Device queries are tested with deterministic samples because hosted runners do not contain your Bluetooth accessories or laptop battery. Screenshot commands are loaded and their parameter sets checked in CI. Real desktop capture and jump-list opening require a local interactive session:

```powershell
.\tests\Test-Interactive.ps1
```

This opens Notepad and saves `tests/notepad.png` and `tests/notepad-jumplist.png` for visual inspection. It does not close Notepad automatically.
