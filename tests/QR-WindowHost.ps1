. "$PSScriptRoot/../Get-QR.ps1"
Get-QR -Text 'QR window CI test' -Path (Join-Path $PSScriptRoot 'qr-window.png') -Width 256 -Window
