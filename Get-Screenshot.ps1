. "$PSScriptRoot/Get-HWND.ps1"
. "$PSScriptRoot/Private/ScreenCapture.ps1"

function Get-Screenshot {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'Name')]
        [string]$Name,

        [Parameter(Mandatory, ParameterSetName = 'ProcessId')]
        [int]$ProcessId,

        [Parameter(Mandatory, ParameterSetName = 'Hwnd')]
        [IntPtr]$Hwnd,

        [string]$Path = (Join-Path (Get-Location) 'screenshot.png')
    )

    $window = switch ($PSCmdlet.ParameterSetName) {
        Name      { Get-HWND -Name $Name | Select-Object -First 1 }
        ProcessId { Get-HWND -ProcessId $ProcessId | Select-Object -First 1 }
        Hwnd      { $Hwnd }
    }

    [void][PowerShellScriptsNative]::SetForegroundWindow($window)
    Start-Sleep -Milliseconds 250

    $bounds = [PowerShellScriptsNative+RECT]::new()
    [void][PowerShellScriptsNative]::DwmGetWindowAttribute(
        $window, 9, [ref]$bounds, [Runtime.InteropServices.Marshal]::SizeOf($bounds)
    )

    $rectangle = [System.Drawing.Rectangle]::FromLTRB(
        $bounds.Left, $bounds.Top, $bounds.Right, $bounds.Bottom
    )
    $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    $bitmap = New-ScreenBitmap -Bounds $rectangle
    $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
    Get-Item -LiteralPath $Path
}
