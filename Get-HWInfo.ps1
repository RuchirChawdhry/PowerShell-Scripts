function Get-HWInfo {
    param(
        [ValidateSet('System', 'CPU', 'GPU', 'RAM', 'Disk', 'Board', 'BIOS', 'Network', 'Monitor')]
        [string[]]$Category = @('System', 'CPU', 'GPU', 'RAM', 'Disk', 'Board', 'BIOS', 'Network', 'Monitor')
    )

    $hardware = [ordered]@{}

    foreach ($item in $Category) {
        $hardware[$item] = switch ($item) {
            System {
                Get-CimInstance Win32_ComputerSystem |
                    Select-Object Manufacturer, Model, SystemType,
                        @{ Name = 'TotalRAMGB'; Expression = { [math]::Round($_.TotalPhysicalMemory / 1GB, 1) } }
            }
            CPU {
                Get-CimInstance Win32_Processor |
                    Select-Object Name, Manufacturer, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
            }
            GPU {
                Get-CimInstance Win32_VideoController |
                    Select-Object Name, VideoProcessor, DriverVersion, VideoModeDescription
            }
            RAM {
                Get-CimInstance Win32_PhysicalMemory |
                    Select-Object BankLabel, Manufacturer, PartNumber, SerialNumber, Speed, ConfiguredClockSpeed,
                        @{ Name = 'CapacityGB'; Expression = { [math]::Round($_.Capacity / 1GB, 1) } }
            }
            Disk {
                Get-CimInstance Win32_DiskDrive |
                    Select-Object Model, SerialNumber, InterfaceType, MediaType,
                        @{ Name = 'SizeGB'; Expression = { [math]::Round($_.Size / 1GB, 1) } }
            }
            Board {
                Get-CimInstance Win32_BaseBoard |
                    Select-Object Manufacturer, Product, Version, SerialNumber
            }
            BIOS {
                Get-CimInstance Win32_BIOS |
                    Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate, SerialNumber
            }
            Network {
                Get-CimInstance Win32_NetworkAdapter -Filter 'PhysicalAdapter = TRUE' |
                    Select-Object Name, MACAddress, Speed, NetConnectionID
            }
            Monitor {
                Get-CimInstance -Namespace root/wmi -ClassName WmiMonitorID |
                    Select-Object InstanceName,
                        @{ Name = 'Name'; Expression = { -join ($_.UserFriendlyName | Where-Object { $_ -gt 0 } | ForEach-Object { [char]$_ }) } },
                        @{ Name = 'Manufacturer'; Expression = { -join ($_.ManufacturerName | Where-Object { $_ -gt 0 } | ForEach-Object { [char]$_ }) } }
            }
        }
    }

    [pscustomobject]$hardware
}
