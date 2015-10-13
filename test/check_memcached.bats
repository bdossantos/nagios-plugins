#!/usr/bin/env bats

load test_helper

@test 'Test check_memcached.sh with unreachable service' {
  run check_memcached.sh --host fakehost --port 123456
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - timed out connecting to memcached on fakehost:123456'
}

@test 'Test check_memcached.sh with empty stats' {
  stub nc ''
  run check_memcached.sh --host fakehost --port 123456
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - timed out connecting to memcached on fakehost:123456'
}

@test 'Test check_memcached.sh with empty limit_maxbytes/bytes stats' {
  stub nc 'empty'
  run check_memcached.sh --host fakehost --port 123456
  [ "$status" -eq 2 ]
  echo "$output" | grep "CRITICAL - 'limit_maxbytes' and 'bytes' are empty"
}

@test 'Test check_memcached.sh with warn flag greater than critical' {
  run check_memcached.sh --warning 95 --critical 90
  [ "$status" -eq 3 ]
  echo "$output" | grep "UNKNOWN - warn (95) can't be greater than critical (90)"
}

@test 'Test check_memcached.sh with fake OK but empty memcached' {
  local nc_output='STAT limit_maxbytes 4294967296
  STAT bytes 0'
  stub nc "$nc_output"

  run check_memcached.sh --host fakehost --port 123456 --warning 90 --critical 95
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - Memcached is empty'
}

@test 'Test check_memcached.sh with fake OK memcached' {
  local nc_output='STAT limit_maxbytes 4294967296
  STAT bytes 606577764
  STAT get_hits 3082625389
  STAT get_misses 118496131'
  stub nc "$nc_output"

  run check_memcached.sh --host fakehost --port 123456 --warning 90 --critical 95
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - 14% used (606577764 of 4294967296) bytes used, get hit ratio 96.30%'
}

@test 'Test check_memcached.sh with warning' {
  local nc_output='STAT limit_maxbytes 4294967296
  STAT bytes 4000000321
  STAT get_hits 3082625389
  STAT get_misses 118496131'
  stub nc "$nc_output"

  run check_memcached.sh --host fakehost --port 123456
  [ "$status" -eq 1 ]
  echo "$output" | grep 'WARNING - 93% used (4000000321 of 4294967296) bytes used, get hit ratio 96.30%'
}

@test 'Test check_memcached.sh with critical' {
  local nc_output='STAT limit_maxbytes 4294967296
  STAT bytes 4200000123
  STAT get_hits 3082625389
  STAT get_misses 118496131'
  stub nc "$nc_output"

  run check_memcached.sh --host fakehost --port 123456
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - 97% used (4200000123 of 4294967296) bytes used, get hit ratio 96.30%'
}
