setup() {
    load '../helpers/setup'
    common_setup
    # shellcheck disable=SC1091
    source "${REPO_ROOT}/fk"
}

teardown() {
    load '../helpers/setup'
    common_teardown
}

@test "setup_shell_integration adds block to .bashrc" {
    touch "$HOME/.bashrc"
    run setup_shell_integration
    assert_output --partial "Shell integration added to"
    run grep "_fk_inject_history" "$HOME/.bashrc"
    assert_success
}

@test "setup_shell_integration adds block to .zshrc" {
    touch "$HOME/.zshrc"
    run setup_shell_integration
    run grep "_fk_inject_history" "$HOME/.zshrc"
    assert_success
}

@test "setup_shell_integration skips if already present in .bashrc" {
    touch "$HOME/.bashrc"
    echo "_fk_inject_history" >> "$HOME/.bashrc"
    run setup_shell_integration
    assert_output --partial "already present"
}

@test "setup_shell_integration does nothing when no rc files exist" {
    run setup_shell_integration
    assert_success
    assert_output ""
}
