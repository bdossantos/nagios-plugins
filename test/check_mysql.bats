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

@test 'Test check_mysql.sh output with fake mysqladmin command and successfull result' {
  local output='Uptime: 1232296  Threads: 7  Questions: 148586347  Slow queries: 965  Opens: 11911  Flush tables: 2  Open tables: 256  Queries per second avg: 120.576'
  stub mysqladmin "$output"

  run check_mysql.sh
  [ "$status" -eq 0 ]
  echo "$output" | grep "$output"
}
