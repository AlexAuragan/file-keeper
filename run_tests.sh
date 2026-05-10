#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATS="$REPO_ROOT/tests/lib/bats/bin/bats"

if [[ ! -x "$BATS" ]]; then
    echo "ERROR: bats not found. Run: git submodule update --init --recursive"
    exit 1
fi

if [[ $# -gt 0 ]]; then
    exec "$BATS" --print-output-on-failure "$REPO_ROOT/tests/$1"
fi

exec "$BATS" \
    --print-output-on-failure \
    --recursive \
    "$REPO_ROOT/tests/fk" \
    "$REPO_ROOT/tests/fkg"
