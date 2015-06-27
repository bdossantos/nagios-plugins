#!/usr/bin/env bats

load test_helper

@test 'Test check_php_fpm.sh with unreachable service' {
  run check_php_fpm.sh --host fakehost --port 123456 --warning 90 --critical 95 -s status
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - could not fetch php-fpm pool status page fakehost:123456/status'
}

@test 'Test check_php_fpm.sh with empty stats' {
  stub wget ''
  run check_php_fpm.sh --host fakehost --port 123456 --warning 90 --critical 95 -s status
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - could not fetch php-fpm pool status page fakehost:123456/status'
}

@test 'Test check_php_fpm.sh with empty active_processes/total_processes stats' {
  stub wget 'empty'
  run check_php_fpm.sh --host fakehost --port 123456 --warning 90 --critical 95 -s status
  [ "$status" -eq 3 ]
  echo "$output" | grep "UNKNOWN - 'active_processes' or 'total_processes' are empty"
}

@test 'Test check_php_fpm.sh with warn flag greater than critical' {
  run check_php_fpm.sh --host fakehost --port 123456 --warning 95 --critical 90 -s status
  [ "$status" -eq 3 ]
  echo "$output" | grep "UNKNOWN - warning (95) can't be greater than critical (90)"
}

@test 'Test check_php_fpm.sh with fake OK memcached' {
  local wget_output='pool:                 www
process manager:      static
start time:           26/Jun/2015:14:53:09 +0200
start since:          94382
accepted conn:        4230703
listen queue:         0
max listen queue:     1
listen queue len:     65535
idle processes:       211
active processes:     44
total processes:      256
max active processes: 120
max children reached: 0
slow requests:        1337'
  stub wget "$wget_output"

  run check_php_fpm.sh --host fakehost --port 123456 --warning 90 --critical 95 -s status
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - 17% of process pool is used (44 active processes on 256)'
}

@test 'Test check_php_fpm.sh with warning' {
  local wget_output='pool:                 www
process manager:      static
start time:           26/Jun/2015:14:53:09 +0200
start since:          94382
accepted conn:        4230703
listen queue:         0
max listen queue:     1
listen queue len:     65535
idle processes:       211
active processes:     227
total processes:      256
max active processes: 240
max children reached: 0
slow requests:        1337'
  stub wget "$wget_output"

  run check_php_fpm.sh --host fakehost --port 123456 --warning 85 --critical 90 -s status
  [ "$status" -eq 1 ]
  echo "$output" | grep 'WARNING - 88% of process pool is used (227 active processes on 256)'
}

@test 'Test check_php_fpm.sh with critical' {
  local wget_output='pool:                 www
process manager:      static
start time:           26/Jun/2015:14:53:09 +0200
start since:          94382
accepted conn:        4230703
listen queue:         0
max listen queue:     1
listen queue len:     65535
idle processes:       211
active processes:     252
total processes:      256
max active processes: 252
max children reached: 0
slow requests:        1337'
  stub wget "$wget_output"

  run check_php_fpm.sh --host fakehost --port 123456 --warning 85 --critical 90 -s status
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - 98% of process pool is used (252 active processes on 256)'
}
