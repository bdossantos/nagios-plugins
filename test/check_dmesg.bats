#!/usr/bin/env bats

load test_helper

@test 'Test check_dmesg.sh output with dmesg command returning sample I/O error' {
  local dmesg_output='web03.prd.rou.bds.tld: kernel: end_request: I/O error, dev sdb, sector 1953525160
  web03.prd.rou.bds.tld: Buffer I/O error on device sdb, logical block 244190645
  '
  stub dmesg "$dmesg_output"

  run check_dmesg.sh
  [ "$status" -eq 1 ]
  echo "$output" | grep 'WARNING - The dmesg output contain error(s) :'
}
