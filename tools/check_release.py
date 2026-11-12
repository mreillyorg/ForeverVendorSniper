#!/usr/bin/env python3
"""Validate archive structure without publishing to CurseForge."""
from pathlib import Path
from zipfile import ZipFile

archives = list(Path('.release').glob('*.zip'))
if not archives:
    raise SystemExit('No package archive found in .release')
for archive in archives:
    with ZipFile(archive) as z:
        names = z.namelist()
        roots = {name.split('/')[0] for name in names if name}
        if roots != {'ForeverVendorSniper'}:
            raise SystemExit(f'{archive}: unexpected top-level entries {roots}')
        if 'ForeverVendorSniper/ForeverVendorSniper.toc' not in names:
            raise SystemExit(f'{archive}: missing TOC')
        if any('/tests/' in name or '/tools/' in name for name in names):
            raise SystemExit(f'{archive}: development files leaked')
    print('PASS:', archive)
