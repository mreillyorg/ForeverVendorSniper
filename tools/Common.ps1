# Shared local packaging and installation helpers.
Set-StrictMode -Version Latest
function Get-FvsRoot { return (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path }
function Get-FvsMetadata {
    param([string]$Root)
    $toc = Join-Path $Root 'ForeverVendorSniper.toc'
    if (-not (Test-Path -LiteralPath $toc)) { throw "Missing $toc" }
    $lines = @(Get-Content -LiteralPath $toc)
    $version = $null; $interface = $null
    foreach ($line in $lines) {
        if ($line -match '^##\s*Version:\s*(\S+)') { $version = $Matches[1] }
        if ($line -match '^##\s*Interface:\s*(\S+)') { $interface = $Matches[1] }
    }
    if (-not $version -or -not $interface) { throw 'Missing Version or Interface in TOC' }
    return [pscustomobject]@{ Name='ForeverVendorSniper'; Version=$version; Interface=$interface; Toc=$lines }
}
function Get-FvsIgnore {
    param([string]$Root)
    $path = Join-Path $Root '.pkgmeta'
    if (-not (Test-Path -LiteralPath $path)) { throw 'Missing .pkgmeta' }
    $lines = @(Get-Content -LiteralPath $path)
    $active = $false; $ignore = @()
    foreach ($line in $lines) {
        if ($line -match '^ignore\s*:') { $active = $true; continue }
        if ($line -match '^\S' -and $line -notmatch '^\s*#') { $active = $false }
        if ($active -and $line -match '^\s+-\s+(.+?)\s*$') { $ignore += $Matches[1].Trim('"', "'") }
    }
    if ($ignore.Count -eq 0) { throw 'No ignore entries in .pkgmeta' }
    return $ignore
}
function Get-FvsShippingFiles {
    param([string]$Root)
    $ignore = @(Get-FvsIgnore -Root $Root)
    return @(Get-ChildItem -LiteralPath $Root -File | Where-Object {
        $file = $_; $excluded = $file.Name.StartsWith('.')
        foreach ($pattern in $ignore) { if ($file.Name -like $pattern) { $excluded = $true } }
        -not $excluded
    } | Sort-Object Name)
}
function Find-FvsAddOns {
    param([string]$Root)
    $found = @()
    if ($env:WOW_ADDONS_PATH) {
        if (Test-Path -LiteralPath $env:WOW_ADDONS_PATH -PathType Container) {
            return @((Resolve-Path -LiteralPath $env:WOW_ADDONS_PATH).Path)
        }
        throw 'WOW_ADDONS_PATH does not exist'
    }
    $dir = Get-Item -LiteralPath $Root
    while ($null -ne $dir) {
        foreach ($candidate in @((Join-Path $dir.FullName 'Interface\AddOns'), (Join-Path $dir.FullName 'AddOns'))) {
            if (Test-Path -LiteralPath $candidate -PathType Container) { $found += (Resolve-Path -LiteralPath $candidate).Path }
        }
        $dir = $dir.Parent
    }
    foreach ($base in @($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
        if (-not $base) { continue }
        foreach ($flavour in @('_forever_', '_classic_era_', '_classic_')) {
            $candidate = Join-Path $base "World of Warcraft\$flavour\Interface\AddOns"
            if (Test-Path -LiteralPath $candidate -PathType Container) { $found += (Resolve-Path -LiteralPath $candidate).Path }
        }
    }
    return @($found | Select-Object -Unique)
}
function Assert-FvsSafeTarget {
    param([string]$Path)
    if ((Split-Path -Leaf $Path) -ine 'ForeverVendorSniper' -or
        (Split-Path -Leaf (Split-Path -Parent $Path)) -ine 'AddOns') {
        throw "Unsafe target: $Path"
    }
    if (Test-Path -LiteralPath $Path) {
        if ((Get-Item -LiteralPath $Path -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "Refusing to modify junction or symlink: $Path"
        }
    }
}
