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

@test "add_file appends path|desc to DB" {
    run add_file /etc/nginx/nginx.conf nginx config
    assert_success
    assert_output --partial "Added: /etc/nginx/nginx.conf [nginx config]"
    run grep -c "^/etc/nginx/nginx.conf|nginx config$" "$FK_DB"
    assert_output "1"
}

@test "add_file creates DB if it does not exist" {
    [ ! -f "$FK_DB" ]
    add_file /etc/foo.conf foo
    [ -f "$FK_DB" ]
}

@test "add_file rejects duplicate path" {
    populate_db "/etc/nginx/nginx.conf|nginx config"
    run add_file /etc/nginx/nginx.conf other desc
    assert_output --partial "File already tracked: /etc/nginx/nginx.conf"
    run wc -l < "$FK_DB"
    assert_output "1"
}

@test "add_file requires both path and description" {
    run add_file /etc/foo.conf
    assert_output --partial "Usage: fk --add"
}

@test "add_file requires path" {
    run add_file
    assert_output --partial "Usage: fk --add"
}

@test "add_file -s resolves service path from systemctl" {
    export MOCK_SYSTEMCTL_PATH="/etc/systemd/system/test.service"
    run add_file -s test.service "test service"
    assert_success
    assert_output --partial "Added: /etc/systemd/system/test.service"
    run grep "^/etc/systemd/system/test.service|" "$FK_DB"
    assert_success
}

@test "add_file -s fails gracefully when service not found" {
    export MOCK_SYSTEMCTL_PATH=""
    run add_file -s nonexistent.service
    assert_output --partial "Service not found: nonexistent.service"
    [ ! -f "$FK_DB" ] || [ ! -s "$FK_DB" ]
}

@test "add_file -s rejects duplicate service" {
    export MOCK_SYSTEMCTL_PATH="/etc/systemd/system/test.service"
    add_file -s test.service "test"
    run add_file -s test.service "test"
    assert_output --partial "File already tracked"
}

@test "add_file -s requires service name" {
    run add_file -s
    assert_output --partial "Usage: fk --add -s"
}
