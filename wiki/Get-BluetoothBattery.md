# Get-BluetoothBattery

Lists Bluetooth PnP devices that expose Windows' battery percentage property, with cleaned friendly names and instance IDs.

## Usage

```powershell
. .\Get-BluetoothBattery.ps1
Get-BluetoothBattery -Name 'Sony'
```

## Parameters

- `-Name`: Optional substring to filter accessory names; defaults to all Bluetooth devices.

## Returns

Name, BatteryPercent, InstanceId.

## Notes

The accessory must report a battery value to Windows; absent reports produce no row.

[Source script](https://github.com/RuchirChawdhry/PowerShell-Scripts/blob/main/Get-BluetoothBattery.ps1) · [Documentation page](https://ruchirchawdhry.github.io/PowerShell-Scripts/scripts/get-bluetoothbattery.html)
