function Get-BluetoothBattery {
    param(
        [string]$Name = '*'
    )

    $key = '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2'

    Get-PnpDevice -PresentOnly |
        Where-Object { $_.InstanceId -match '^BTH' -and $_.FriendlyName -like "*$($Name.Trim('*'))*" } |
        ForEach-Object {
            $device = $_
            Get-PnpDeviceProperty -InstanceId $device.InstanceId -KeyName $key -ErrorAction Ignore |
                Where-Object Type -ne Empty |
                ForEach-Object {
                    [pscustomobject]@{
                        Name           = $device.FriendlyName -replace ' (Hands-Free( AG| HF)?|Handsfree( AG)?|Avrcp Transport|Stereo)$', ''
                        BatteryPercent = [int]$_.Data
                        InstanceId     = $device.InstanceId
                    }
                }
        } |
        Sort-Object Name, BatteryPercent -Unique
}
