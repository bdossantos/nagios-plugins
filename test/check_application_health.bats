#!/usr/bin/env bats

load test_helper

@test 'Test check_application_health.sh without webroot and command flags provided' {
  run check_application_health.sh
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - undefined webroot or command'
}

@test 'Test check_application_health.sh without webroot flag provided' {
  run check_application_health.sh -c /bin/false
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - undefined webroot or command'
}

@test 'Test check_application_health.sh without command flag provided' {
  run check_application_health.sh -w $TMP
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - undefined webroot or command'
}

@test 'Test check_application_health.sh with non existent webroot' {
  run check_application_health.sh -w /nonexistentdirectory -c /bin/false
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - webroot directory does not exist'
}

@test 'Test check_application_health.sh with fake unhealthy app' {
  run check_application_health.sh -w $TMP -c false
  [ "$status" -eq 2 ]
  echo "$output" | grep "CRITICAL - The application is sick, 'false' return code != 0 !"
}

@test 'Test check_application_health.sh with fake healthy app' {
  run check_application_health.sh -w $TMP -c true
  [ "$status" -eq 0 ]
  echo "$output" | grep 'OK - The application is healthy'
}
