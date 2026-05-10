setup() {
    load '../helpers/setup'
    common_setup
    # shellcheck disable=SC1091
    source "${REPO_ROOT}/fk"

    # Create real temp files to cat
    CONF_FILE="$TEST_TMPDIR/nginx.conf"
    SVC_FILE="$TEST_TMPDIR/foo.service"
    echo "nginx content" > "$CONF_FILE"
    echo "service content" > "$SVC_FILE"

    populate_db \
        "${CONF_FILE}|nginx" \
        "/etc/systemd/system/foo.service|foo"

    # Point the systemd entry at our temp file via a symlink
    mkdir -p "/tmp/bats_svc_$$"
    ln -sf "$SVC_FILE" "/tmp/bats_svc_$$/foo.service"
    SVC_LINK="/tmp/bats_svc_$$/foo.service"
}

teardown() {
    rm -rf "/tmp/bats_svc_$$"
    load '../helpers/setup'
    common_teardown
}

@test "cat_file returns 1 when DB is empty" {
    rm -f "$FK_DB"
    run cat_file 1
    assert_failure
    assert_output --partial "No files tracked yet."
}

@test "cat_file outputs config file by number" {
    run cat_file 1
    assert_success
    assert_output --partial "nginx content"
}

@test "cat_file fails for out-of-range number" {
    run cat_file 99
    assert_failure
    assert_output --partial "Invalid number: 99"
}

@test "cat_file fails for invalid input" {
    run cat_file "!"
    assert_failure
    assert_output --partial "Usage: fk --cat"
}
