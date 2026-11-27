$ErrorActionPreference = 'Stop'

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class QRWindowTestNative {
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern IntPtr FindWindow(string className, string title);
    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr hwnd, uint msg, IntPtr wParam, IntPtr lParam);
}
'@

$qrProcess = Start-Process (Get-Command pwsh).Source -ArgumentList '-NoProfile', '-STA', '-File', "`"$PSScriptRoot/QR-WindowHost.ps1`"" -NoNewWindow -PassThru
for ($attempt = 0; $attempt -lt 35; $attempt++) {
    $window = [QRWindowTestNative]::FindWindow($null, 'QR: QR window CI test')
    if ($window -ne [IntPtr]::Zero -or $qrProcess.HasExited) { break }
    Start-Sleep -Seconds 1
}

if ($window -eq [IntPtr]::Zero) { throw "QR window unavailable; child exited: $($qrProcess.HasExited)" }
[void][QRWindowTestNative]::PostMessage($window, 0x0010, [IntPtr]::Zero, [IntPtr]::Zero)
if (-not $qrProcess.WaitForExit(15000)) { throw 'QR window did not close' }
if ($qrProcess.ExitCode -ne 0) { throw "QR window host exited with $($qrProcess.ExitCode)" }
if (-not (Test-Path (Join-Path $PSScriptRoot 'qr-window.png'))) { throw 'QR window PNG missing' }
Write-Host 'QR preview window opened and closed.'
