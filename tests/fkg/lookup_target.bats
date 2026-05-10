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

@test "lookup_target returns ip when name has ip in config" {
    echo "dell 192.168.1.10" > "$FK_NODES_FILE"
    run lookup_target dell
    assert_output "192.168.1.10"
}

@test "lookup_target returns name when no ip configured" {
    echo "lenovo" > "$FK_NODES_FILE"
    run lookup_target lenovo
    assert_output "lenovo"
}

@test "lookup_target returns name when not in config file" {
    echo "dell 192.168.1.10" > "$FK_NODES_FILE"
    run lookup_target pve3
    assert_output "pve3"
}

@test "lookup_target returns name when config file does not exist" {
    run lookup_target somenode
    assert_output "somenode"
}

@test "lookup_target only matches exact name not prefix" {
    printf "dell 192.168.1.10\ndell2 192.168.1.11\n" > "$FK_NODES_FILE"
    run lookup_target dell
    assert_output "192.168.1.10"
}
