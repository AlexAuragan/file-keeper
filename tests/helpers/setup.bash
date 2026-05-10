REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"

load "${REPO_ROOT}/tests/lib/bats-support/load"
load "${REPO_ROOT}/tests/lib/bats-assert/load"

common_setup() {
    TEST_TMPDIR="$(mktemp -d)"
    export HOME="$TEST_TMPDIR/home"
    mkdir -p "$HOME"

    export FK_DB="$TEST_TMPDIR/.file_keeper"
    export FK_LAST_CMD="$TEST_TMPDIR/fk_last_cmd"
    export FK_EDITOR="true"  # no-op editor
    export FK_NODES_FILE="$TEST_TMPDIR/.fkg_nodes"
    export FK_CACHE_DIR="$TEST_TMPDIR/cache"
    export MOCK_GIT_CALLS_FILE="$TEST_TMPDIR/git_calls"
    export MOCK_SSH_CALLS_FILE="$TEST_TMPDIR/ssh_calls"

    mkdir -p "$FK_CACHE_DIR"

    # Prepend per-test writable mock dir (for configure_mock)
    export MOCK_BIN="$TEST_TMPDIR/mocks"
    mkdir -p "$MOCK_BIN"
    export PATH="$MOCK_BIN:${REPO_ROOT}/tests/helpers/mocks:$PATH"
}

common_teardown() {
    rm -rf "$TEST_TMPDIR"
}

# Write a one-off mock into the per-test MOCK_BIN dir.
# Usage: configure_mock <name> <exit_code> <stdout>
configure_mock() {
    local name="$1" exit_code="$2" stdout="$3"
    printf '#!/bin/bash\necho %s\nexit %d\n' "$stdout" "$exit_code" \
        > "$MOCK_BIN/$name"
    chmod +x "$MOCK_BIN/$name"
}

# Populate FK_DB with given lines.
populate_db() {
    printf '%s\n' "$@" > "$FK_DB"
}
