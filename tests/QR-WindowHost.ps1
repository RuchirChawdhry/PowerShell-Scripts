Write-Host 'QR host started'
. "$PSScriptRoot/../Get-QR.ps1"
Write-Host 'QR source loaded'
Get-QR -Text 'QR window CI test' -Path (Join-Path $PSScriptRoot 'qr-window.png') -Width 256 -Window -Verbose
