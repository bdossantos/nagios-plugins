#!/usr/bin/env bats

load test_helper

@test 'Test check_gcp_maintenance_event.sh without scheduled host maintenance' {
  stub curl 'NONE'
  run check_gcp_maintenance_event.sh
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - No scheduled host maintenance'
}

@test 'Test check_gcp_maintenance_event.sh with undergoing host maintenance : instance will be migrated' {
  stub curl 'MIGRATE_ON_HOST_MAINTENANCE'
  run check_gcp_maintenance_event.sh
  [ "$status" -eq 1 ]
  echo "$output" | grep 'WARNING - Undergoing host maintenance, instance will be migrated'
}

@test 'Test check_gcp_maintenance_event.sh with undergoing host maintenance : instance will be shut down' {
  stub curl 'SHUTDOWN_ON_HOST_MAINTENANCE'
  run check_gcp_maintenance_event.sh
  [ "$status" -eq 1 ]
  echo "$output" | grep 'WARNING - Undergoing host maintenance, instance will be shut down'
}

@test 'Test check_gcp_maintenance_event.sh while we could not fetch instance event' {
  stub curl '' 255
  run check_gcp_maintenance_event.sh
  [ "$status" -eq 3 ]
  echo "$output" | grep 'UNKNOWN - Could not fetch maintenance event'
}
