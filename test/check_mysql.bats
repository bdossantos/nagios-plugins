#!/usr/bin/env bats

load test_helper

@test 'Test check_mysql.sh output and the return code when mysqladmin is not found' {
  PATH="/fake:/bin:$BATS_TEST_DIRNAME/../" run check_mysql.sh
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - mysqladmin command not found'
}

@test 'Test check_mysql.sh output with failed connection' {
  local output="mysqladmin: connect to server at 'localhost' failed
  error: 'Can't connect to local MySQL server through socket '/tmp/mysql.sock' (2)'
  Check that mysqld is running and that the socket: '/tmp/mysql.sock' exists!"
  stub mysqladmin "$output" 1

  run check_mysql.sh
  [ "$status" -eq 2 ]
}

@test "Test check_mysql.sh when can't fetch 'max_connections' value" {
  local output='Uptime: 1232296  Threads: 7  Questions: 148586347  Slow queries: 965  Opens: 11911  Flush tables: 2  Open tables: 256  Queries per second avg: 120.576'
  stub mysqladmin "$output"
  stub mysql 'error' 1
  stub awk 'error' 1

  run check_mysql.sh
  echo "$output" >/tmp/my
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - could not fetch MySQL max_connections'
}

@test "Test check_mysql.sh when 'connected_thread' and 'max_connections' are empty" {
  local output='Uptime: 1232296  Threads: 7  Questions: 148586347  Slow queries: 965  Opens: 11911  Flush tables: 2  Open tables: 256  Queries per second avg: 120.576'
  stub mysqladmin "$output"
  stub mysql '' 1

  run check_mysql.sh
  [ "$status" -eq 2 ]
  echo "$output" | grep "CRITICAL - 'connected_thread' and 'max_connections' are empty"
}

@test 'Test check_mysql.sh with warn flag greater than critical' {
  local output='Uptime: 1232296  Threads: 7  Questions: 148586347  Slow queries: 965  Opens: 11911  Flush tables: 2  Open tables: 256  Queries per second avg: 120.576'
  stub mysqladmin "$output"

  run check_mysql.sh --warning 95 --critical 90
  [ "$status" -eq 3 ]
  echo "$output" >/tmp/my
  echo "$output" | grep "UNKNOWN - warning (95) can't be greater than critical (90)"
}

@test 'Test check_mysql.sh output with fake mysqladmin command and successfull result' {
  local output='Uptime: 1232296  Threads: 7  Questions: 148586347  Slow queries: 965  Opens: 11911  Flush tables: 2  Open tables: 256  Queries per second avg: 120.576 - 7 of 500 max_connections'
  stub mysqladmin "$output"
  stub mysql 'max_connections 500'

  run check_mysql.sh
  [ "$status" -eq 0 ]
  echo "$output" | grep "$output"
}
