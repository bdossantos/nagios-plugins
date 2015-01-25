#!/usr/bin/env bats

load test_helper

@test 'Test check_conntrack.sh when conntrack_count/conntrack_max are not found' {
  # fake `find /proc/sys -type f -name '*conntrack_count' | head -n 1` output
  stub find ''
  stub head ''

  run check_conntrack.sh --warning 75 --critical 90
  [ "$status" -eq 3 ]
  echo "$output" | grep "ERROR - Can't find \*conntrack_count"
}
