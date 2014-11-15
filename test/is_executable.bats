#!/usr/bin/env bats

load test_helper

@test "Check if each script is executable" {
  for file in $NAGIOS_BASH_SCRIPTS; do
    run test -x "$file"
    [ $status -eq 0 ]
  done
}
