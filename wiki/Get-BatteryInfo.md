# Get-BatteryInfo

Combines Windows battery WMI classes to calculate health and charge percentages for installed batteries.

## Usage

```powershell
. .\Get-BatteryInfo.ps1
Get-BatteryInfo
```

## Returns

Name, Manufacturer, SerialNumber, DesignCapacityMWh, FullChargeCapacityMWh, RemainingCapacityMWh, HealthPercent, ChargePercent, VoltageMV, Charging, Discharging, ACConnected.

## Notes

On a desktop without a reported battery the command returns no results.

[Source script](https://github.com/RuchirChawdhry/PowerShell-Scripts/blob/main/Get-BatteryInfo.ps1) · [Documentation page](https://ruchirchawdhry.github.io/PowerShell-Scripts/scripts/get-batteryinfo.html)
