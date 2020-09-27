#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l
  dokku apps:create my_app
  dokku "$PLUGIN_COMMAND_PREFIX:link" l my_app
}

teardown() {
  dokku "$PLUGIN_COMMAND_PREFIX:unlink" l my_app
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l
  dokku --force apps:destroy my_app
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote"
  assert_contains "${lines[*]}" "Please specify a valid name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the app argument is missing" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l
  assert_contains "${lines[*]}" "Please specify an app to run the command on"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the app does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l not_existing_app
  assert_contains "${lines[*]}" "App not_existing_app does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" not_existing_service my_app
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) error when the service is already promoted" {
  run dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  assert_contains "${lines[*]}" "already promoted as CLICKHOUSE_URL"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) changes CLICKHOUSE_URL" {
  password="$(sudo cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  dokku config:set my_app "CLICKHOUSE_URL=clickhouse://u:p@host:9000/db" "DOKKU_CLICKHOUSE_BLUE_URL=clickhouse://l:$password@dokku-clickhouse-l:9000/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  url=$(dokku config:get my_app CLICKHOUSE_URL)
  assert_equal "$url" "clickhouse://l:$password@dokku-clickhouse-l:9000/l"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) creates new config url when needed" {
  password="$(sudo cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  dokku config:set my_app "CLICKHOUSE_URL=clickhouse://u:p@host:9000/db" "DOKKU_CLICKHOUSE_BLUE_URL=clickhouse://l:$password@dokku-clickhouse-l:9000/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  run dokku config my_app
  assert_contains "${lines[*]}" "DOKKU_CLICKHOUSE_"
}

@test "($PLUGIN_COMMAND_PREFIX:promote) uses CLICKHOUSE_DATABASE_SCHEME variable" {
  password="$(sudo cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  dokku config:set my_app "CLICKHOUSE_DATABASE_SCHEME=clickhouse2" "CLICKHOUSE_URL=clickhouse://u:p@host:9000/db" "DOKKU_CLICKHOUSE_BLUE_URL=clickhouse2://l:$password@dokku-clickhouse-l:9000/l"
  dokku "$PLUGIN_COMMAND_PREFIX:promote" l my_app
  url=$(dokku config:get my_app CLICKHOUSE_URL)
  assert_contains "$url" "clickhouse2://l:$password@dokku-clickhouse-l:9000/l"
}
