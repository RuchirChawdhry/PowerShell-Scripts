$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent

function Assert {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

Get-ChildItem $root -Filter *.ps1 -Recurse | ForEach-Object {
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $_.FullName, [ref]$tokens, [ref]$errors
    )
    Assert ($errors.Count -eq 0) "Parse error in $($_.FullName): $errors"
}

@(
    'Get-BluetoothBattery.ps1', 'Get-BatteryInfo.ps1', 'Get-QR.ps1',
    'Get-HWND.ps1', 'Get-ProcesID.ps1', 'Get-HWInfo.ps1', 'Get-Screenshot.ps1',
    'Get-ScreenshotJumplist.ps1'
) | ForEach-Object { . (Join-Path $root $_) }

Assert ((Get-Command Get-ProcessID).Definition -eq 'Get-ProcesID') 'ProcessID alias missing'
Assert ((Get-ProcesID -Name 'pwh') -contains $PID) 'Subsequence matching failed'

function Get-Process {
    param([int]$Id)
    $processes = @(
        [pscustomobject]@{ Id = 42; ProcessName = 'FancyNotepad'; MainWindowTitle = 'Notes'; MainWindowHandle = [IntPtr]12345 },
        [pscustomobject]@{ Id = 43; ProcessName = 'Other'; MainWindowTitle = 'Untitled - Notepad'; MainWindowHandle = [IntPtr]67890 },
        [pscustomobject]@{ Id = 44; ProcessName = 'Background'; MainWindowTitle = ''; MainWindowHandle = [IntPtr]::Zero }
    )
    if ($PSBoundParameters.ContainsKey('Id')) { return $processes | Where-Object Id -EQ $Id }
    $processes
}

Assert ((Get-ProcesID -Name 'fnp') -contains 42) 'Fuzzy process lookup failed'
Assert ((Get-HWND -Name 'notepad').Count -eq 2) 'Window-name lookup failed'
Assert ((Get-HWND -ProcessId 42) -eq [IntPtr]12345) 'Window PID lookup failed'
Remove-Item Function:Get-Process

function Get-PnpDevice {
    param([switch]$PresentOnly)
    @(
        [pscustomobject]@{ InstanceId = 'BTHENUM\A'; FriendlyName = 'Demo Headset Hands-Free AG' },
        [pscustomobject]@{ InstanceId = 'BTHLE\B'; FriendlyName = 'Other Headset' },
        [pscustomobject]@{ InstanceId = 'USB\C'; FriendlyName = 'USB Device' }
    )
}

function Get-PnpDeviceProperty {
    [CmdletBinding()]
    param([string]$InstanceId, [string]$KeyName)
    switch ($InstanceId) {
        'BTHENUM\A' { [pscustomobject]@{ Type = 'Byte'; Data = 78 } }
        'BTHLE\B'  { [pscustomobject]@{ Type = 'Empty'; Data = $null } }
    }
}

$bluetooth = @(Get-BluetoothBattery)
Assert ($bluetooth.Count -eq 1) 'Bluetooth devices without a level must be omitted'
Assert ($bluetooth[0].Name -eq 'Demo Headset') 'Bluetooth display name not normalized'
Assert ($bluetooth[0].BatteryPercent -eq 78) 'Bluetooth battery percentage incorrect'
Assert ((@(Get-BluetoothBattery -Name 'Other')).Count -eq 0) 'Bluetooth name filter failed'
Remove-Item Function:Get-PnpDevice
Remove-Item Function:Get-PnpDeviceProperty

function Get-CimInstance {
    param(
        [Parameter(Position = 0)][string]$ClassName,
        [string]$Namespace,
        [string]$Filter
    )
    switch ($ClassName) {
        BatteryStaticData {
            [pscustomobject]@{ InstanceName = 'BAT0'; DeviceName = 'Demo Battery'; ManufactureName = 'Demo'; SerialNumber = '123'; DesignedCapacity = 60000 }
        }
        BatteryFullChargedCapacity {
            [pscustomobject]@{ InstanceName = 'BAT0'; FullChargedCapacity = 48000 }
        }
        BatteryStatus {
            [pscustomobject]@{ InstanceName = 'BAT0'; RemainingCapacity = 24000; Voltage = 11500; Charging = $false; Discharging = $true; PowerOnline = $false }
        }
        Win32_Processor {
            [pscustomobject]@{ Name = 'Demo CPU'; NumberOfCores = 8; NumberOfLogicalProcessors = 16; MaxClockSpeed = 4400 }
        }
        Win32_PhysicalMemory {
            [pscustomobject]@{ BankLabel = 'DIMM0'; Manufacturer = 'Demo'; PartNumber = 'DDR5'; Capacity = 17179869184; Speed = 5600 }
        }
        Win32_DiskDrive {
            [pscustomobject]@{ Model = 'Demo SSD'; Size = 512110190592; MediaType = 'Fixed hard disk media' }
        }
        WmiMonitorID {
            [pscustomobject]@{ InstanceName = 'DISPLAY\\DEMO'; UserFriendlyName = @(68, 101, 109, 111, 32, 80, 97, 110, 101, 108, 0); ManufacturerName = @(68, 69, 77, 0) }
        }
    }
}

$battery = Get-BatteryInfo
Assert ($battery.HealthPercent -eq 80) 'Battery health calculation failed'
Assert ($battery.ChargePercent -eq 50) 'Battery charge calculation failed'
Assert ($battery.Discharging -eq $true) 'Battery discharge status failed'
$hardware = Get-HWInfo -Category CPU, RAM, Disk, Monitor
Assert ($hardware.CPU.Name -eq 'Demo CPU') 'CPU information failed'
Assert ($hardware.RAM.CapacityGB -eq 16) 'RAM capacity conversion failed'
Assert ($hardware.Disk.SizeGB -gt 470) 'Disk capacity conversion failed'
Assert ($hardware.Monitor.Name -eq 'Demo Panel') 'Monitor name decoding failed'
Remove-Item Function:Get-CimInstance
Assert ([bool]((Get-HWInfo -Category CPU).CPU.Name)) 'Real processor inventory failed'

$directory = Join-Path ([System.IO.Path]::GetTempPath()) ("powershell-scripts-" + [guid]::NewGuid())
[void](New-Item -ItemType Directory -Path $directory)
$path = Join-Path $PSScriptRoot 'qr-ci.png'
$qr = Get-QR -Text 'AarPaar QR test' -Path $path -Width 256
$bytes = [System.IO.File]::ReadAllBytes($qr.FullName)
Assert ((($bytes[0..7] -join ',') -eq '137,80,78,71,13,10,26,10')) 'QR output is not PNG'
Add-Type -AssemblyName System.Drawing
$image = [System.Drawing.Bitmap]::new($qr.FullName)
Assert ($image.Width -eq 256 -and $image.Height -eq 256) 'QR image has wrong dimensions'
Assert ($image.GetPixel(0, 0).A -eq 255 -and $image.GetPixel(0, 0).R -eq 255) 'QR background must be opaque white'
$image.Dispose()

$output = @(Get-QR -Text 'Terminal QR test' -Path (Join-Path $directory 'terminal.png') -Width 256 -Terminal 6>&1)
Assert (($output | Where-Object { $_ -is [System.Management.Automation.InformationRecord] }).MessageData -match [char]0x2584) 'Terminal QR output missing'
Assert ($output[-1].Name -eq 'terminal.png') 'Terminal QR did not return PNG'

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class QRWindowTestNative {
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr FindWindow(string className, string title);
    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr hwnd, uint msg, IntPtr wParam, IntPtr lParam);
}
'@
$qrStdout = Join-Path $directory 'qr-host.log'
$qrStderr = Join-Path $directory 'qr-host-error.log'
$qrHost = Start-Process -FilePath (Get-Command pwsh).Source -ArgumentList '-NoProfile', '-STA', '-File', "`"$PSScriptRoot/QR-WindowHost.ps1`"" -PassThru -RedirectStandardOutput $qrStdout -RedirectStandardError $qrStderr
for ($attempt = 0; $attempt -lt 45; $attempt++) {
    $qrWindow = [QRWindowTestNative]::FindWindow($null, 'QR: QR window CI test')
    if ($qrWindow -ne [IntPtr]::Zero -or $qrHost.HasExited) { break }
    Start-Sleep -Seconds 1
}
Assert ($qrWindow -ne [IntPtr]::Zero) "QR preview window did not open. Host exit: $($qrHost.HasExited). Errors: $(Get-Content $qrStderr -Raw)"
[void][QRWindowTestNative]::PostMessage($qrWindow, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
Assert ($qrHost.WaitForExit(20000)) 'QR preview window did not close'
Assert ($qrHost.ExitCode -eq 0) 'QR preview process failed'
Assert (Test-Path (Join-Path $PSScriptRoot 'qr-window.png')) 'QR preview PNG is missing'

Add-Type -AssemblyName System.Windows.Forms
$form = [System.Windows.Forms.Form]::new()
$form.Text = 'Screenshot CI target'
$form.StartPosition = 'Manual'
$form.Location = [System.Drawing.Point]::new(100, 100)
$form.Size = [System.Drawing.Size]::new(320, 240)
$form.BackColor = [System.Drawing.Color]::LimeGreen
$form.Show()
[System.Windows.Forms.Application]::DoEvents()

$screenshot = Get-Screenshot -Hwnd $form.Handle -Path (Join-Path $directory 'window.png')
$capture = [System.Drawing.Bitmap]::new($screenshot.FullName)
Assert ($capture.Width -ge 200 -and $capture.Height -ge 150) 'Window screenshot has incorrect dimensions'
$corners = @(
    $capture.GetPixel(0, 0).A
    $capture.GetPixel($capture.Width - 1, 0).A
    $capture.GetPixel(0, $capture.Height - 1).A
    $capture.GetPixel($capture.Width - 1, $capture.Height - 1).A
)
Assert (($corners | Measure-Object -Minimum).Minimum -eq 255) 'Screenshot has transparent borders'
$capture.Dispose()
$form.Close()
$form.Dispose()
Remove-Item $directory -Recurse -Force

Assert ((Get-Command Get-Screenshot).ParameterSets.Name -contains 'Hwnd') 'Screenshot HWND parameter set missing'
Assert ((Get-Command Get-Screenshot).ParameterSets.Name -contains 'ProcessId') 'Screenshot PID parameter set missing'
Assert ((Get-Command Get-ScreenshotJumplist).ParameterSets.Name -contains 'Name') 'Jump-list name parameter set missing'
Assert ((Get-Command Get-HWInfo).Name -eq 'Get-HWInfo') 'Hardware inventory command missing'

Write-Host 'All CI tests passed.'
