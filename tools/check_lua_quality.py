#!/usr/bin/env python3
"""Run Lua 5.1 parsing, Luacheck, and the unit tests from the repo root."""
import argparse
import pathlib
import subprocess
import sys

root = pathlib.Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser()
parser.add_argument('--lua', default='lua5.1')
parser.add_argument('--luac', default='luac5.1')
parser.add_argument('--luacheck', default='luacheck')
args = parser.parse_args()
files = sorted(root.glob('*.lua')) + sorted((root / 'tests').glob('*.lua'))

def run(command):
    print('+', ' '.join(str(x) for x in command), flush=True)
    subprocess.run([str(x) for x in command], cwd=root, check=True)

try:
    for file in files:
        run([args.luac, '-p', file.relative_to(root)])
    run([args.luacheck, '--config', '.luacheckrc'] + [str(f.relative_to(root)) for f in files])
    run([args.lua, 'tests/run_tests.lua'])
except (OSError, subprocess.CalledProcessError) as exc:
    print('FAILED:', exc, file=sys.stderr)
    sys.exit(1)
print('All quality checks passed')
