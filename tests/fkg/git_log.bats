setup() {
    load '../helpers/setup'
    common_setup
    # shellcheck disable=SC1091
    source "${REPO_ROOT}/fkg"
    mkdir -p "$FK_CACHE_DIR/.git"
}

teardown() {
    load '../helpers/setup'
    common_teardown
}

@test "git_log fails when git not initialized" {
    rm -rf "$FK_CACHE_DIR/.git"
    run git_log
    assert_failure
    assert_output --partial "Git not initialized"
}

@test "git_log calls git log --oneline" {
    run git_log
    assert_success
    run grep "log --oneline" "$MOCK_GIT_CALLS_FILE"
    assert_success
}

@test "git_log forwards extra args to git log" {
    git_log lenovo/CT108/etc/nginx/nginx.conf
    run grep "lenovo/CT108/etc/nginx/nginx.conf" "$MOCK_GIT_CALLS_FILE"
    assert_success
}
