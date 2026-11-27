. "$PSScriptRoot/Private/Find-Process.ps1"
. "$PSScriptRoot/Private/ScreenCapture.ps1"

function Get-ScreenshotJumplist {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'Name')]
        [string]$Name,

        [Parameter(Mandatory, ParameterSetName = 'ProcessId')]
        [int]$ProcessId,

        [string]$Path = (Join-Path (Get-Location) 'jumplist.png'),

        [ValidateRange(200, 1200)]
        [int]$Width = 540
    )

    Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Windows.Forms

    $process = switch ($PSCmdlet.ParameterSetName) {
        Name      { Find-ProcessFuzzy -Name $Name | Where-Object MainWindowHandle -NE 0 | Select-Object -First 1 }
        ProcessId { Get-Process -Id $ProcessId }
    }

    $taskbarHandle = [PowerShellScriptsNative]::FindWindow('Shell_TrayWnd', $null)
    $taskbar = [Windows.Automation.AutomationElement]::FromHandle($taskbarHandle)
    $buttons = $taskbar.FindAll(
        [Windows.Automation.TreeScope]::Descendants,
        [Windows.Automation.PropertyCondition]::new(
            [Windows.Automation.AutomationElement]::ControlTypeProperty,
            [Windows.Automation.ControlType]::Button
        )
    )

    $windowTitle = ($process.MainWindowTitle -ne '') ? $process.MainWindowTitle : $process.ProcessName
    $button = $buttons |
        Where-Object {
            $_.Current.Name -like "*$($process.ProcessName)*" -or
            $_.Current.Name -like "*$windowTitle*"
        } |
        Select-Object -First 1

    $icon = $button.Current.BoundingRectangle
    $screen = [System.Windows.Forms.Screen]::FromPoint(
        [System.Drawing.Point]::new([int]($icon.Left + $icon.Width / 2), [int]$icon.Top)
    ).Bounds
    $left = [math]::Max($screen.Left, [math]::Min(
        [int]($icon.Left + $icon.Width / 2 - $Width / 2), $screen.Right - $Width
    ))
    $area = [System.Drawing.Rectangle]::FromLTRB($left, $screen.Top, $left + $Width, [int]$icon.Top)

    $before = New-ScreenBitmap -Bounds $area
    $centerX = [int]($icon.Left + $icon.Width / 2)
    $centerY = [int]($icon.Top + $icon.Height / 2)
    [void][PowerShellScriptsNative]::SetCursorPos($centerX, $centerY)
    [PowerShellScriptsNative]::mouse_event(0x0008, 0, 0, 0, [UIntPtr]::Zero)
    [PowerShellScriptsNative]::mouse_event(0x0010, 0, 0, 0, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 600
    $after = New-ScreenBitmap -Bounds $area

    $xMin, $yMin = $area.Width, $area.Height
    $xMax, $yMax = 0, 0
    for ($y = 0; $y -lt $area.Height; $y += 4) {
        for ($x = 0; $x -lt $area.Width; $x += 4) {
            $a = $after.GetPixel($x, $y)
            $b = $before.GetPixel($x, $y)
            $delta = [math]::Abs([int]$a.R - $b.R) +
                     [math]::Abs([int]$a.G - $b.G) +
                     [math]::Abs([int]$a.B - $b.B)
            if ($delta -gt 40) {
                $xMin = [math]::Min($xMin, $x)
                $yMin = [math]::Min($yMin, $y)
                $xMax = [math]::Max($xMax, $x)
                $yMax = [math]::Max($yMax, $y)
            }
        }
    }

    $crop = [System.Drawing.Rectangle]::FromLTRB(
        [math]::Max(0, $xMin - 12), [math]::Max(0, $yMin - 12),
        [math]::Min($area.Width, $xMax + 16), [math]::Min($area.Height, $yMax + 16)
    )
    $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    $image = $after.Clone($crop, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $image.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $image.Dispose()
    $after.Dispose()
    $before.Dispose()
    Get-Item -LiteralPath $Path
}
