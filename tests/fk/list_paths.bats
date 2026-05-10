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

@test "list_paths prints nothing when DB does not exist" {
    run list_paths
    assert_success
    assert_output ""
}

@test "list_paths prints nothing for empty DB" {
    touch "$FK_DB"
    run list_paths
    assert_success
    assert_output ""
}

@test "list_paths prints one path per line without description" {
    populate_db "/etc/nginx/nginx.conf|nginx" "/etc/redis/redis.conf|redis"
    run list_paths
    assert_success
    assert_output "/etc/nginx/nginx.conf
/etc/redis/redis.conf"
}

@test "list_paths strips description from output" {
    populate_db "/etc/foo.conf|some long description here"
    run list_paths
    assert_output "/etc/foo.conf"
}
