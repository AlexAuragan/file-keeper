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

@test "build_lists returns 1 and prints message when DB is empty" {
    run build_lists
    assert_failure
    assert_output --partial "No files tracked yet."
}

@test "build_lists returns 1 when DB does not exist" {
    run build_lists
    assert_failure
}

@test "build_lists populates config_files for non-systemd paths" {
    populate_db "/etc/nginx/nginx.conf|nginx" "/etc/redis/redis.conf|redis"
    config_files=()
    service_files=()
    build_lists
    [ "${#config_files[@]}" -eq 2 ]
    [ "${#service_files[@]}" -eq 0 ]
}

@test "build_lists populates service_files for systemd paths" {
    populate_db "/etc/systemd/system/foo.service|foo" "/usr/lib/systemd/system/bar.service|bar"
    config_files=()
    service_files=()
    build_lists
    [ "${#service_files[@]}" -eq 2 ]
    [ "${#config_files[@]}" -eq 0 ]
}

@test "build_lists separates mixed entries correctly" {
    populate_db "/etc/nginx/nginx.conf|nginx" "/etc/systemd/system/foo.service|foo"
    config_files=()
    service_files=()
    build_lists
    [ "${#config_files[@]}" -eq 1 ]
    [ "${#service_files[@]}" -eq 1 ]
}

@test "build_lists stores path|desc in arrays" {
    populate_db "/etc/nginx/nginx.conf|nginx config"
    config_files=()
    service_files=()
    build_lists
    [[ "${config_files[0]}" == "/etc/nginx/nginx.conf|nginx config" ]]
}
