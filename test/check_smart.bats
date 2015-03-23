#!/usr/bin/env bats

load test_helper

@test 'Test check_smart.sh when `lsblk` is not found' {
  skip
  PATH="/fake:/bin:$BATS_TEST_DIRNAME/../" run check_smart.sh
  [ "$status" -eq 3 ]
  echo "$output" | grep 'UNKNOWN - Could not find `lsblk` utility'
}

@test 'Test check_smart.sh when `smartctl` is not found' {
  skip
  stub lsblk ''
  PATH="/fake:/bin:$BATS_TEST_DIRNAME/../:$BATS_TEST_DIRNAME/tmp/stub" \
    run check_smart.sh &>/tmp/smart
  echo "$output" > /tmp/smart
  [ "$status" -eq 3 ]
  echo "$output" | grep 'UNKNOWN - Could not find or execute `smartctl` utility'
}

@test 'Test check_smart.sh with healthy smartcl output' {
  skip
  local smartctl_output='SMART Error Log Version: 1
No Errors Logged'

  stub lsblk 'sda'
  stub 'smartctl -i' 'sda'
  stub 'smart' "$smartctl_output"

  run check_smart.sh
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - disk(s) look healthy :'
}
