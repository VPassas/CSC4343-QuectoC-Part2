#!/usr/bin/env python3
"""Compare stdout, stderr and status with independent expected results."""
from pathlib import Path
import json, subprocess, sys

root = Path(__file__).resolve().parent.parent
cases = json.loads((root / 'tests/cases.json').read_text())

failures = 0

for case in cases:
    expected = (case['stdout'], case['stderr'], case['status'])

    try:
        result = subprocess.run(
            [str(root / 'build/quectoc-parser')],
            input=case['input'].encode('ascii'),
            capture_output=True,
            timeout=5
        )

        actual = (
            result.stdout.decode(),
            result.stderr.decode(),
            result.returncode
        )

    except subprocess.TimeoutExpired:
        actual = ('', 'TIMEOUT', -1)

    ok = actual == expected

    print(('PASS ' if ok else 'FAIL ') + case['id'])

    if not ok:
        failures += 1
        print(' expected:', repr(expected))
        print(' actual:  ', repr(actual))

print(f'{len(cases)-failures}/{len(cases)} passed')

sys.exit(bool(failures))