# Get-ProcesID

Searches process names and visible window titles for a fuzzy character sequence.

## Usage

```powershell
. .\Get-ProcesID.ps1
Get-ProcesID -Name 'chrome'
Get-ProcessID -Name 'npad'
```

## Parameters

- `-Name`: Required fuzzy process name or window title.

## Returns

One or more integer process IDs.

## Notes

The requested spelling Get-ProcesID is preserved; Get-ProcessID is an alias.

[Source script](https://github.com/RuchirChawdhry/PowerShell-Scripts/blob/main/Get-ProcesID.ps1) · [Documentation page](https://ruchirchawdhry.github.io/PowerShell-Scripts/scripts/get-procesid.html)
