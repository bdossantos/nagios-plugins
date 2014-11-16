#!/usr/bin/env bats

load test_helper

@test 'Test check_influxdb.sh with fake up and running InfluxDB' {
  stub curl '{"status":"ok"}'
  run check_influxdb.sh
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - InfluxDB is up & running'
}

@test 'Test check_influxdb.sh with KO InfluxDB' {
  run check_influxdb.sh
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - InfluxDB is KO'
}
