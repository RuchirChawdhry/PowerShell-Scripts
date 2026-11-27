function Get-BatteryInfo {
    $batteries = Get-CimInstance -Namespace root/wmi -ClassName BatteryStaticData
    $capacities = Get-CimInstance -Namespace root/wmi -ClassName BatteryFullChargedCapacity
    $statuses = Get-CimInstance -Namespace root/wmi -ClassName BatteryStatus

    $batteries | ForEach-Object {
        $battery = $_
        $capacity = $capacities | Where-Object InstanceName -EQ $battery.InstanceName | Select-Object -First 1
        $status = $statuses | Where-Object InstanceName -EQ $battery.InstanceName | Select-Object -First 1

        [pscustomobject]@{
            Name                   = $battery.DeviceName
            Manufacturer           = $battery.ManufactureName
            SerialNumber           = $battery.SerialNumber
            DesignCapacityMWh      = [int]$battery.DesignedCapacity
            FullChargeCapacityMWh  = [int]$capacity.FullChargedCapacity
            RemainingCapacityMWh   = [int]$status.RemainingCapacity
            HealthPercent          = [math]::Round(100 * $capacity.FullChargedCapacity / $battery.DesignedCapacity, 1)
            ChargePercent          = [math]::Round(100 * $status.RemainingCapacity / $capacity.FullChargedCapacity, 1)
            VoltageMV              = [int]$status.Voltage
            Charging               = [bool]$status.Charging
            Discharging            = [bool]$status.Discharging
            ACConnected            = [bool]$status.PowerOnline
        }
    }
}
