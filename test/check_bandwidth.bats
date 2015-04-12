#!/usr/bin/env bats

load test_helper

@test 'Test check_bandwidth.sh with warn flag greater than critical' {
  run check_bandwidth.sh --warning 8000 --critical 6000
  [ "$status" -eq 3 ]
  echo "$output" | grep "UNKNOWN - warning (8000) can't be greater than critical (6000)"
}

@test 'Test check_bandwidth.sh when network interface is not found' {
  run check_bandwidth.sh -i fake_eth1337
  [ "$status" -eq 2 ]
  echo "$output" | grep "CRITICAL - Could not fetch 'fake_eth1337' interface statistics"
}
