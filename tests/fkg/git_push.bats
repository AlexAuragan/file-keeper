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

@test "git_push fails when git not initialized" {
    rm -rf "$FK_CACHE_DIR/.git"
    run git_push
    assert_failure
    assert_output --partial "Git not initialized"
}

@test "git_push prints nothing to commit when diff is clean" {
    export MOCK_GIT_DIFF_EXIT=0  # 0 = no changes
    run git_push
    assert_success
    assert_output --partial "Nothing to commit"
}

@test "git_push commits and pushes when there are changes" {
    export MOCK_GIT_DIFF_EXIT=1  # 1 = changes exist
    run git_push "my commit message"
    assert_success
    run grep "commit" "$MOCK_GIT_CALLS_FILE"
    assert_success
    run grep "push" "$MOCK_GIT_CALLS_FILE"
    assert_success
}

@test "git_push uses provided commit message" {
    export MOCK_GIT_DIFF_EXIT=1
    git_push "weekly backup"
    run grep "weekly backup" "$MOCK_GIT_CALLS_FILE"
    assert_success
}

@test "git_push defaults to timestamp message when none given" {
    export MOCK_GIT_DIFF_EXIT=1
    git_push
    # Timestamp format: YYYY-MM-DD HH:MM:SS
    run grep -E "[0-9]{4}-[0-9]{2}-[0-9]{2}" "$MOCK_GIT_CALLS_FILE"
    assert_success
}
