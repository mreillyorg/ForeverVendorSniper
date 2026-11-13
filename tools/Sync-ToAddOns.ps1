<#
.SYNOPSIS
    Safely mirror release files to Interface\AddOns\ForeverVendorSniper.
.EXAMPLE
    .\tools\Sync-ToAddOns.ps1 -WhatIf
.EXAMPLE
    .\tools\Sync-ToAddOns.ps1 -AddOnsPath 'C:\Games\WoW\Interface\AddOns'
.EXAMPLE
    .\tools\Sync-ToAddOns.ps1 -Watch -SkipBuild
#>
[CmdletBinding(SupportsShouldProcess)]
param([string]$AddOnsPath, [switch]$Watch, [switch]$Remove, [switch]$SkipBuild)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
$root = Get-FvsRoot
$meta = Get-FvsMetadata -Root $root
if ($AddOnsPath) {
    if (-not (Test-Path -LiteralPath $AddOnsPath -PathType Container)) { throw "Missing AddOns directory: $AddOnsPath" }
    $directory = (Resolve-Path -LiteralPath $AddOnsPath).Path
} else {
    $found = @(Find-FvsAddOns -Root $root)
    if ($found.Count -ne 1) { throw "Expected one AddOns directory, found $($found.Count). Specify -AddOnsPath." }
    $directory = $found[0]
}
if ((Split-Path -Leaf $directory) -ine 'AddOns') { throw "Not an AddOns directory: $directory" }
$target = Join-Path $directory $meta.Name
Assert-FvsSafeTarget -Path $target
Write-Host "Source: $root`nTarget: $target"
if ($Remove) {
    if (Test-Path -LiteralPath $target) {
        if ($PSCmdlet.ShouldProcess($target, 'Remove installed addon')) {
            Remove-Item -LiteralPath $target -Recurse -Force
        }
    }
    return
}
if (-not $SkipBuild) { & (Join-Path $PSScriptRoot 'build.ps1') -Check }
function Sync-FvsOnce {
    Assert-FvsSafeTarget -Path $target
    $shipping = @(Get-FvsShippingFiles -Root $root)
    if ($shipping.Count -eq 0) { throw 'No files to install' }
    if (-not (Test-Path -LiteralPath $target)) {
        if ($PSCmdlet.ShouldProcess($target, 'Create addon directory')) {
            New-Item -ItemType Directory -Path $target -Force | Out-Null
        }
    }
    foreach ($file in $shipping) {
        $destination = Join-Path $target $file.Name
        if ($PSCmdlet.ShouldProcess($destination, 'Copy addon file')) {
            Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
        }
    }
    if (Test-Path -LiteralPath $target) {
        $names = @($shipping | ForEach-Object { $_.Name })
        foreach ($entry in @(Get-ChildItem -LiteralPath $target -Force)) {
            if ($names -notcontains $entry.Name) {
                if ($PSCmdlet.ShouldProcess($entry.FullName, 'Remove stale addon file')) {
                    Remove-Item -LiteralPath $entry.FullName -Recurse -Force
                }
            }
        }
    }
    Write-Host "Synced $($shipping.Count) files. Use /reload in WoW for Lua changes."
}
Sync-FvsOnce
if (-not $Watch -or $WhatIfPreference) { return }
Write-Host 'Watching source directory. Press Ctrl+C to stop.'
$watcher = New-Object IO.FileSystemWatcher
$watcher.Path = $root
$watcher.IncludeSubdirectories = $false
$watcher.NotifyFilter = [IO.NotifyFilters]::LastWrite -bor [IO.NotifyFilters]::FileName -bor [IO.NotifyFilters]::Size
try {
    $watcher.EnableRaisingEvents = $true
    while ($true) {
        $change = $watcher.WaitForChanged([IO.WatcherChangeTypes]::All, 1000)
        if ($change.TimedOut) { continue }
        do { $next = $watcher.WaitForChanged([IO.WatcherChangeTypes]::All, 400) } while (-not $next.TimedOut)
        try { Sync-FvsOnce } catch { Write-Warning $_.Exception.Message }
    }
} finally { $watcher.Dispose() }
