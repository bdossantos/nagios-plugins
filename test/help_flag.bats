#!/usr/bin/env bats

load test_helper

@test 'Check return code when using help flag' {
  for file in $NAGIOS_BASH_SCRIPTS; do
    run bash $file --help
    [ "$status" -eq 3 ]
  done
}

@test 'Check if help flag return usage instructions' {
  for file in $NAGIOS_BASH_SCRIPTS; do
    run bash $file --help
    echo "$output" | grep -i "Usage:"
  done
}
