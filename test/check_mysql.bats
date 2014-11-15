#!/usr/bin/env bats

load test_helper

@test 'Test check_mysql.sh output and the return code when mysqladmin is not found' {
  skip
  OLD_PATH=$PATH
  export PATH='.'
  run check_mysql.sh
  export PATH=$OLD_PATH
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - mysqladmin command not found'
}

@test 'Test check_mysql.sh output with fake mysqladmin command and successfull result' {
  local output='Uptime: 1232296  Threads: 7  Questions: 148586347  Slow queries: 965  Opens: 11911  Flush tables: 2  Open tables: 256  Queries per second avg: 120.576'
  stub mysqladmin "$output"

  run check_mysql.sh
  [ "$status" -eq 0 ]
}
