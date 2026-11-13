# Changelog

## 0.1.0-alpha (unreleased)
- Establish Lua 5.1 addon structure and native AH scanning prototype.
- Add vendor arbitrage calculations, movable companion panel, and three themes.
- Add fail-closed purchase validation, unit tests, and release packaging configuration.

- Add `/fvs debug api` to persist a sorted C_AuctionHouse function inventory.
- Correct the TOC interface metadata to WoW Forever 16001.

### Development continuation
- Added custom-theme creation, selection, editing and deletion through `/fvs theme` commands.
- Improved scan pagination, query-error handling and throttling recovery.
- Added mocked two-page scan and custom-theme regression tests (40 assertions total).
- Kept live purchasing disabled until Forever-specific purchase APIs are confirmed.
