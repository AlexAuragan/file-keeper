setup() {
    load '../helpers/setup'
    common_setup
    # shellcheck disable=SC1091
    source "${REPO_ROOT}/fk"

    # Create a real config file
    CONF_FILE="$TEST_TMPDIR/nginx.conf"
    touch "$CONF_FILE"

    config_files=("${CONF_FILE}|nginx")
    service_files=("/etc/systemd/system/foo.service|foo")
}

teardown() {
    load '../helpers/setup'
    common_teardown
}

@test "handle_choice numeric opens config file with editor" {
    run handle_choice "1" config_files[@] service_files[@]
    assert_success
    # FK_EDITOR=true so last_cmd records 'true <path>'
    run cat "$FK_LAST_CMD"
    assert_output --partial "$CONF_FILE"
}

@test "handle_choice out-of-range number prints error" {
    run handle_choice "99" config_files[@] service_files[@]
    assert_output --partial "Invalid number"
}

@test "handle_choice letter r restarts service" {
    run handle_choice "ar" config_files[@] service_files[@]
    assert_success
    run cat "$FK_LAST_CMD"
    assert_output --partial "restart"
    assert_output --partial "foo"
}

@test "handle_choice letter s starts service" {
    run handle_choice "as" config_files[@] service_files[@]
    assert_success
    run cat "$FK_LAST_CMD"
    assert_output --partial "start"
}

@test "handle_choice letter i shows status" {
    run handle_choice "ai" config_files[@] service_files[@]
    assert_success
    run cat "$FK_LAST_CMD"
    assert_output --partial "status"
}

@test "handle_choice letter j shows journal" {
    run handle_choice "aj" config_files[@] service_files[@]
    assert_success
    run cat "$FK_LAST_CMD"
    assert_output --partial "journalctl"
}

@test "handle_choice letter jf follows journal" {
    run handle_choice "ajf" config_files[@] service_files[@]
    assert_success
    run cat "$FK_LAST_CMD"
    assert_output --partial "journalctl"
    assert_output --partial "-f"
}

@test "handle_choice unknown action prints error" {
    run handle_choice "ax" config_files[@] service_files[@]
    assert_output --partial "Unknown action: x"
}

@test "handle_choice completely invalid input prints error" {
    run handle_choice "!" config_files[@] service_files[@]
    assert_output --partial "Invalid input"
}
