#!/usr/bin/env bats

load test_helper

@test 'Test return code when using help flag' {
  for file in $NAGIOS_BASH_SCRIPTS; do
    run bash $file --help
    [ "$status" -eq 3 ]
  done
}

@test 'Test if help flag return usage instructions' {
  for file in $NAGIOS_BASH_SCRIPTS; do
    run bash $file --help
    echo "$output" | grep -i "Usage:"
  done
}

@test 'Test return code when using unknown flag' {
  for file in $NAGIOS_BASH_SCRIPTS; do
    run bash $file --unknown-flag-ya-rly
    [ "$status" -eq 3 ]
    echo "$output" | grep -i "Usage:"
  done
}
