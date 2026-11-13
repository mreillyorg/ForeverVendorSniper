<# Validates the addon and optionally builds a local installation ZIP. #>
[CmdletBinding()]
param([switch]$Check, [string]$OutputDirectory)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
$root = Get-FvsRoot
$meta = Get-FvsMetadata -Root $root
$files = @(Get-FvsShippingFiles -Root $root)
$names = @($files | ForEach-Object { $_.Name })
$pkgmeta = Get-Content -LiteralPath (Join-Path $root '.pkgmeta') -Raw
if ($pkgmeta -notmatch '(?m)^package-as:\s*ForeverVendorSniper\s*$') { throw 'Invalid package-as in .pkgmeta' }
$luaFiles = @($meta.Toc | Where-Object { $_ -match '^\s*[^#].*\.lua\s*$' } | ForEach-Object { $_.Trim() })
foreach ($required in @('ForeverVendorSniper.toc') + $luaFiles) {
    if ($names -notcontains $required) { throw "Missing or excluded shipping file: $required" }
}
foreach ($file in @(Get-ChildItem -LiteralPath $root -Filter '*.lua' -File)) {
    if ($luaFiles -notcontains $file.Name) { throw "Lua file not listed in TOC: $($file.Name)" }
}
Write-Host "Validated $($meta.Name) $($meta.Version), Interface $($meta.Interface), $($files.Count) shipping files"
if ($Check) { return }
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $root 'dist' }
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$staging = Join-Path ([IO.Path]::GetTempPath()) ('fvs-' + [guid]::NewGuid().ToString('N'))
try {
    $addon = Join-Path $staging $meta.Name
    New-Item -ItemType Directory -Path $addon -Force | Out-Null
    foreach ($file in $files) { Copy-Item -LiteralPath $file.FullName -Destination $addon }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = Join-Path $OutputDirectory "$($meta.Name)-$($meta.Version).zip"
    if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
    [IO.Compression.ZipFile]::CreateFromDirectory($staging, $zip)
    Write-Host "Created $zip"
} finally { if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force } }
