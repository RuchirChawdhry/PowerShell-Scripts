. "$PSScriptRoot/Private/Find-Process.ps1"
. "$PSScriptRoot/Private/ScreenCapture.ps1"

function Get-ScreenshotJumplist {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'Name')]
        [string]$Name,

        [Parameter(Mandatory, ParameterSetName = 'ProcessId')]
        [int]$ProcessId,

        [string]$Path = (Join-Path (Get-Location) 'jumplist.png')
    )

    $process = switch ($PSCmdlet.ParameterSetName) {
        Name      { Find-ProcessFuzzy -Name $Name | Where-Object MainWindowHandle -NE 0 | Select-Object -First 1 }
        ProcessId { Get-Process -Id $ProcessId }
    }

    $taskbar = [PowerShellScriptsNative]::FindWindow('Shell_TrayWnd', $null)
    $tree = winapp ui inspect -w $taskbar --interactive --json | ConvertFrom-Json
    $pattern = (@($Name, $process.ProcessName, $process.MainWindowTitle) |
        Where-Object { $_ } |
        ForEach-Object { [regex]::Escape($_) }) -join '|'
    $button = @($tree.windows[0].elements) |
        Where-Object { $_.name -match $pattern } |
        Select-Object -First 1

    [PowerShellScriptsNative]::keybd_event(0x5B, 0, 0, [UIntPtr]::Zero)
    [PowerShellScriptsNative]::keybd_event(0x54, 0, 0, [UIntPtr]::Zero)
    [PowerShellScriptsNative]::keybd_event(0x54, 0, 2, [UIntPtr]::Zero)
    [PowerShellScriptsNative]::keybd_event(0x5B, 0, 2, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 250

    winapp ui click $button.selector -w $taskbar --right --json | Out-Null
    Start-Sleep -Milliseconds 1200

    $popup = [PowerShellScriptsNative]::GetForegroundWindow()
    $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    winapp ui screenshot -w $popup --capture-screen --output $Path --json | Out-Null
    Get-Item -LiteralPath $Path
}
