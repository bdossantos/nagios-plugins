#!/usr/bin/env bats

load test_helper

@test 'Test check_last.sh output and exit code when everything is OK' {
  local last_output='bdossant pts/2        1.2.3.4    Sun May  17 13:37   still logged in'
  stub last "$last_output"

  run check_last.sh
  [ "$status" -eq 0 ]
  echo "$output" | grep 'bdossant pts/2        1.2.3.4    Sun May  17 13:37   still logged in'
}

@test 'Test check_last.sh exit code when something went wrong' {
  # stub tail exit code, the last command of the pipe
  stub tail " " 1

  run check_last.sh
  [ "$status" -eq 1 ]
}
