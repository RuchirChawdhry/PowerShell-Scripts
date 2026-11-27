# Get-HWInfo

Queries Windows for system, CPU, GPU, memory modules, disks, motherboard, BIOS, physical network adapters and display information.

## Usage

```powershell
. .\Get-HWInfo.ps1
(Get-HWInfo -Category CPU, RAM).CPU
Get-HWInfo
```

## Parameters

- `-Category`: Any subset of System, CPU, GPU, RAM, Disk, Board, BIOS, Network, Monitor; all by default.

## Returns

An object whose properties are the requested named categories.

## Notes

Hardware fields are as reported by Windows; sensor-specific information needs a separate sensor provider.

[Source script](https://github.com/RuchirChawdhry/PowerShell-Scripts/blob/main/Get-HWInfo.ps1) · [Documentation page](https://ruchirchawdhry.github.io/PowerShell-Scripts/scripts/get-hwinfo.html)
