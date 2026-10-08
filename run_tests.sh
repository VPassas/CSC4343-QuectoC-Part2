#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
bash build.sh
python3 tests/run_tests.py