$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../Get-QR.ps1"
Add-Type -AssemblyName System.Windows.Forms

$script:qrPreviewSeen = $false
$timer = [System.Windows.Forms.Timer]::new()
$timer.Interval = 1000
$timer.Add_Tick({
    foreach ($form in [System.Windows.Forms.Application]::OpenForms) {
        if ($form.Text -eq 'QR: QR window CI test') {
            $script:qrPreviewSeen = $true
            $form.Close()
            $timer.Stop()
            break
        }
    }
})

$timer.Start()
$qr = Get-QR -Text 'QR window CI test' -Path (Join-Path $PSScriptRoot 'qr-window.png') -Width 256 -Window
$timer.Dispose()

if (-not $script:qrPreviewSeen) { throw 'QR preview never displayed its Windows Form' }
if ($qr.Name -ne 'qr-window.png') { throw 'QR window did not save its PNG' }
Write-Host 'QR preview window displayed and closed.'
