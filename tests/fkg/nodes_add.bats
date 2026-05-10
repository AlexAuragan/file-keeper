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

@test "nodes_add writes name and ip to nodes file" {
    run nodes_add dell 192.168.1.10
    assert_success
    assert_output --partial "Added: dell (192.168.1.10)"
    run grep "^dell 192.168.1.10$" "$FK_NODES_FILE"
    assert_success
}

@test "nodes_add writes name-only line when no ip given" {
    run nodes_add lenovo
    assert_success
    assert_output --partial "Added: lenovo"
    run grep "^lenovo$" "$FK_NODES_FILE"
    assert_success
}

@test "nodes_add creates nodes file if it does not exist" {
    [ ! -f "$FK_NODES_FILE" ]
    nodes_add dell 192.168.1.10
    [ -f "$FK_NODES_FILE" ]
}

@test "nodes_add rejects duplicate name with ip" {
    echo "dell 192.168.1.10" > "$FK_NODES_FILE"
    run nodes_add dell 192.168.1.20
    assert_failure
    assert_output --partial "Node already exists: dell"
}

@test "nodes_add rejects duplicate name without ip" {
    echo "lenovo" > "$FK_NODES_FILE"
    run nodes_add lenovo
    assert_failure
    assert_output --partial "Node already exists: lenovo"
}

@test "nodes_add requires a name argument" {
    run nodes_add
    assert_failure
    assert_output --partial "Usage:"
}
