. "$PSScriptRoot/Get-HWND.ps1"

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

    $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    winapp ui screenshot -w $window --capture-screen --output $Path --json | Out-Null
    Get-Item -LiteralPath $Path
}
