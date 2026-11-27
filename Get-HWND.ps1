function Get-HWND {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'Name')]
        [string]$Name,

        [Parameter(Mandatory, ParameterSetName = 'ProcessId')]
        [int]$ProcessId
    )

    $processes = switch ($PSCmdlet.ParameterSetName) {
        Name      {
            $pattern = ($Name.ToCharArray() | ForEach-Object { [regex]::Escape([string]$_) }) -join '.*'
            Get-Process |
                Where-Object { $_.ProcessName -match $pattern -or $_.MainWindowTitle -match $pattern } |
                Sort-Object @{ Expression = {
                    [int]($_.ProcessName -notlike "$Name*") + [int]($_.ProcessName -notlike "*$Name*")
                } }, ProcessName, Id
        }
        ProcessId { Get-Process -Id $ProcessId }
    }

    $processes |
        Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero } |
        Select-Object -ExpandProperty MainWindowHandle
}
