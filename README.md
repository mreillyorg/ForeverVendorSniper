# ForeverVendorSniper

Experimental WoW Forever (1.60.1 / Lua 5.1) Auction House vendor-arbitrage addon.

**Status: alpha, not purchase-ready.** The native scanner enumerates pages manually and calculates buyout-versus-NPC-vendor profit. The purchase action is intentionally disabled until Forever's live purchase and commodity API can be verified in game. Do not describe this build as supporting working buyouts or automatic full scans.

## Features implemented
- Movable AH companion panel; `/fvs` toggles, `/fvs scan` starts a scan.
- Native AH page scan with manual Next Page and Stop controls.
- Vendor resale comparison, minimum profit (default 1 silver) and discount calculation.
- Blizzard, Dark and Light palette switching; validated custom theme storage API (in-game editor pending).
- Optional Auctionator/TSM detection only; actual adapter integration pending API verification.
- Fail-closed purchasing stub and tests.

## Known limitations
- Forever's AH may use different query and commodity APIs; verify in game before relying on scanner results.
- Missing `GetItemInfo` cache data means an item is skipped.
- Results from prior pages are **not** live actionable auction indices.
- No automatic scan continuation, bid opportunities, custom theme editor or import/export yet.
- UI resizability and confirmation/purchase workflow are pending.

## Live Auction House API diagnostics
While logged in, run `/fvs debug api`. The command enumerates only function names
from `C_AuctionHouse` (it sends **no** auction queries and makes no purchases).
Log out normally to write SavedVariables, then inspect:
`_forever_/WTF/Account/<account>/SavedVariables/ForeverVendorSniper.lua`.
Look for `apiDiagnostics.methods` in `ForeverVendorSniperDB`; it is an alphabetically
sorted list, with `count` and schema `version`. The command overwrites the previous
snapshot on each successful capture. If the AH API is unavailable, it reports an
error and leaves the previous snapshot untouched.

## Testing
Run `python tools/check_lua_quality.py --lua /path/to/lua5.1 --luac /path/to/luac5.1 --luacheck /path/to/luacheck`.

## Packaging
BigWigsMods/packager uses `.pkgmeta` and `package-as` to produce one top-level `ForeverVendorSniper/` folder. Configure CurseForge project ID in the TOC and `CF_API_KEY` GitHub secret before publishing. Publishing is disabled until live integration is tested.

## Custom themes (alpha)
The in-game theme editor is currently command-based:
- `/fvs theme create Ocean` duplicates the current theme and selects it.
- `/fvs theme color Ocean accent #55AADD` sets one color. Supported fields: `background`, `panel`, `accent`, `text`, `profit`.
- `/fvs theme select Dark` selects a built-in or saved custom theme.
- `/fvs theme delete Ocean` removes a custom theme.
Custom themes persist in SavedVariables. A graphical color picker remains planned.

## Scanner notes
The native scanner currently requires clicking **Next Page** between pages, honors query cooldowns and does not purchase auctions. Auctionator and TSM are detected but are not yet integrated as live listing providers. Forever AH API verification is still required.

## Windows local development tools

The PowerShell helpers in `tools/` are adapted from ForeverWindowMover's development workflow.
The `.pkgmeta` ignore list controls which root-level files are copied, matching the
BigWigs release packaging exclusions. They do not include `.git`, tests or tools.

```powershell
.\tools\build.ps1 -Check
.\tools\build.ps1
.\tools\Sync-ToAddOns.ps1 -WhatIf
.\tools\Sync-ToAddOns.ps1 -AddOnsPath 'C:\Games\WoW\Interface\AddOns'
.\tools\Sync-ToAddOns.ps1 -Watch -SkipBuild
.\tools\Sync-ToAddOns.ps1 -Remove -AddOnsPath 'C:\Games\WoW\Interface\AddOns'
```

Set `$env:WOW_ADDONS_PATH` to your `Interface\AddOns` directory for automatic
selection. When multiple installations are detected, specify `-AddOnsPath`.
The sync tool refuses to modify any target outside an `AddOns\ForeverVendorSniper`
folder, and it rejects junctions/symlinks at that target. `-WhatIf` previews changes.
The watcher runs until Ctrl+C; Lua changes require `/reload` in game.
