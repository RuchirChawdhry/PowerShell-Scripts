function Get-QR {
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$Text,

        [string]$Path = (Join-Path (Get-Location) 'qr.png'),

        [ValidateRange(10, 2000)]
        [int]$Width = 400
    )

    process {
        New-QRCodeText -Text $Text -Width $Width -OutPath $Path | Out-Null
        Get-Item -LiteralPath $Path
    }
}
