Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class JumpListNative {
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr FindWindow(string className, string windowName);

    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    public static extern void keybd_event(byte virtualKey, byte scan, uint flags, UIntPtr extraInfo);
}
'@

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
        Name      {
            $pattern = ($Name.ToCharArray() | ForEach-Object { [regex]::Escape([string]$_) }) -join '.*'
            Get-Process |
                Where-Object { $_.ProcessName -match $pattern -or $_.MainWindowTitle -match $pattern } |
                Sort-Object @{ Expression = {
                    [int]($_.ProcessName -notlike "$Name*") + [int]($_.ProcessName -notlike "*$Name*")
                } }, ProcessName, Id |
                Where-Object MainWindowHandle -NE 0 |
                Select-Object -First 1
        }
        ProcessId { Get-Process -Id $ProcessId }
    }

    $taskbar = [JumpListNative]::FindWindow('Shell_TrayWnd', $null)
    $tree = winapp ui inspect -w $taskbar --interactive --json | ConvertFrom-Json
    $pattern = (@($Name, $process.ProcessName, $process.MainWindowTitle) |
        Where-Object { $_ } |
        ForEach-Object { [regex]::Escape($_) }) -join '|'
    $button = @($tree.windows[0].elements) |
        Where-Object { $_.name -match $pattern } |
        Select-Object -First 1

    [JumpListNative]::keybd_event(0x5B, 0, 0, [UIntPtr]::Zero)
    [JumpListNative]::keybd_event(0x54, 0, 0, [UIntPtr]::Zero)
    [JumpListNative]::keybd_event(0x54, 0, 2, [UIntPtr]::Zero)
    [JumpListNative]::keybd_event(0x5B, 0, 2, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 250

    winapp ui click $button.selector -w $taskbar --right --json | Out-Null
    Start-Sleep -Milliseconds 1200

    $popup = [JumpListNative]::GetForegroundWindow()
    $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    winapp ui screenshot -w $popup --capture-screen --output $Path --json | Out-Null
    Get-Item -LiteralPath $Path
}
