setup() {
    load '../helpers/setup'
    common_setup
    mkdir -p "${FK_CACHE_DIR}/.git"
}

teardown() {
    load '../helpers/setup'
    common_teardown
}

@test "git_restore fails when git not initialized" {
    rm -rf "${FK_CACHE_DIR}/.git"
    run bash -c "
        export FK_CACHE_DIR='${FK_CACHE_DIR}'
        export PATH='${MOCK_BIN}:${REPO_ROOT}/tests/helpers/mocks:${PATH}'
        source '${REPO_ROOT}/fkg'
        git_restore lenovo/CT108/etc/nginx/nginx.conf
    "
    assert_failure
    assert_output --partial "Git not initialized"
}

@test "git_restore requires a file argument" {
    run bash -c "
        export FK_CACHE_DIR='${FK_CACHE_DIR}'
        export PATH='${MOCK_BIN}:${REPO_ROOT}/tests/helpers/mocks:${PATH}'
        source '${REPO_ROOT}/fkg'
        git_restore
    "
    assert_failure
    assert_output --partial "Usage:"
}

@test "git_restore previews file content before prompting" {
    export MOCK_GIT_SHOW_OUTPUT="server { listen 80; }"
    run bash -c "
        export FK_CACHE_DIR='${FK_CACHE_DIR}'
        export MOCK_GIT_CALLS_FILE='${MOCK_GIT_CALLS_FILE}'
        export MOCK_GIT_SHOW_OUTPUT='server { listen 80; }'
        export PATH='${MOCK_BIN}:${REPO_ROOT}/tests/helpers/mocks:${PATH}'
        source '${REPO_ROOT}/fkg'
        printf 'n\n' | git_restore lenovo/CT108/etc/nginx/nginx.conf
    "
    assert_output --partial "server { listen 80; }"
}

@test "git_restore aborts on n" {
    run bash -c "
        export FK_CACHE_DIR='${FK_CACHE_DIR}'
        export MOCK_GIT_CALLS_FILE='${MOCK_GIT_CALLS_FILE}'
        export PATH='${MOCK_BIN}:${REPO_ROOT}/tests/helpers/mocks:${PATH}'
        source '${REPO_ROOT}/fkg'
        printf 'n\n' | git_restore lenovo/CT108/etc/nginx/nginx.conf
    "
    assert_output --partial "Aborted"
    run grep "checkout" "$MOCK_GIT_CALLS_FILE"
    assert_failure
}

@test "git_restore runs git checkout on y" {
    run bash -c "
        export FK_CACHE_DIR='${FK_CACHE_DIR}'
        export MOCK_GIT_CALLS_FILE='${MOCK_GIT_CALLS_FILE}'
        export PATH='${MOCK_BIN}:${REPO_ROOT}/tests/helpers/mocks:${PATH}'
        source '${REPO_ROOT}/fkg'
        printf 'y\n' | git_restore lenovo/CT108/etc/nginx/nginx.conf abc1234
    "
    assert_output --partial "Restored"
    run grep "checkout" "$MOCK_GIT_CALLS_FILE"
    assert_success
}
