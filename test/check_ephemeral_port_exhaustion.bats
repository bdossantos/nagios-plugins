#!/usr/bin/env bats

load test_helper

@test 'Test check_ephemeral_port_exhaustion.sh with critical flag greater than warning' {
  run check_ephemeral_port_exhaustion.sh --warning 512 --critical 1024
  [ "$status" -eq 3 ]
  [ "$output" = "UNKNOWN - critical (1024) can't be greater than warning (512)" ]
}

@test 'Test check_ephemeral_port_exhaustion.sh when could not fetch local port range' {
  # eg: '/proc/sys/net/ipv4/ip_local_port_range' does not exist on Darwin
  [[ $OS == 'Linux' ]] && skip 'Skip - on Linux'

  run check_ephemeral_port_exhaustion.sh --warning 2048 --critical 1024
  [ "$status" -eq 2 ]
  [ "$output" = 'CRITICAL - Could not fetch local port range' ]
}

@test 'Test check_ephemeral_port_exhaustion.sh when could not fetch min/max port range' {
  [[ $OS != 'Linux' ]] && skip 'Skip - not on Linux'
  # fake `cat /proc/sys/net/ipv4/ip_local_port_range`
  stub cat ''

  run check_ephemeral_port_exhaustion.sh --warning 2048 --critical 1024
  [ "$status" -eq 2 ]
  [ "$output" = "CRITICAL - could not fetch 'min_port_range' or 'max_port_range'" ]
}

@test 'Test check_ephemeral_port_exhaustion.sh when critial treshold is reached' {
  # fake `cat /proc/sys/net/ipv4/ip_local_port_range`
  stub cat '32768   61000'
  # fake `netstat -an | grep -c 'ESTABLISHED'`
  stub grep '28137'

  run check_ephemeral_port_exhaustion.sh --warning 2048 --critical 1024
  [ "$status" -eq 2 ]
  [ "$output" = 'CRITICAL - 28137 established connections, 95 free ephemeral ports (range 32768-61000)' ]
}

@test 'Test check_ephemeral_port_exhaustion.sh when treshold treshold is reached' {
  # fake `cat /proc/sys/net/ipv4/ip_local_port_range`
  stub cat '32768   61000'
  # fake `netstat -an | grep -c 'ESTABLISHED'`
  stub grep '27123'

  run check_ephemeral_port_exhaustion.sh --warning 2048 --critical 1024
  [ "$status" -eq 1 ]
  [ "$output" = 'WARNING - 27123 established connections, 1109 free ephemeral ports (range 32768-61000)' ]
}

@test 'Test check_ephemeral_port_exhaustion.sh when everything is OK' {
  # fake `cat /proc/sys/net/ipv4/ip_local_port_range`
  stub cat '32768   61000'
  # fake `netstat -an | grep -c 'ESTABLISHED'`
  stub grep '1337'

  run check_ephemeral_port_exhaustion.sh --warning 2048 --critical 1024
  [ "$status" -eq 0 ]
  [ "$output" = 'OK - 1337 established connections, 26895 free ephemeral ports (range 32768-61000)' ]
}
