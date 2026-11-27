# Get-QR

Uses a bundled PowerShell QR encoder and Windows' built-in .NET drawing APIs. No QR module, package, API key, or network service.

## Usage

```powershell
. .\Get-QR.ps1
Get-QR 'Hello world' -Terminal -Window -Path .\hello.png -Width 400
```

## Parameters

- `-Text`: Required text or pipeline input.
- `-Path`: PNG output path; defaults to qr.png in the working directory.
- `-Width`: Square image size in pixels; defaults to 400.
- `-Terminal`: Print ANSI-colored half-block QR glyphs in the console.
- `-Window`: Open a Windows Forms QR preview and wait until it is closed.

## Returns

PNG FileInfo object; terminal rendering is written to the host when selected.

## Notes

Every invocation writes the PNG. -Terminal and -Window can be combined. The QR has a four-module quiet zone and an opaque white background.

[Source script](https://github.com/RuchirChawdhry/PowerShell-Scripts/blob/main/Get-QR.ps1) · [Documentation page](https://ruchirchawdhry.github.io/PowerShell-Scripts/scripts/get-qr.html)
