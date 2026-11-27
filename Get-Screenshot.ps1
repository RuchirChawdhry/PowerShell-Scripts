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
        Name      {
            $pattern = ($Name.ToCharArray() | ForEach-Object { [regex]::Escape([string]$_) }) -join '.*'
            Get-Process |
                Where-Object { $_.ProcessName -match $pattern -or $_.MainWindowTitle -match $pattern } |
                Sort-Object @{ Expression = {
                    [int]($_.ProcessName -notlike "$Name*") + [int]($_.ProcessName -notlike "*$Name*")
                } }, ProcessName, Id |
                Where-Object MainWindowHandle -NE 0 |
                Select-Object -First 1 -ExpandProperty MainWindowHandle
        }
        ProcessId { (Get-Process -Id $ProcessId).MainWindowHandle }
        Hwnd      { $Hwnd }
    }

    $Path = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    winapp ui screenshot -w $window --capture-screen --output $Path --json | Out-Null
    Get-Item -LiteralPath $Path
}
