#!/usr/bin/env bats

load test_helper

@test 'Check the check_fs_writable.sh output and the return code when no argument provided' {
  run check_fs_writable.sh
  [ "$status" -eq 2 ]
  echo "$output" | grep 'CRITICAL - the path to directory to check is not defined'
}

@test 'Check the check_fs_writable.sh return code when writing to current working directory' {
  run check_fs_writable.sh -d ./
  [ "$status" -eq 0 ]
  echo "$output" | grep "OK - './' directory is writable"
}

@test 'Check the check_fs_writable.sh return code when writing to a non-existent directory' {
  run check_fs_writable.sh -d /nonexistentdirectory
  [ "$status" -eq 2 ]
  echo "$output" | grep "CRITICAL - '/nonexistentdirectory' does not exist!"
}

@test 'Check the check_fs_writable.sh return code when writing to a non-writable directory : /' {
  run check_fs_writable.sh -d /
  [ "$status" -eq 2 ]
  echo "$output" | grep "CRITICAL - Could not create a file into '/' directory!"
}
