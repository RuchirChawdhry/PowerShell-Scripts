function Get-ProcesID {
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Name
    )

    $pattern = ($Name.ToCharArray() | ForEach-Object { [regex]::Escape([string]$_) }) -join '.*'
    Get-Process |
        Where-Object { $_.ProcessName -match $pattern -or $_.MainWindowTitle -match $pattern } |
        Sort-Object @{ Expression = {
            [int]($_.ProcessName -notlike "$Name*") + [int]($_.ProcessName -notlike "*$Name*")
        } }, ProcessName, Id |
        Select-Object -ExpandProperty Id
}

Set-Alias -Name Get-ProcessID -Value Get-ProcesID
