setup() {
    load '../helpers/setup'
    common_setup
}

teardown() {
    load '../helpers/setup'
    common_teardown
}

@test "delete_file removes selected entry from DB" {
    populate_db \
        "/etc/nginx/nginx.conf|nginx" \
        "/etc/redis/redis.conf|redis"

    # Select entry "1" (nginx) at the interactive prompt
    run bash -c "
        export FK_DB='${FK_DB}'
        export FK_EDITOR='true'
        printf '1\n' | '${REPO_ROOT}/fk' --delete
    "
    assert_success
    run grep "/etc/nginx/nginx.conf" "$FK_DB"
    assert_failure
    run grep "/etc/redis/redis.conf" "$FK_DB"
    assert_success
}

@test "delete_file with empty DB shows getting started message" {
    run bash -c "
        export FK_DB='${FK_DB}'
        '${REPO_ROOT}/fk' --delete
    "
    assert_output --partial "Get started"
}
