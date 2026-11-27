. "$PSScriptRoot/Private/Find-Process.ps1"

function Get-ProcesID {
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Name
    )

    Find-ProcessFuzzy -Name $Name | Select-Object -ExpandProperty Id
}

Set-Alias -Name Get-ProcessID -Value Get-ProcesID
