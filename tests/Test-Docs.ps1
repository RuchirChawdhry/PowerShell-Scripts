$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$docs = Join-Path $root 'docs'
$wiki = Join-Path $root 'wiki'

[xml]$sitemap = Get-Content (Join-Path $docs 'sitemap.xml') -Raw
$urls = @($sitemap.SelectNodes('//*[local-name()="loc"]'))
if ($urls.Count -ne 9) { throw 'The sitemap must include the homepage and all eight command pages' }
if (Test-Path (Join-Path $docs 'sitemap-0.xml')) { throw 'Unexpected numbered sitemap' }

foreach ($node in $urls) {
    $url = [uri]$node.InnerText
    if ($url.Host -ne 'ruchirchawdhry.github.io') { throw "Wrong sitemap origin: $url" }
    $relative = $url.AbsolutePath -replace '^/PowerShell-Scripts/?', ''
    $target = if ($relative) { Join-Path $docs $relative } else { Join-Path $docs 'index.html' }
    if (-not (Test-Path $target)) { throw "Sitemap target missing: $url" }
}

@('Get-BluetoothBattery', 'Get-BatteryInfo', 'Get-QR', 'Get-HWND',
  'Get-ProcesID', 'Get-HWInfo', 'Get-Screenshot', 'Get-ScreenshotJumplist') | ForEach-Object {
    if (-not (Test-Path (Join-Path $wiki "$_.md"))) { throw "Wiki page missing: $_" }
    if ((Get-Content (Join-Path $wiki 'Home.md') -Raw) -notmatch [regex]::Escape("[[$_]]")) {
        throw "Wiki navigation missing: $_"
    }
}

Write-Host 'Pages, sitemap.xml and GitHub Wiki sources are complete.'
