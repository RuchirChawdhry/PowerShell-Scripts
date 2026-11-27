. "$PSScriptRoot/Private/Find-Process.ps1"

function Get-HWND {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'Name')]
        [string]$Name,

        [Parameter(Mandatory, ParameterSetName = 'ProcessId')]
        [int]$ProcessId
    )

    $processes = switch ($PSCmdlet.ParameterSetName) {
        Name      { Find-ProcessFuzzy -Name $Name }
        ProcessId { Get-Process -Id $ProcessId }
    }

    $processes |
        Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } |
        Select-Object -ExpandProperty MainWindowHandle
}
