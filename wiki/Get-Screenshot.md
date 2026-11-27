# Get-Screenshot

Invokes Microsoft's WinApp CLI screen capture on the chosen foreground window, avoiding transparent edges.

## Usage

```powershell
. .\Get-Screenshot.ps1
Get-Screenshot -Name 'notepad' -Path .\notepad.png
Get-Screenshot -Hwnd (Get-HWND -Name 'npad' | Select-Object -First 1)
```

## Parameters

- `-Name`: Fuzzy app/process name or title.
- `-ProcessId`: Exact PID.
- `-Hwnd`: Exact HWND IntPtr.
- `-Path`: PNG output path, defaults to screenshot.png.

## Returns

PNG FileInfo object.

## Notes

Requires Microsoft WinApp CLI and a running interactive Windows desktop. Captures visible content, including overlays.

[Source script](https://github.com/RuchirChawdhry/PowerShell-Scripts/blob/main/Get-Screenshot.ps1) · [Documentation page](https://ruchirchawdhry.github.io/PowerShell-Scripts/scripts/get-screenshot.html)
