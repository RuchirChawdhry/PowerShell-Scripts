# Get-HWND

Matches characters in sequence across running process names and window titles, prioritizing exact and prefix process names.

## Usage

```powershell
. .\Get-HWND.ps1
Get-HWND -Name 'npad'
Get-HWND -ProcessId 1234
```

## Parameters

- `-Name`: Fuzzy app/process name or title.
- `-ProcessId`: Exact process ID, alternative to -Name.

## Returns

One or more IntPtr main-window handles; processes without a main window are omitted.

## Notes

'npad' matches Notepad because the characters occur in order.

[Source script](https://github.com/RuchirChawdhry/PowerShell-Scripts/blob/main/Get-HWND.ps1) · [Documentation page](https://ruchirchawdhry.github.io/PowerShell-Scripts/scripts/get-hwnd.html)
