function Find-ProcessFuzzy {
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $pattern = ($Name.ToCharArray() | ForEach-Object { [regex]::Escape([string]$_) }) -join '.*'

    Get-Process |
        Where-Object { $_.ProcessName -match $pattern -or $_.MainWindowTitle -match $pattern } |
        Sort-Object @{ Expression = {
            [int]($_.ProcessName -notlike "$Name*") + [int]($_.ProcessName -notlike "*$Name*")
        } }, ProcessName, Id
}
