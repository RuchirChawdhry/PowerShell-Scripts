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
    'Get-HWND.ps1', 'Get-ProcesID.ps1', 'Get-Screenshot.ps1',
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
    param([string]$Namespace, [string]$ClassName)
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
    }
}

$battery = Get-BatteryInfo
Assert ($battery.HealthPercent -eq 80) 'Battery health calculation failed'
Assert ($battery.ChargePercent -eq 50) 'Battery charge calculation failed'
Assert ($battery.Discharging -eq $true) 'Battery discharge status failed'
Remove-Item Function:Get-CimInstance

$directory = Join-Path ([System.IO.Path]::GetTempPath()) ("powershell-scripts-" + [guid]::NewGuid())
[void](New-Item -ItemType Directory -Path $directory)
$path = Join-Path $directory 'qr.png'
$qr = Get-QR -Text 'AarPaar QR test' -Path $path -Width 256
$bytes = [System.IO.File]::ReadAllBytes($qr.FullName)
Assert ((($bytes[0..7] -join ',') -eq '137,80,78,71,13,10,26,10')) 'QR output is not PNG'
$image = [System.Drawing.Image]::FromFile($qr.FullName)
Assert ($image.Width -ge 10 -and $image.Height -ge 10) 'QR image is empty'
$image.Dispose()

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
$capture.Dispose()
$form.Close()
$form.Dispose()
Remove-Item $directory -Recurse -Force

Assert ((Get-Command Get-Screenshot).ParameterSets.Name -contains 'Hwnd') 'Screenshot HWND parameter set missing'
Assert ((Get-Command Get-Screenshot).ParameterSets.Name -contains 'ProcessId') 'Screenshot PID parameter set missing'
Assert ((Get-Command Get-ScreenshotJumplist).ParameterSets.Name -contains 'Name') 'Jump-list name parameter set missing'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Windows.Forms
Assert ($null -ne [Windows.Automation.AutomationElement]::RootElement) 'Windows UI Automation unavailable'

Write-Host 'All CI tests passed.'
