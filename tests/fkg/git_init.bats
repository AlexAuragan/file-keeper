setup() {
    load '../helpers/setup'
    common_setup
    # shellcheck disable=SC1091
    source "${REPO_ROOT}/fkg"
}

teardown() {
    load '../helpers/setup'
    common_teardown
}

@test "git_init creates cache dir if missing" {
    rm -rf "$FK_CACHE_DIR"
    git_init
    [ -d "$FK_CACHE_DIR" ]
}

@test "git_init calls git init in cache dir" {
    git_init
    run grep "init" "$MOCK_GIT_CALLS_FILE"
    assert_success
}

@test "git_init with remote adds origin" {
    git_init "git@forgejo.example.com:user/repo.git"
    run grep "remote add origin" "$MOCK_GIT_CALLS_FILE"
    assert_success
}

@test "git_init prints already initialized when .git exists" {
    mkdir -p "$FK_CACHE_DIR/.git"
    run git_init
    assert_output --partial "Git already initialized"
}

@test "git_init with remote on existing repo sets url instead" {
    mkdir -p "$FK_CACHE_DIR/.git"
    # Make git remote add fail so the || branch (set-url) is triggered
    cat > "$MOCK_BIN/git" <<'EOF'
#!/bin/bash
echo "$*" >> "${MOCK_GIT_CALLS_FILE:-/dev/null}"
case "$*" in
    *"remote add"*) exit 1 ;;
    *) exit 0 ;;
esac
EOF
    chmod +x "$MOCK_BIN/git"
    git_init "git@forgejo.example.com:user/repo.git"
    run grep "remote set-url" "$MOCK_GIT_CALLS_FILE"
    assert_success
}
