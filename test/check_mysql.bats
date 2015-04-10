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
  stub mysqladmin "$mysql_output" 1

  run check_mysql.sh
  [ "$status" -eq 2 ]
}

@test "Test check_mysql.sh when can't fetch 'max_connections' value" {
  local mysql_output='Uptime: 1232296  Threads: 7  Questions: 148586347  Slow queries: 965  Opens: 11911  Flush tables: 2  Open tables: 256  Queries per second avg: 120.576'
  stub mysqladmin "$mysql_output"
  stub mysql 'error' 1
  stub awk 'error' 1

  run check_mysql.sh
  echo "$mysql_output" >/tmp/my
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - could not fetch MySQL max_connections'
}

@test "Test check_mysql.sh when 'connected_thread' and 'max_connections' are empty" {
  local mysql_output='Uptime: 1232296  Threads: 7  Questions: 148586347  Slow queries: 965  Opens: 11911  Flush tables: 2  Open tables: 256  Queries per second avg: 120.576'
  stub mysqladmin "$mysql_output"
  stub mysql '' 1

  run check_mysql.sh
  [ "$status" -eq 2 ]
  echo "$output" | grep "CRITICAL - 'connected_thread' and 'max_connections' are empty"
}

@test 'Test check_mysql.sh with warn flag greater than critical' {
  local mysql_output='Uptime: 1232296  Threads: 7  Questions: 148586347  Slow queries: 965  Opens: 11911  Flush tables: 2  Open tables: 256  Queries per second avg: 120.576'
  stub mysqladmin "$mysql_output"

  run check_mysql.sh --warning 95 --critical 90
  [ "$status" -eq 3 ]
  echo "$output" | grep "UNKNOWN - warning (95) can't be greater than critical (90)"
}

@test 'Test check_mysql.sh output with fake mysqladmin command and successfull result' {
  local mysql_output='Uptime: 1232296  Threads: 17  Questions: 148586347  Slow queries: 965  Opens: 11911  Flush tables: 2  Open tables: 256  Queries per second avg: 120.576'
  stub mysqladmin "$mysql_output"
  stub mysql 'max_connections 500'

  run check_mysql.sh
  [ "$status" -eq 0 ]
  echo "$output" | grep "$mysql_output"
}

@test 'Test check_mysql.sh with warning max_connections threshold' {
  local mysql_output='Uptime: 1232296  Threads: 470  Questions: 148586347  Slow queries: 965  Opens: 11911  Flush tables: 2  Open tables: 256  Queries per second avg: 120.576'
  stub mysqladmin "$mysql_output"
  stub mysql 'max_connections 500'

  run check_mysql.sh --warning 90 --critical 95
  [ "$status" -eq 1 ]
  echo "$output" | grep "WARNING - $mysql_output - 470 of 500 max_connections"
}

@test 'Test check_mysql.sh with critical max_connections threshold' {
  local mysql_output='Uptime: 1232296  Threads: 490  Questions: 148586347  Slow queries: 965  Opens: 11911  Flush tables: 2  Open tables: 256  Queries per second avg: 120.576'
  stub mysqladmin "$mysql_output"
  stub mysql 'max_connections 500'

  run check_mysql.sh --warning 90 --critical 95
  [ "$status" -eq 2 ]
  echo "$output" | grep "CRITICAL - $mysql_output - 490 of 500 max_connections"
}
