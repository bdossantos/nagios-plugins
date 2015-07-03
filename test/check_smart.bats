#!/usr/bin/env bats

load test_helper

@test 'Test check_smart.sh when `lsblk` is not found' {
  [[ $OS == 'Linux' ]] && skip 'Skip - on Linux'
  # this test will fail if /bin/lsblk exist, and we need /bin in PATH
  PATH="/fake:/bin:$BATS_TEST_DIRNAME/../" run check_smart.sh
  [ "$status" -eq 3 ]
  echo "$output" | grep 'UNKNOWN - Could not find `lsblk` utility'
}

@test 'Test check_smart.sh when `smartctl` is not found' {
  stub lsblk ''
  PATH="/fake:/bin:$BATS_TEST_DIRNAME/../:$BATS_TEST_DIRNAME/tmp/stub" \
    run check_smart.sh
  [ "$status" -eq 3 ]
  echo "$output" | grep 'UNKNOWN - Could not find or execute `smartctl` utility'
}

@test 'Test check_smart.sh with healthy smartcl output' {
  local smartctl_output='SMART Error Log Version: 1
No Errors Logged'

  stub lsblk 'sda'
  stub 'smartctl' 'SMART support is: Available'
  stub 'smart' "$smartctl_output"

  run check_smart.sh
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - disk(s) look healthy :'
}
