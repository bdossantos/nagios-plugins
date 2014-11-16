#!/usr/bin/env bats

load test_helper

@test 'Test check_memory.sh under warning/critical treshold' {
  local free_output='total       used       free     shared    buffers     cached
Mem:         32070      26552       5518          0        212       5784
-/+ buffers/cache:      20555      11515
Swap:         1021          0       1021'
  stub free "$free_output"

  run check_memory.sh --warning 90 --critical 95
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - 64% (20555 of 32070) MB used'
}

@test 'Test check_memory.sh warning' {
  local free_output='total       used       free     shared    buffers     cached
Mem:         32070      31831        238          0        121       2293
-/+ buffers/cache:      29417       2653
Swap:         1021          0       1021'
  stub free "$free_output"

  run check_memory.sh --warning 90 --critical 95
  [ "$status" -eq 1 ]
  echo "$output" | grep 'WARNING - 91% (29417 of 32070) MB used'
}

@test 'Test check_memory.sh critical' {
  local free_output='total       used       free     shared    buffers     cached
Mem:         32070      31831        238          0        121       2293
-/+ buffers/cache:      29417       2653
Swap:         1021          0       1021'
  stub free "$free_output"

  run check_memory.sh --warning 85 --critical 90
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - 91% (29417 of 32070) MB used'
}

@test 'Test check_memory.sh unknown' {
  stub free ''

  run check_memory.sh --warning 85 --critical 90
  [ "$status" -eq 3 ]
  echo "$output" | grep 'UNKNOWN - Error'
}
